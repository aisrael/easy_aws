require 'spec_helper'

require 'uuid'
require 'time'

HOSTED_ZONE_ID = 'Z5EMV0UQ55K3F'

describe EasyAWS::Domain do

  subject {
    EasyAWS::Domain.new name: 'example.com', hosted_zone_id: HOSTED_ZONE_ID
  }

  it 'has an attribute name' do
    subject.should respond_to(:name)
    subject.name.should eq('example.com')
  end
  it 'has an attribute hosted_zone_id' do
    subject.should respond_to(:hosted_zone_id)
    subject.hosted_zone_id.should eq(HOSTED_ZONE_ID)
  end

  let(:client) { subject.send(:route53_client) }
  
  describe '#create_hosted_zone' do
    subject {
      EasyAWS::Domain.new name: 'example.com'
    }
    it 'raises an error if a hosted_zone_id is already present' do
      subject.hosted_zone_id = HOSTED_ZONE_ID
      expect {
        subject.create_hosted_zone
      }.to raise_error("hosted_zone_id already specified: #{HOSTED_ZONE_ID}")
    end
    it 'returns the newly created hosted zone id' do
      id  = rand(36**13).to_s(36).upcase
      ref = UUID.new.generate

      client.stub(:create_hosted_zone).with(name: 'example.com', caller_reference: ref).and_return({
        :hosted_zone => {
          :id => "/hosted_zone/#{id}",
          :name => 'example.com',
          :caller_reference => ref,
          :resource_record_set_count => 2
        },
        :change_info => {
          :id => rand(36**13).to_s(36).upcase,
          :status => 'PENDING',
          :submitted_at => Time.now.utc
        },
        :delegation_set => {
          :name_servers => %w(ns-1094.awsdns-08.org ns-955.awsdns-55.net ns-1716.awsdns-22.co.uk ns-273.awsdns-34.com)
        }
      })
      result = subject.create_hosted_zone :caller_reference => ref
      result.should eq("/hosted_zone/#{id}")
    end
  end

  describe '#resource_record_sets' do
    before(:each) do
      client.stub(:list_resource_record_sets).with(hosted_zone_id: HOSTED_ZONE_ID).and_return({
        :resource_record_sets=>[
          {:name=>"example.com.", :type=>"MX", :ttl=>3600, :resource_records=>[{:value=>"1 ASPMX.L.GOOGLE.COM."}, {:value=>"5 ALT1.ASPMX.L.GOOGLE.COM."}, {:value=>"5 ALT2.ASPMX.L.GOOGLE.COM."}, {:value=>"10 ASPMX2.GOOGLEMAIL.COM."}, {:value=>"10 ASPMX3.GOOGLEMAIL.COM."}]},
          {:name=>"example.com.", :type=>"NS", :ttl=>172800, :resource_records=>[{:value=>"ns-1018.awsdns-63.net."}, {:value=>"ns-1645.awsdns-13.co.uk."}, {:value=>"ns-1384.awsdns-45.org."}, {:value=>"ns-156.awsdns-19.com."}]},
          {:name=>"example.com.", :type=>"SOA", :ttl=>900, :resource_records=>[{:value=>"ns-1018.awsdns-63.net. awsdns-hostmaster.amazon.com. 1 7200 900 1209600 86400"}]},
          {:name=>"example.com.", :type=>"TXT", :ttl=>86400, :resource_records=>[{:value=>"\"google-site-verification=dO9Xtma4XjWm-QRdkMBQMcJdnwPOiux_lIE1kXSaRMY\""}]},
          {:name=>"www.example.com.", :type=>"CNAME", :ttl=>300, :resource_records=>[{:value=>"ec2-23-22-206-201.compute-1.amazonaws.com"}]},
          {:name=>"mail.example.com.", :type=>"CNAME", :ttl=>3600, :resource_records=>[{:value=>"ghs.googlehosted.com"}]}
        ], 
        :is_truncated=>false, 
        :max_items=>100
      })
    end
    it 'returns an Array of resource record sets' do
      rrs = subject.resource_record_sets
      rrs.should_not be_nil
      rrs.count.should eq(6)
      rrs.each {|rr| rr.should be_a(EasyAWS::Domain::ResourceRecordSet)}
    end
    it 'accepts can filter by type' do
      rrs = subject.resource_record_sets type: 'CNAME'
      rrs.count.should eq(2)
    end
  end

  describe '#create_subdomain' do
    it 'works!' do
      request = {
        hosted_zone_id: HOSTED_ZONE_ID,
        change_batch: {
          comment: 'Create test.example.com CNAME',
          changes: [
            {
              action: 'CREATE',
              resource_record_set: {
                name: 'test.example.com',
                type: 'CNAME',
                ttl: 300,
                resource_records: [
                  {value: 'www.example.com'}
                ] 
              }
            }
          ]
        }
      }
      response = {
        :change_info=>{
          :id=>'/change/C3J2ANQZTMF3QM', 
          :status=>'PENDING', 
          :submitted_at=>Time.parse('2013-01-14 11:14:23 UTC'), 
          :comment=>'Create test.example.com CNAME'
        }
      }
      client.should_receive(:change_resource_record_sets).with(request).and_return(response)

      result = subject.create_subdomain name: 'test', value: 'www.example.com'
      result.should be_a(EasyAWS::Domain::ChangeInfo)
    end
  end
  
  describe EasyAWS::Domain::ChangeInfo do
    SUBMIT_TIME = Time.parse('2013-01-14 11:14:23 UTC')
    CHANGE_INFO_HASH = { :id => '/change/C3J2ANQZTMF3QM', 
        :status =>'PENDING', 
        :submitted_at => SUBMIT_TIME, 
        :comment => 'Create test.example.com CNAME' }
    it 'accepts a hash initializer' do
      change_info = EasyAWS::Domain::ChangeInfo.new CHANGE_INFO_HASH
      change_info.id.should eq('/change/C3J2ANQZTMF3QM')
      change_info.status.should eq('PENDING')
      change_info.submitted_at.should eq(SUBMIT_TIME)
      change_info.comment.should eq('Create test.example.com CNAME')
    end
    describe '.from_response' do
      it 'extracts the :change_info from the response hash' do
        change_info = EasyAWS::Domain::ChangeInfo.from_response :change_info => CHANGE_INFO_HASH
        change_info.id.should eq('/change/C3J2ANQZTMF3QM')
        change_info.status.should eq('PENDING')
        change_info.submitted_at.should eq(SUBMIT_TIME)
        change_info.comment.should eq('Create test.example.com CNAME')
      end
    end
  end

  describe 'Integration Test', :integration => true do

    DEFAULT_WAIT_UNTIL = 1.minute

    def wait_until_in_sync(domain, &block)
      ci = block.call
      timeout = Time.now + DEFAULT_WAIT_UNTIL
      while ci.pending? && Time.new < timeout
        ci = domain.get_change(ci.id)
        return ci if ci.in_sync?
      end
      return nil
    end

    it 'works' do
      domain_name = load_config['domain_name'] || fail("No domain name configured in config.yml")
      domain = EasyAWS::Domain.new name: domain_name
      ci = wait_until_in_sync(domain) { domain.create_hosted_zone }
      fail 'create_subdomain timed out' unless ci

      domain.resource_record_sets.count.should eq(2)

      expect {
        ci = wait_until_in_sync(domain) { domain.create_subdomain name: 'test' }
        fail 'create_subdomain timed out' unless ci
      }.to change {domain.resource_record_sets.count}.by(1)

      begin
      ensure
        ci = wait_until_in_sync(domain) { domain.delete_hosted_zone }
        fail 'delete_hosted_zone timed out' unless ci
      end
    end
  end
end
