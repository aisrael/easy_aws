require 'spec_helper'

require 'easy_aws/cloud_formation'

describe EasyAWS::CloudFormation do
  specify { is_a? Module }
  specify { respond_to? :template }
  describe '.template' do
    subject { EasyAWS::CloudFormation.template }
    specify { is_a? EasyAWS::CloudFormation::Template::Builder }
  end
end
