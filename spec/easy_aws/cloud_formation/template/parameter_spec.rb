require 'spec_helper'
require 'easy_aws/cloud_formation'

describe EasyAWS::CloudFormation::Template::Parameter do

  it { should respond_to :name }
  it { should respond_to :description }
  it { should respond_to :type }
  it { should respond_to :default }

end
