easy_aws
========

Amazon's Ruby SDK, [aws-sdk-ruby](https://github.com/aws/aws-sdk-ruby) exposes relatively low-level AWS API operations. 
`easy_aws` provides an easier to use, object-oriented wrapper around those.


Route 53
-------

Right now, `easy_aws` only provides a convenience wrapper around AWS Route 53 API for Ruby:

    # First, configure AWS SDK as you normally would
    AWS.config access_key_id: ENV['AWS_ACCESS_KEY_ID'], secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
    
    # Then, use EasyAWS convenience classes
    domain = EasyAWS::Domain.new 'example.com'
    domain.create_hosted_zone                               # "/hosted_zone/5IHFJ3DUWGB7G"
    domain.resource_record_sets.count                       # 2
    domain.create_subdomain 'test'                          # {:change_info => { :id => "/change/T04OEV0PSKAYZ", ...
    domain.get_change "/change/T04OEV0PSKAYZ"               # {:change_info => { :status => 'INSYNC', ...
    domain.delete_subdomain 'test'                          # {:change_info => { :id => "/change/P0VV3D3SWM6J7", ...
    domain.delete_hosted_noze                               # {:change_info => { :id => "/change/QZEMEPSV8A6EA", ...

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

