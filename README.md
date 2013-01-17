easy_aws
========

Amazon's Ruby SDK, [aws-sdk-ruby](https://github.com/aws/aws-sdk-ruby) exposes relatively low-level AWS API operations. 
`easy_aws` provides an easier to use, object-oriented wrapper around those.


Route 53
-------

Right now, `easy_aws` only provides a convenience wrapper around AWS Route 53 API for Ruby:

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

Testing
--------
Add `spec/config.yml`, with the following contents
````
access_key_id: YOUR_AWS_ACCESS_KEY_ID
secret_access_key: YOUR_AWS_SECRET_ACCESS_KEY
domain_name: 'example.com'
````

And run the live integration tests (will perform actual Route 53 calls) using `rspec --tag integration`

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
