#!/usr/bin/env ruby
#
# To run this from the repository root directory, use ruby -I
#
#    ruby -I ./lib examples/cloud_formation
#

require 'easy_aws/cloud_formation'

include EasyAWS::CloudFormation

# Define a template
template = Template.new do

  description 'apex-shoresuite-com template'

  # Define parameters one by one
  parameter 'KeyName', :string, description: 'The key name to use to connect to the instances'

  # Or use a parameters 'block' for some syntatic sugar
  parameters {
    string 'InstanceType', description: 'The EC2 instance type to use', default: 't1.micro'
  }

  # You can also add mappings in a mappings {} block
  mapping 'RegionMap', {
    "us-east-1" => { "32" => "ami-6411e20d"},
    "us-west-1" => { "32" => "ami-c9c7978c"},
    "eu-west-1" => { "32" => "ami-37c2f643"},
    "ap-southeast-1" => { "32" => "ami-66f28c34"},
    "ap-northeast-1" => { "32" => "ami-9c03a89d"}
  }

  resources {

  }
end

# Express the template as JSON
puts template.to_json(:pretty)
