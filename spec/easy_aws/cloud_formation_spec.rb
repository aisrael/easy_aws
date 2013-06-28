require 'spec_helper'

require 'easy_aws/cloud_formation'

describe EasyAWS::CloudFormation do
  specify { is_a? Module }
  
  describe EasyAWS::CloudFormation::Template do
     
    specify { is_a? Class }
    describe EasyAWS::CloudFormation::Template::DEFAULT_AWS_TEMPLATE_FORMAT_VERSION do
      specify { eq('2010-09-09') }
    end 
    specify { respond_to? :aws_template_format_version }
    specify { respond_to? :description }
    specify { respond_to? :description= }
    
    it 'accepts an initializer hash' do
      template = EasyAWS::CloudFormation::Template.new description: 'This is a test description.'
      expect(template.description).to eq('This is a test description.')
    end
  end
end
