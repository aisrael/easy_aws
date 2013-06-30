require 'spec_helper'

require 'easy_aws/cloud_formation'

describe EasyAWS::CloudFormation::Template do

  describe 'EasyAWS::CloudFormation::Template::DEFAULT_AWS_TEMPLATE_FORMAT_VERSION' do
    specify { EasyAWS::CloudFormation::Template::DEFAULT_AWS_TEMPLATE_FORMAT_VERSION.should eq('2010-09-09') }
  end 
  it { should respond_to :aws_template_format_version }
  it { should respond_to :description }
  it { should respond_to :description= }

  it 'accepts an initializer hash' do
    template = EasyAWS::CloudFormation::Template.new description: 'This is a test description.'
    expect(template.description).to eq('This is a test description.')
  end

  subject { EasyAWS::CloudFormation::Template.new description: 'Test description.' } 

  it { should respond_to :parameters }
  describe '#parameters' do
    specify { subject.parameters.should be_a EasyAWS::CloudFormation::Template::Parameter::Collection }
    it 'accepts a block for defining parameters, and evaluates it in the Parameter::Collection context' do
      parameters = subject.parameters do
        number 'Number parameter'
        string 'String parameter'
      end
      expect(parameters.size).to eq(2)
      expect(parameters.first.name).to eq('Number parameter')
      expect(parameters.last.name).to eq('String parameter')
    end
  end

  it { should respond_to :mappings }
  describe '#mappings' do
    specify { subject.mappings.should be_a EasyAWS::CloudFormation::Template::Mappings }
    it 'accepts a block' do
      mappings = subject.mappings {
        map 'RegionMap', {
          "us-east-1" => { "32" => "ami-6411e20d"},
          "us-west-1" => { "32" => "ami-c9c7978c"},
          "eu-west-1" => { "32" => "ami-37c2f643"},
          "ap-southeast-1" => { "32" => "ami-66f28c34"},
          "ap-northeast-1" => { "32" => "ami-9c03a89d"}
        }
      }
      expect(mappings.size).to eq(1)
      expect(mappings.keys.first).to eq('RegionMap')
    end
  end
  
  it { should respond_to :resources }
  describe '#resources' do
    specify { subject.resources.should be_a EasyAWS::CloudFormation::Template::Resource::Collection }
    it 'accepts a block' do
      resources = subject.resources {
        
      }
    end
  end

  it 'works with a full test' do
    template = EasyAWS::CloudFormation::Template.new do

      description 'test template' 

      # Define parameters one by one
      parameter 'KeyName', :string, description: 'The key name to use to connect to the instances'

      # Or use a parameters 'block' for some syntatic sugar
      parameters {
        string 'InstanceType', description: 'The EC2 instance type to use', default: 't1.micro'
      }

      # You can also add mappings in a mappings {} block 
      mapping 'RegionMap', {
        "us-east-1" => { "32" => "ami-6411e20d"},
        "us-west-1" => { "32" => "ami-c9c7978c"},
        "eu-west-1" => { "32" => "ami-37c2f643"},
        "ap-southeast-1" => { "32" => "ami-66f28c34"},
        "ap-northeast-1" => { "32" => "ami-9c03a89d"}
      }
    end

    template.to_json(:pretty).should eq <<JSON
{
  "AWSTemplateFormatVersion": "2010-09-09",
  "Description": "test template",
  "Parameters": {
    "KeyName": {
      "Type": "String",
      "Description": "The key name to use to connect to the instances"
    },
    "InstanceType": {
      "Type": "String",
      "Description": "The EC2 instance type to use",
      "Default": "t1.micro"
    }
  },
  "Mappings": {
    "Mappings": {
      "RegionMap": {
        "us-east-1": {
          "32": "ami-6411e20d"
        },
        "us-west-1": {
          "32": "ami-c9c7978c"
        },
        "eu-west-1": {
          "32": "ami-37c2f643"
        },
        "ap-southeast-1": {
          "32": "ami-66f28c34"
        },
        "ap-northeast-1": {
          "32": "ami-9c03a89d"
        }
      }
    }
  }
}
JSON
.chomp # get rid of trailing newline in here document above

  end
end
