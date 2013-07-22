easy_aws
========

Amazon's Ruby SDK, [aws-sdk-ruby](https://github.com/aws/aws-sdk-ruby) exposes relatively low-level AWS API operations.
`easy_aws` provides an easier to use, object-oriented wrapper around those.


Route 53
-------

`easy_aws` provides a convenience wrapper around AWS Route 53 API for Ruby:

````ruby
# First, configure AWS SDK as you normally would
AWS.config access_key_id: ENV['AWS_ACCESS_KEY_ID'], secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']

# Then, use EasyAWS convenience classes
domain = EasyAWS::Domain.new 'example.com'

# Create a new hosted zone
domain.create_hosted_zone                               # "/hosted_zone/5IHFJ3DUWGB7G"

# Query the record sets
domain.resource_record_sets.count                       # 2
domain.resource_record_sets(type: 'NS').first           # #<EasyAWS::Domain::ResourceRecordSet::NS ...>

# Create a subdomain
domain.create_subdomain name: 'test', value: '10.0.0.1' # {:change_info => { :id => "/change/T04OEV0PSKAYZ", ...
domain.get_change "/change/T04OEV0PSKAYZ"               # {:change_info => { :status => 'INSYNC', ...
domain.resource_record_sets.count                       # 3

# Delete a subdomain
domain.delete_subdomain 'test'                          # {:change_info => { :id => "/change/P0VV3D3SWM6J7", ...

# Delete the hosted zone
domain.delete_hosted_zone                               # {:change_info => { :id => "/change/QZEMEPSV8A6EA", ...
````

CloudFormation
-------

`easy_aws` also provides a convenient DSL for authoring CloudFormation templates:

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


Integration Testing
--------
Add `spec/config.yml`, with the following contents
````
access_key_id: YOUR_AWS_ACCESS_KEY_ID
secret_access_key: YOUR_AWS_SECRET_ACCESS_KEY
domain_name: YOUR_DOMAIN_NAME # e.g. 'example.com'
````

And run the live integration tests (which will perform actual AWS calls, regular AWS charges _will_ apply) with

    rspec --tag integration

Contributing to easy_aws
========

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

Copyright
========

Copyright (c) 2013 Alistair A. Israel. See LICENSE.txt for
further details.

