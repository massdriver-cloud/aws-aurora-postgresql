#! /usr/bin/env ruby
require 'json'
require 'pp'
require 'yaml'
require 'digest'

$force = false
$engine = "aurora-postgresql"
$region = "us-east-1"
$engines_file = "/tmp/aws-rds-#{$engine}-engines.json"
# db instance name to ec2 details
$instance_classes = {}

# tracks group id to list of aws instance classes
$instances_classes_in_group = {}

# This is an optimization around minimizing the number of oneOfs w/ repeated instance classes
engine_version_to_instance_class_group = {}

def generate_instance_class_group_jsonschema_id(instance_classes)
  group_id = Digest::SHA2.hexdigest(instance_classes.sort.join(','))

  $instances_classes_in_group[group_id] = instance_classes

  group_id
end

$mdyaml = "massdriver.yaml"
conf = YAML.load(File.read($mdyaml))

def maybe_get_data(cmd, file, force)
  if !File.exists?(file) || force
    `#{cmd} > #{file}`
  else
    puts "#{file} exists, skipping fetch..."
  end
end

def read_json_file(file)
  JSON.parse(File.read(file))
end

def instance_details_file(joined_list_of_instances)
  hash = Digest::SHA2.hexdigest(joined_list_of_instances)
  "/tmp/aws-rds-#{$engine}-instances-details-#{hash}.json"
end

def engine_version_instance_file(v)
  "/tmp/aws-rds-#{$engine}-#{v}-instances.json"
end

def transform_instance_class_from(t, from)
  if from == :rds
    t = t[3..-1]

    if t == "serverless"
      nil
    elsif t =~ /^x2g/
      t.gsub("x2g", "x2gd")
    else
      t
    end
  elsif from == :ec2
    t = if t =~ /^x2gd/
      t.gsub("x2gd", "x2g")
    else
      t
    end
    "db.#{t}"
  else
    t
  end
end

## Get Engine Versions
### This was set by update-engine-version.rb
supported_engine_versions = conf["params"]["properties"]["database"]["properties"]["version"]["enum"]
supported_engine_versions_to_instance_class_map = {}

## Map engine version to instance types

# for each engine version, get all instance types supported and store in file
#   track all instance types for getting details

supported_engine_versions.each do |engine_version|
  puts "Getting instances for #{engine_version}"
  instances_file = engine_version_instance_file(engine_version)
  maybe_get_data("aws rds describe-orderable-db-instance-options --engine #{$engine} --engine-version #{engine_version} --region #{$region} --vpc", instances_file, false)
  instances = read_json_file(instances_file)

  supported_engine_versions_to_instance_class_map[engine_version] = []

  instances["OrderableDBInstanceOptions"].each do |v|
    next if !supported_engine_versions.member?(v["EngineVersion"])
    rds_instance_class = v["DBInstanceClass"]

    supported_engine_versions_to_instance_class_map[engine_version].push(rds_instance_class)

    if rds_instance_class == "db.serverless"
      $instance_classes[rds_instance_class] = {
        RDSInstanceType: rds_instance_class,
        EC2InstanceType: nil,
        DefaultVCpus: 0,
        SizeInGiB: 0,
        Note: "",
        Label: "Serverless 2GiB / 1 ACU (db.serverless)"
      }
    else
      $instance_classes[rds_instance_class] = {
        EC2InstanceType: transform_instance_class_from(rds_instance_class, :rds)
      }
    end
  end

  group_id = generate_instance_class_group_jsonschema_id(supported_engine_versions_to_instance_class_map[engine_version])
  engine_version_to_instance_class_group[engine_version] = group_id
end

$instance_classes.each_slice(100) do |instance_class_chunk|
  chunked_ec2_names = instance_class_chunk.map{|_k, v| v[:EC2InstanceType]}
  joined_for_cli = chunked_ec2_names.join(' ')

  puts "Getting details for chunk: #{joined_for_cli}"
  file = instance_details_file(joined_for_cli)
  maybe_get_data("aws ec2 describe-instance-types --instance-types #{joined_for_cli} --region #{$region}", file, $force)
  details = read_json_file(file)

  details["InstanceTypes"].each do |deets|
    if deets["CurrentGeneration"]
      rds_instance_class = transform_instance_class_from(deets["InstanceType"], :ec2)
      gib = deets["MemoryInfo"]["SizeInMiB"] / 1_024
      vcpus = deets["VCpuInfo"]["DefaultVCpus"]

      note = if deets["InstanceType"].start_with?("t")
        "Burstable"
      else
        "Memory Optimized"
      end

      $instance_classes[rds_instance_class].merge!({
        RDSInstanceType: rds_instance_class,
        EC2InstanceType: deets["InstanceType"],
        DefaultVCpus: vcpus,
        SizeInGiB: gib,
        Note: note,
        Label: "#{note} #{gib} GiB, #{vcpus} vCPUs (#{rds_instance_class})"
      })
    end
  end
end

## Build params $defs of instance group ids
conf["params"]["$defs"] = {}

engine_version_to_instance_class_group.values.uniq.each do |group_id|
  formatted_instance_classes = $instances_classes_in_group[group_id].
    map {|rds_instance_class| $instance_classes[rds_instance_class]}.
    sort { |a,b| [a[:DefaultVCpus], a[:SizeInGiB]] <=> [b[:DefaultVCpus] , b[:SizeInGiB]]}.
    map {|ic| {"title" => ic[:Label], "const" => ic[:RDSInstanceType]}}

  conf["params"]["$defs"]["instance-class-group-#{group_id}"] = {
    "title" => "Instance Class",
    "type" => "string",
    "oneOf" => formatted_instance_classes
  }
end

## Update massdriver.yaml instance types

# make sure path exists
conf["params"]["properties"]["database"]["dependencies"] ||= {}
conf["params"]["properties"]["database"]["dependencies"]["version"] ||= {}

# clear previous version dependencies
conf["params"]["properties"]["database"]["dependencies"]["version"]["oneOf"] = []

supported_engine_versions.each do |version|
  prev = conf["params"]["properties"]["database"]["dependencies"]["version"]["oneOf"]

  group_id = engine_version_to_instance_class_group[version]
  ref_name = "#/$defs/instance-class-group-#{group_id}"

  updated = prev.push(
    {
      "properties" => {
        "version" => {"const" => version},
        "instance_class" => {
          "$ref" => ref_name
        }
      }
    }
  )

  conf["params"]["properties"]["database"]["dependencies"]["version"]["oneOf"] = updated
end


## Update the file
File.write($mdyaml, conf.to_yaml)
