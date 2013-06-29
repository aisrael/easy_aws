require 'spec_helper'
require 'easy_aws/cloud_formation'

describe EasyAWS::CloudFormation::Template do

  specify { respond_to? :name }
  specify { respond_to? :description }
  specify { respond_to? :type }
  specify { respond_to? :default }

end
