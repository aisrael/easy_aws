require 'spec_helper'

require 'easy_aws/cloud_formation'

describe EasyAWS::CloudFormation::Template::ParameterCollection do
  
  specify { is_a? Array }
  specify { respond_to? :build }
  describe '#build' do
    it 'creates and adds a Parameter' do
      subject.build name: 'Parameter name', type: :string
      expect(subject.size).to eq(1)
      expect(subject.first).to be_a(EasyAWS::CloudFormation::Template::Parameter)
      parameter = subject.first
      expect(parameter.name).to eq('Parameter name')
      expect(parameter.type).to eq(:string)
    end
    it 'returns the newly created Parameter' do
      result = subject.build name: 'Parameter name', type: :string
      expect(result).to be_a(EasyAWS::CloudFormation::Template::Parameter)
      expect(result.name).to eq('Parameter name')
      expect(result.type).to eq(:string)
    end
  end 
  specify { respond_to? :number }
  describe '#number' do
    it 'creates and adds a number Parameter' do
      subject.number 'Numeric parameter'
      expect(subject.size).to eq(1)
      expect(subject.first).to be_a(EasyAWS::CloudFormation::Template::Parameter)
      parameter = subject.first
      expect(parameter.name).to eq('Numeric parameter')
      expect(parameter.type).to eq(:number)
    end
  end
  specify { respond_to? :string }
  describe '#string' do
    it 'creates and adds a string Parameter' do
      subject.string 'String parameter'
      expect(subject.size).to eq(1)
      expect(subject.first).to be_a(EasyAWS::CloudFormation::Template::Parameter)
      parameter = subject.first
      expect(parameter.name).to eq('String parameter')
      expect(parameter.type).to eq(:string)
    end
  end
  specify { respond_to? :list }
  describe '#number' do
    it 'creates and adds a list Parameter' do
      subject.list 'List parameter'
      expect(subject.size).to eq(1)
      expect(subject.first).to be_a(EasyAWS::CloudFormation::Template::Parameter)
      parameter = subject.first
      expect(parameter.name).to eq('List parameter')
      expect(parameter.type).to eq(:list)
    end
  end
end
