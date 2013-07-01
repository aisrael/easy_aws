require 'spec_helper'
require 'easy_aws/cloud_formation'
require 'easy_aws/dsl_block'

describe EasyAWS::CloudFormation::Template::Resource do

  subject { EasyAWS::CloudFormation::Template::Resource.build name: 'ResourceName', type: 'AWS::EC2::Instance' }

  it { should respond_to :name }
  it { should respond_to :type }
  it { should respond_to :properties }

  describe '#properties' do
    it 'returns a Properties object' do
      subject.properties.should be_a(EasyAWS::CloudFormation::Template::Resource::Properties)
    end
    it 'accepts a block' do
      subject.properties {
        add 'MyString', 'one-string-value'
      }
      # expect {
      # }.to change { subject.properties.size }.by(1)
      expect(subject.properties.size).to eq(1)
    end
    it 'can yield the object to the block' do
      expect {
        subject.properties do |h|
          h['MyString'] = 'one-string-value'
        end
      }.to change { subject.properties.size }.by(1)
    end
  end

  describe EasyAWS::CloudFormation::Template::Resource::Properties do
    subject { EasyAWS::CloudFormation::Template::Resource::Properties.new }
    it { should be_a Hash }
    it 'provides a builder' do
      expect {
        subject.add 'MyString', 'one-string-value'
      }.to change { subject.size }.by(1)
      subject.keys.first.should eq('MyString')
      subject.values.first.should eq('one-string-value')
    end
  end

  describe EasyAWS::CloudFormation::Template::Resource::Collection do
    subject { EasyAWS::CloudFormation::Template::Resource::Collection.new }
    it { should be_a Array }
    it { should respond_to :add }
    specify '#add accepts a name and type' do
      expect {
        subject.add 'MyQueue', 'AWS::SQS::Queue'
      }.to change { subject.size }.by(1)
      expect(subject.first.name).to eq('MyQueue')
      expect(subject.first.type).to eq('AWS::SQS::Queue')
    end
    it { should respond_to :sqs_queue }
    describe '#sqs_queue' do
      it 'adds an "AWS:SQS::Queue"' do
        expect {
          subject.sqs_queue 'MyQueue'
        }.to change { subject.size }.by(1)
        expect(subject.first.name).to eq('MyQueue')
        expect(subject.first.type).to eq('AWS::SQS::Queue')
      end
      it 'accepts a block, passing the resource Properties wrapped using a DSLBlock' do
        resource = nil
        block_self = nil
        expect {
          resource = subject.sqs_queue 'MyQueue' do
            block_self = self
            some_property 'SomeValue'
          end
        }.to change { subject.size }.by(1)
        expect(block_self).to be_a(EasyAWS::DSLBlock)
        expect(block_self.target).to be_a(EasyAWS::CloudFormation::Template::Resource::Properties)
        expect(block_self.target).to equal(resource.properties)
        expect(resource.properties.size).to eq(1)
        expect(resource.properties.some_property).to eq('SomeValue')
      end
    end
    
    it { should respond_to :load_balancer }
    describe '#load_balancer' do
      it 'adss an "AWS::ElasticLoadBalancing::LoadBalancer"' do
        resource = subject.load_balancer 'StagingElb'
        expect(subject.size).to eq(1)
        expect(resource).to be_a(EasyAWS::CloudFormation::Template::Resource::LoadBalancer)
        expect(subject.first.name).to eq('StagingElb')
        expect(subject.first.type).to eq('AWS::ElasticLoadBalancing::LoadBalancer')
      end
    end
    
  end

end
