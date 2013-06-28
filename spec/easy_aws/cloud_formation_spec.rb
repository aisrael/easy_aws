require 'spec_helper'

require 'easy_aws/cloud_formation'

describe EasyAWS::CloudFormation do
  specify { is_a? Module }
  
  describe EasyAWS::CloudFormation::Template do
    specify { is_a? Class }
  end
end
