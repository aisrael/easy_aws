require 'uuid'

module EasyAWS
  class Domain
    attr_accessor :name, :hosted_zone_id

    def initialize(params = {})
      self.name = params[:name] if params.key?(:name)
      self.hosted_zone_id = params[:hosted_zone_id] if params.key?(:hosted_zone_id)
    end

    def create_hosted_zone(params = {})
      raise "hosted_zone_id already specified: #{hosted_zone_id}" unless @hosted_zone_id.nil?
      caller_reference = params[:caller_reference] || UUID.new.generate
      options = {
        name: self.name,
        caller_reference: caller_reference
      }
      puts "create_hosted_zone.options: #{options.inspect}"
      response = route53_client.create_hosted_zone(options)
      puts "create_hosted_zone.response: #{response.inspect}"
      self.hosted_zone_id = response[:hosted_zone][:id]
    end
    
    def delete_hosted_zone
      route53_client.delete_hosted_zone(id: hosted_zone_id)
    end

    def resource_record_sets(params = {})
      fetch_raw_resource_record_sets(params).map { |rr|
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
      raise 'No value given' unless params.key?(:value)
      suffix = ".#{self.name}"
      name = params[:name]
      name += suffix unless name.end_with?(suffix)
      value = params[:value]
      value = [value] unless value.is_a?(Array)
      records = value.map do |v|
        {value: v}
      end
      options = {
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
      route53_client.change_resource_record_sets(options)
    end

    def delete_subdomain(*args)
      params = args.first.is_a?(Hash) ? args.shift : { name: args.first.to_s }

      raise 'No name specified' unless params.key?(:name)

      suffix = ".#{self.name}"
      name = params[:name]
      name += suffix unless name.end_with?(suffix)

      found = fetch_raw_resource_record_sets(type: 'CNAME').find { |h| h[:name] == name + '.' }

      raise "No resource record matching :name => #{name}" unless found

      options = {
        hosted_zone_id: self.hosted_zone_id,
        change_batch: {
          comment: "Delete #{name} CNAME",
          changes: [
            {
              action: 'DELETE',
              resource_record_set: found
            }
          ]
        }
      }
      route53_client.change_resource_record_sets(options)
    end

    def get_change(*args)
      id = if args.is_a?(Hash) && args.key?(:id)
        args[:id]
      else
        args.shift
      end
      route53_client.get_change(id: id)
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

    def fetch_raw_resource_record_sets(params = {})
      results = route53_client.list_resource_record_sets(hosted_zone_id: hosted_zone_id)[:resource_record_sets]
      if type = params[:type]
        results.select! { |rr| rr[:type] == type }
      end
      results
    end

    def route53_client
      @r53 ||= AWS::Route53.new
      @r53.client
    end

  end
end
