require 'spec_helper'
require 'easy_aws/cloud_formation'

describe EasyAWS::CloudFormation::Template::Resource do

  it { should respond_to :name }
  it { should respond_to :type }

  describe EasyAWS::CloudFormation::Template::Resource::Collection do

  end
end
