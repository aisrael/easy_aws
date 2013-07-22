module EasyAWS
  module CloudFormation
    class Template
      class Resource
        class LoadBalancer < Resource
          def listeners
            properties[:listeners] ||= []
          end

          def listener(lb_protocol, lb_port, instance_protocol, instance_port, options = {})
            hash = {
              'Protocol' => lb_protocol,
              'LoadBalancerPort' => lb_port,
              'InstanceProtocol' => instance_protocol,
              'InstancePort' => instance_port
            }
            hash['SSLCertificateId'] = options[:certificate_id] if options.key?(:certificate_id)
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
            else
              super
            end
          end
        end
      end
    end
  end
end
