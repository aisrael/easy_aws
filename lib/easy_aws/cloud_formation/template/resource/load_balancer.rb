class EasyAWS::CloudFormation::Template::Resource
  class LoadBalancer < EasyAWS::CloudFormation::Template::Resource
    def listeners
      properties[:listeners] ||= []
    end

    def listener(lb_protocol, lb_port, instance_protocol, instance_port, certificate_id = nil)
      hash = {
        'Protocol' => lb_protocol,
        'LoadBalancerPort' => lb_port,
        'InstanceProtocol' => instance_protocol,
        'InstancePort' => instance_port
      }
      hash['SSLCertificateId'] = certificate_id unless certificate_id.blank?
      listeners << hash
    end

    def availability_zones(*zones)
      if properties.has_key?(:availability_zones)
        properties[:availability_zones].concat!(zones)
      else
        properties.store(:availability_zones, zones)
      end
    end

    def method_missing(method_name, *args)
      if args && args.size == 1
        properties.store(method_name, args.first)
      end
    end
  end
end
