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

  description 'Cloud Formation template'

  # Define parameters one by one
  parameter 'KeyName', :string, description: 'The key name to use to connect to the instances'

  # Or use a parameters 'block' for some syntatic sugar
  parameters {
    string 'AvailabilityZone', description: 'The availability zone to create instances in'

    # Also accepts a block
    string 'InstanceType' do
      allowed_values %w(t1.micro m1.small m1.medium m1.large)
      description "EC2 instance type (e.g. #{allowed_values.join(', ')})"
      default 't1.micro'
    end
  }

  # You can also add mappings in a mappings {} block
  mapping 'RegionMap', {
    'us-east-1' => { '32' => 'ami-6411e20d'},
    'us-west-1' => { '32' => 'ami-c9c7978c'},
    'eu-west-1' => { '32' => 'ami-37c2f643'},
    'ap-southeast-1' => { '32' => 'ami-66f28c34'},
    'ap-northeast-1' => { '32' => 'ami-9c03a89d'}
  }

  resources {
    ec2_instance 'AppInstance1' do
      availability_zone Ref: 'AvailabilityZone'
      image_id 'ami-d8450c8a'
      instance_type Ref: 'InstanceType'
    end
    load_balancer 'LoadBalancer' do
      availability_zones Ref: 'AvailabilityZone'
      listener 'HTTP', 80, 'HTTP', 80
      instances Ref: 'AppInstance1'
    end
  }
end

# Express the template as JSON
puts template.to_json(:pretty)
