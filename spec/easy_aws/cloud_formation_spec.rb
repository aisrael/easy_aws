require 'spec_helper'

require 'easy_aws/cloud_formation'

describe EasyAWS::CloudFormation do
  it { should be_a Module }
  it { should respond_to :template }
  describe '.template' do
    subject { EasyAWS::CloudFormation.template }
    it { should be_a EasyAWS::CloudFormation::Template }
  end
end
