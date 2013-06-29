require 'spec_helper'
require 'easy_aws/cloud_formation'

describe EasyAWS::CloudFormation::Template::Mappings do

  specify { respond_to? :map }

  specify '#map accepts a mapping name and a hash' do
    subject.map 'RegionMap', {
      'us-east-1' => 'ami-6411e20d',
      'us-west-1' => 'ami-c9c7978c',
      'eu-west-1' => 'ami-37c2f643',
      'ap-southeast-1' => 'ami-66f28c34',
      'ap-northeast-1' => 'ami-9c03a89d'
    }
    map = subject['RegionMap']
    expect(map).to_not be_nil
    expect(map).to be_a(Hash)
    expect(map.size).to eq(5)
    expect(map['ap-southeast-1']).to eq('ami-66f28c34')
  end

  specify '#map accepts a mapping name and a block, and yields the Hash value' do
    subject.map 'RegionMap' do |map|
      map['us-east-1'] = 'ami-6411e20d'
      map['us-west-1'] = 'ami-c9c7978c'
      map['eu-west-1'] = 'ami-37c2f643'
      map['ap-southeast-1'] = 'ami-66f28c34'
      map['ap-northeast-1'] = 'ami-9c03a89d'
    end
    map = subject['RegionMap']
    expect(map).to_not be_nil
    expect(map).to be_a(Hash)
    expect(map.size).to eq(5)
    expect(map['ap-southeast-1']).to eq('ami-66f28c34')
  end

  specify { respond_to? :to_h }
  specify '#to_h returns the Parameter::Collection as a hash' do
    subject.map 'RegionMap', {
      'us-east-1' => 'ami-6411e20d',
      'us-west-1' => 'ami-c9c7978c',
      'eu-west-1' => 'ami-37c2f643',
      'ap-southeast-1' => 'ami-66f28c34',
      'ap-northeast-1' => 'ami-9c03a89d'
    }
    h = subject.to_h
    expect(h).to eq({
      'Mappings' => {
        'RegionMap' => {
          'us-east-1' => 'ami-6411e20d',
          'us-west-1' => 'ami-c9c7978c',
          'eu-west-1' => 'ami-37c2f643',
          'ap-southeast-1' => 'ami-66f28c34',
          'ap-northeast-1' => 'ami-9c03a89d'
        }
      }
    })
  end
end
