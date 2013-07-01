require 'active_support/core_ext' # for Hash#except
require 'easy_aws/dsl_block'

module EasyAWS
  module CloudFormation
    class Template
      class Resource
        attr_accessor :name, :type

        def initialize(params = {})
          @name = params[:name] if params[:name]
          @type = params[:type] if params[:type]
          props = params.except(:name, :type)
          unless props.empty?
            @properties = Properties.new
            @properties.merge!(props)
          end 
        end

        TYPES_MAP = {
          ec2_instance: 'EC2::Instance',
          route53_record_set: 'Route53::RecordSet', 
          sqs_queue: 'SQS::Queue' 
        }.each_with_object({}) {|(k,v), m|
          # save us some repetitive typing 
          m[k] = 'AWS::' + v
        }
        TYPES = TYPES_MAP.keys

        def properties(&block)
          @properties ||= Properties.new
          @properties.instance_eval(&block) if block_given? 
          @properties
        end

        def to_h
          h = { 'Type' => self.type }
          h['Properties'] = @properties.each_with_object({}) {|(k, v), properties|
            key = k.is_a?(Symbol) ? k.to_s.classify : k.to_s 
            properties[key] = v
          } unless @properties.nil? || @properties.empty?
          h
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
            Resource.new(name: name, type: type).tap { |resource|
              resource.properties.merge! props 
              push resource 
            }
          end

          TYPES_MAP.each {|method, type|
            # We can't use define_method because it doesn't support blocks            
            module_eval <<-EOF
              def #{method}(name, options = {}, &block)
                resource = add(name, "#{type}", options)
                DSLBlock.eval_using(resource.properties, block) if block_given?
                resource
              end
            EOF
          }

          def to_h
            each_with_object({}) {|parameter, h| h[parameter.name] = parameter.to_h }
          end
        end
      end
    end
  end
end
