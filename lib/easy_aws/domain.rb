module EasyAWS
  class Domain
    attr_accessor :name, :hosted_zone_id

    def initialize(params = {})
      self.name = params[:name] if params.key?(:name)
      self.hosted_zone_id = params[:hosted_zone_id] if params.key?(:hosted_zone_id)
    end

    def resource_record_sets(params = {})
      results = route53_client.list_resource_record_sets(hosted_zone_id: hosted_zone_id)[:resource_record_sets]
      if type = params[:type]
        results.select! { |rr| rr[:type] == type }
      end
      results.map { |rr|
        case rr[:type]
        when 'MX'
          ResourceRecordSet::MX.new(rr)
        when 'NS'
          ResourceRecordSet::NS.new(rr)
        when 'SOA'
          ResourceRecordSet::SOA.new(rr)
        when 'TXT'
          ResourceRecordSet::TXT.new(rr)
        when 'CNAME'
          ResourceRecordSet::CNAME.new(rr)
        else
          ResourceRecordSet.new(rr)
        end
      }
    end

    def create_subdomain(params = {})
      raise 'No name specified' unless params.key?(:name)
      raise 'No value given for CNAME' unless params.key?(:value)
      suffix = ".#{self.name}"
      name = params[:name]
      name += suffix unless name.end_with?(suffix)
      value = params[:value]
      value = [value] unless value.is_a?(Array)
      records = value.map do |v|
        {value: v}
      end
      data = {
        hosted_zone_id: self.hosted_zone_id,
        change_batch: {
          comment: "Create #{name} CNAME",
          changes: [
            {
              action: 'CREATE',
              resource_record_set: {
                name: name,
                type: 'CNAME',
                ttl: 300,
                resource_records: records
              }
            }
          ]
        }
      }
      route53_client.change_resource_record_sets(data)
    end

    class ResourceRecordSet
      attr_accessor :name, :type, :ttl, :resource_records
      def initialize(params = {})
        self.name = params[:name]
        self.type = params[:type]
        self.ttl = params[:ttl]
        self.resource_records = params[:resource_records]
      end

      class MX < ResourceRecordSet
        def initialize(params = {})
          super(params.merge({type:'MX'}))
        end
      end

      class NS < ResourceRecordSet
        def initialize(params = {})
          super(params.merge({type:'NS'}))
        end
      end

      class SOA < ResourceRecordSet
        def initialize(params = {})
          super(params.merge({type:'SOA'}))
        end
      end

      class TXT < ResourceRecordSet
        def initialize(params = {})
          super(params.merge({type:'TXT'}))
        end
      end

      class CNAME < ResourceRecordSet
        def initialize(params = {})
          super(params.merge({type:'SOA'}))
        end
      end
    end

    protected

    def route53_client
      @r53 ||= AWS::Route53.new
      @r53.client
    end

  end
end
