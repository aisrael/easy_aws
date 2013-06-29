require 'spec_helper'

require 'easy_aws/cloud_formation'

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
  
  subject { EasyAWS::CloudFormation::Template.new description: 'Test description.' } 
  it 'provides a parameters list' do
    subject.respond_to? :parameters
  end

  describe '#parameters' do
    specify { is_a? EasyAWS::CloudFormation::Template::ParameterCollection }
    it 'accepts a block for defining parameters, and evaluates it in the ParameterCollection context' do
      s = nil
      subject.parameters do
        s = self
        number 'Number parameter'
        string 'String parameter'
      end
      expect(s).to be_a(EasyAWS::CloudFormation::Template::ParameterCollection)
      expect(subject.parameters.size).to eq(2)
    end
  end

  it 'works with a full test' do
    template = EasyAWS::CloudFormation::Template.new do
      description = 'Template description'
      parameters do
        string 'KeyName', description: 'Name of an existing Amazon EC2 KeyPair for SSH access to the Web Server'
      end
    end
  end
end
