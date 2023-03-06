#! /usr/bin/env ruby
require "yaml"

$engine = "aurora-postgresql"
$mdyaml = "massdriver.yaml"
$region = "us-east-1"

major_minor_versions = `aws rds describe-db-engine-versions --engine #{$engine} --query '*[].[EngineVersion]' --output text --region #{$region}`.split("\n").uniq
conf = YAML.load(File.read($mdyaml))

# V 10 doesnt return instance info ... skip it
major_minor_versions.reject! {|v| v =~ /^10/}

conf["params"]["properties"]["database"]["properties"]["version"]["enum"] = major_minor_versions
conf["params"]["properties"]["database"]["properties"]["version"]["default"] = major_minor_versions.last

File.write($mdyaml, conf.to_yaml)
