require 'active_support/core_ext' # for Hash#except

module EasyAWS
  module CloudFormation
    class Template
      class Resource
        include Referrer

        autoload :LoadBalancer, 'easy_aws/cloud_formation/template/resource/load_balancer'

        attr_accessor :name, :type

        METHOD_TYPES_MAP = {
          ec2_instance: 'AWS::EC2::Instance',
          load_balancer: ['AWS::ElasticLoadBalancing::LoadBalancer', LoadBalancer],
          route53_record_set: 'AWS::Route53::RecordSet',
          sqs_queue: 'AWS::SQS::Queue'
        }
        TYPES = ['AWS::EC2::Instance',
          'AWS::ElasticLoadBalancing::LoadBalancer',
          'AWS::Route53::RecordSet',
          'AWS::SQS::Queue']

        private_class_method :new

        def Resource.build(params = {})
          name = params[:name]
          type = params[:type]
          raise "Resource name cannot be blank or empty" if name.blank?
          raise "Resource name '#{name}' is non alphanumeric" unless name =~ /^[[:alnum:]]+$/
          raise 'Resource type cannot be black or empty' if type.blank?
          raise "Resource type '#{type}' unknown or not yet handled" unless TYPES.include?(type)
          if arr = METHOD_TYPES_MAP.select {|k, v| v.is_a? Array }.find {|k, (type_name, class_ref)| type_name == type }
            method_name, (type_name, class_ref) = arr
            # At this point, LoadBalancer.new is also private
            LoadBalancer.send(:new, params)
          else
            # We can call new instead of Resource.send(:new, params) since we *are* Resource
            new(params)
          end
        end

        def initialize(params = {})
          @name = params[:name] if params[:name]
          @type = params[:type] if params[:type]
          raise "Resource name cannot be blank or empty" if @name.blank?
          raise "Resource name '#{@name}' is non alphanumeric" unless @name =~ /^[[:alnum:]]+$/
          raise 'Resource type cannot be black or empty' if @type.blank?
          raise "Resource type '#{@type}' unknown or not yet handled" unless TYPES.include?(@type)
          props = params.except(:name, :type)
          unless props.empty?
            @properties = Properties.new
            @properties.merge!(props)
          end
          add_validations_based_on_type
        end

        def properties(&block)
          @properties ||= Properties.new
          @properties.instance_eval(&block) if block_given?
          @properties
        end

        def to_h
          h = { 'Type' => self.type }
          h['Properties'] = camelize_keys(@properties) unless @properties.nil? || @properties.empty?
          h
        end

        def camelize_keys(hash)
          hash.each_with_object({}) {|(k, v), h|
            key = k.is_a?(Symbol) ? k.to_s.camelize : k
            value = v.is_a?(Hash) ? camelize_keys(v) : v
            h[key] = value
          }
        end

        class Properties < Hash
          def add(name, value)
            store(name, value)
          end
          def method_missing(method_name, *args, &block)
            if has_key?(method_name)
              fetch(method_name)
            else
              super
            end
          end
        end

        # A Resource::Collection provides some convenience methods over a standard Array
        class Collection < Array
          def add(name, type, props = {})
            Resource.build(name: name, type: type).tap { |resource|
              resource.properties.merge! props
              push resource
            }
          end

          # Handle this DSL method specifically
          def load_balancer(name, options = {}, &block)
            resource = add(name, 'AWS::ElasticLoadBalancing::LoadBalancer', options)
            resource.instance_eval(&block) if block_given?
            resource
          end

          METHOD_TYPES_MAP.each {|method, v|
            type = [v].flatten.first # short for v.is_a?(Array) ? v[0] : v
            # We can't use define_method because it doesn't support blocks
            unless instance_methods.include?(method)
              module_eval <<-EOF
                def #{method}(name, options = {}, &block)
                  resource = add(name, "#{type}", options)
                  DSLBlock.eval_using(resource.properties, block) if block_given?
                  resource
                end
              EOF
            end
          }

          def to_h
            each_with_object({}) {|parameter, h| h[parameter.name] = parameter.to_h }
          end
        end # Collection

        # Resource
        private

        def validations
          @validations ||= Hash.new
        end

        def validate(property, &block)
          validations[:property] = block
        end

        def add_validations_based_on_type
          case @type
          when 'AWS::ElasticLoadBalancing::LoadBalancer'
            validate :listeners do
              raise "Resource '#{@name}' (AWS::ElasticLoadBalancing::LoadBalancer) Listeners cannot be empty" if listeners.empty?
            end
          end
        end
      end
    end
  end
end
