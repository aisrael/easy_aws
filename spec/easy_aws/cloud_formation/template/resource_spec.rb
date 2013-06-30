require 'spec_helper'
require 'easy_aws/cloud_formation'

describe EasyAWS::CloudFormation::Template::Resource do

  it { should respond_to :name }
  it { should respond_to :type }
  it { should respond_to :properties }

  describe '#properties' do
    it 'returns a Properties object' do
      subject.properties.should be_a(EasyAWS::CloudFormation::Template::Resource::Properties)
    end
    it 'accepts a block' do
      expect {
        subject.properties {
          add 'MyString', 'one-string-value'
        }
      }.to change { subject.properties.size }.by(1)
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

  end

end
