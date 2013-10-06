require 'active_support/core_ext' # for Hash#except

module EasyAWS
  module CloudFormation
    class Template
      class Resource
        include Referrer

        # These helpers have to come before the autoload below, otherwise they won't be seen by subclasses  
        class << self

          # Allows us to do:
          #
          #    class LoadBalancer < Resource
          #      array_attr :availability_zones
          #
          # Then to go:
          #
          #    load_balancer 'LoadBalancer' do
          #      availability_zones 'ap-southeast-1a', 'ap-southeast-1b'
          #
          # Or, alternatively
          #
          #    load_balancer 'LoadBalancer' do
          #      availability_zone 'ap-southeast-1a'
          #      availability_zone 'ap-southeast-1b'          
          def array_attr(*names)
            names.each {|name|
              define_method(name) do |*args|
                if properties.key?(name)
                  properties.store(name, properties.fetch(name).concat(args))
                else
                  properties.store(name, args)
                end
              end
              define_method(name.to_s.singularize) do |arg|
                if properties.key?(name)
                  properties.fetch(name) << arg
                else
                  properties.store(name, [arg])
                end
              end
            }
          end
        end

        # auto-autoload 
        Dir[File.expand_path('resource/*.rb', File.dirname(__FILE__))].each {|f|
          basename = File.basename(f).chomp('.rb')
          autoload basename.classify.to_sym, "easy_aws/cloud_formation/template/resource/#{basename}"
        }

        attr_accessor :name, :type

        METHOD_TYPES_MAP = {
          auto_scaling_group: ['AWS::AutoScaling::AutoScalingGroup', AutoScalingGroup],
          launch_config: ['AWS::AutoScaling::LaunchConfiguration', LaunchConfig],
          ec2_instance: 'AWS::EC2::Instance',
          ec2_security_group: 'AWS::EC2::SecurityGroup',
          load_balancer: ['AWS::ElasticLoadBalancing::LoadBalancer', LoadBalancer],
          route53_record_set: 'AWS::Route53::RecordSet',
          sqs_queue: 'AWS::SQS::Queue'
        }
        TYPES = METHOD_TYPES_MAP.map {|k, v|
          [v].flatten.first # short for v.is_a?(Array) ? v[0] : v
        }

        private_class_method :new
        
        class << self

          def build(params = {})
            name = params[:name]
            type = params[:type]
            raise 'Resource name cannot be blank or empty' if name.blank?
            raise "Resource name '#{name}' is non alphanumeric" unless name =~ /^[[:alnum:]]+$/
            raise 'Resource type cannot be black or empty' if type.blank?
            raise "Resource type '#{type}' unknown or not yet handled" unless TYPES.include?(type)
            if arr = METHOD_TYPES_MAP.select {|k, v| v.is_a? Array }.find {|k, (type_name, class_ref)| type_name == type }
              method_name, (type_name, class_ref) = arr
              # At this point, LoadBalancer.new is also private
              class_ref.send(:new, params)
            else
              # We can call new instead of Resource.send(:new, params) since we *are* Resource
              new(params)
            end
          end

        end

        def initialize(params = {})
          @name = params[:name] if params[:name]
          @type = params[:type] if params[:type]
          raise 'Resource name cannot be blank or empty' if @name.blank?
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

        def metadata
          @metadata ||= Metadata.new
        end

        def to_h
          h = { 'Type' => self.type }
          h['Properties'] = camelize_keys(@properties) unless @properties.nil? || @properties.empty?
          h
        end

        def camelize_keys(hash)
          hash.each_with_object({}) {|(k, v), h|
            key = k.is_a?(Symbol) ? k.to_s.camelize : k
            h[key] = case 
            when v.is_a?(Hash)
              camelize_keys(v)
            when v.is_a?(Array)
              v.map {|e| e.is_a?(Hash) ? camelize_keys(e) : e }
            else
              v
            end
          }
        end
        
        def method_missing(method_name, *args, &block)
          if args.size == 1
            properties.store(method_name, args.first)
          elsif block_given?
            DSLBlock.eval_using(properties, block) if block_given?
          else
            super
          end
            
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
          def add(name, type, props = {}, &block)
            Resource.build(name: name, type: type).tap { |resource|
              resource.properties.merge! props
              DSLBlock.eval_using(resource.properties, block) if block_given?
              push resource
            }
          end
          alias_method :resource, :add

          # Handle this DSL method specifically
          def load_balancer(name, options = {}, &block)
            resource = add(name, 'AWS::ElasticLoadBalancing::LoadBalancer', options)
            resource.instance_eval(&block) if block_given?
            resource
          end

          METHOD_TYPES_MAP.each {|method, v|
            unless instance_methods.include?(method)
              if v.is_a?(Array)
                type = [v].flatten.first # short for v.is_a?(Array) ? v[0] : v
                module_eval <<-EOF
                  def #{method}(name, options = {}, &block)
                    resource = add(name, '#{type}', options)
                    resource.instance_eval(&block) if block_given?
                    resource
                  end
                EOF
              else
                type = v
                # We can't use define_method because it doesn't support blocks
                module_eval <<-EOF
                  def #{method}(name, options = {}, &block)
                    resource = add(name, '#{type}', options)
                    DSLBlock.eval_using(resource.properties, block) if block_given?
                    resource
                  end
                EOF
              end
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
