require 'spec_helper'

require 'time'

HOSTED_ZONE_ID = 'Z5EMV0UQ55K3F'

describe EasyAWS::Domain do

  before :all do
#    AWS.config access_key_id: AWS_ACCESS_KEY_ID, secret_access_key: AWS_SECRET_ACCESS_KEY
  end

  subject {
    EasyAWS::Domain.new name: 'shoresuite.com', hosted_zone_id: HOSTED_ZONE_ID
  }

  it 'has an attribute name' do
    subject.should respond_to(:name)
    subject.name.should eq('shoresuite.com')
  end
  it 'has an attribute hosted_zone_id' do
    subject.should respond_to(:hosted_zone_id)
    subject.hosted_zone_id.should eq(HOSTED_ZONE_ID)
  end

  let(:client) { subject.send(:route53_client) }

  describe '#resource_record_sets' do
    before(:each) do
      client.stub(:list_resource_record_sets).with(hosted_zone_id: HOSTED_ZONE_ID).and_return({
        :resource_record_sets=>[
          {:name=>"shoresuite.com.", :type=>"MX", :ttl=>3600, :resource_records=>[{:value=>"1 ASPMX.L.GOOGLE.COM."}, {:value=>"5 ALT1.ASPMX.L.GOOGLE.COM."}, {:value=>"5 ALT2.ASPMX.L.GOOGLE.COM."}, {:value=>"10 ASPMX2.GOOGLEMAIL.COM."}, {:value=>"10 ASPMX3.GOOGLEMAIL.COM."}]},
          {:name=>"shoresuite.com.", :type=>"NS", :ttl=>172800, :resource_records=>[{:value=>"ns-1018.awsdns-63.net."}, {:value=>"ns-1645.awsdns-13.co.uk."}, {:value=>"ns-1384.awsdns-45.org."}, {:value=>"ns-156.awsdns-19.com."}]},
          {:name=>"shoresuite.com.", :type=>"SOA", :ttl=>900, :resource_records=>[{:value=>"ns-1018.awsdns-63.net. awsdns-hostmaster.amazon.com. 1 7200 900 1209600 86400"}]},
          {:name=>"shoresuite.com.", :type=>"TXT", :ttl=>86400, :resource_records=>[{:value=>"\"google-site-verification=dO9Xtma4XjWm-QRdkMBQMcJdnwPOiux_lIE1kXSaRMY\""}]},
          {:name=>"cocobeach.shoresuite.com.", :type=>"CNAME", :ttl=>300, :resource_records=>[{:value=>"ec2-23-22-206-201.compute-1.amazonaws.com"}]},
          {:name=>"mail.shoresuite.com.", :type=>"CNAME", :ttl=>3600, :resource_records=>[{:value=>"ghs.googlehosted.com"}]}
        ], 
        :is_truncated=>false, 
        :max_items=>100
      })
    end
    it 'returns an Array of resource record sets' do
      rrs = subject.resource_record_sets
      rrs.should_not be_nil
      rrs.count.should eq(6)
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
          comment: 'Create test.shoresuite.com CNAME',
          changes: [
            {
              action: 'CREATE',
              resource_record_set: {
                name: 'test.shoresuite.com',
                type: 'CNAME',
                ttl: 300,
                resource_records: [
                  {value: 'ec2-23-22-206-201.compute-1.amazonaws.com'}
                ] 
              }
            }
          ]
        }
      }
      response = {
        :change_info=>{
          :id=>"/change/C3J2ANQZTMF3QM", 
          :status=>"PENDING", 
          :submitted_at=>Time.parse('2013-01-14 11:14:23 UTC'), 
          :comment=>"Create admin.shoresuite.com CNAME"
        }
      }
      client.should_receive(:change_resource_record_sets).with(request).and_return(response)

      subject.create_subdomain name: 'test', value: 'ec2-23-22-206-201.compute-1.amazonaws.com'
    end
  end
end
