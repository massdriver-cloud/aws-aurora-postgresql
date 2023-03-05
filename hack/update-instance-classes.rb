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
maybe_get_data("aws rds describe-db-engine-versions --engine #{$engine} --region #{$region}", $engines_file, $force) 
engines = read_json_file($engines_file)

versions = engines["DBEngineVersions"]
supported_engine_versions = []
supported_engine_versions_to_instance_class_map = {}

versions.each do |v|
  next if v["EngineVersion"] == "10.21" # why does this one fail?
  supported_engine_versions.push v["EngineVersion"]
end


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
        Label: "#{note} #{vcpus} vCPUs, #{gib} GiB (#{rds_instance_class})"
      })
    end
  end
end


## Update massdriver.yaml instance types

conf["params"]["properties"]["database"]["dependencies"] ||= {}
conf["params"]["properties"]["database"]["dependencies"]["version"] ||= {}
conf["params"]["properties"]["database"]["dependencies"]["version"]["oneOf"] ||= []

supported_engine_versions.each do |version|
  prev = conf["params"]["properties"]["database"]["dependencies"]["version"]["oneOf"]
  instance_classes_with_details = supported_engine_versions_to_instance_class_map[version].map {|v| $instance_classes[v]}

  sorted_instance_classes_with_details = instance_classes_with_details.sort { |a,b| 
    [a[:DefaultVCpus], a[:SizeInGiB]] <=> [b[:DefaultVCpus] , b[:SizeInGiB]]
  }

  formatted_instance_classes = sorted_instance_classes_with_details.map {|ic| {"title" => ic[:Label], "const" => ic[:RDSInstanceType]}}

  updated = prev.push(
    {
      "properties" => {
        "version" => {"const" => version},
        "instance_class" => {
          "type" => "string",
          "oneOf" => formatted_instance_classes
        }
      }
    }
  )
  conf["params"]["properties"]["database"]["dependencies"]["version"]["oneOf"] = updated
end

puts conf.to_yaml

# ## Update the file
# File.write($mdyaml, conf.to_yaml)
