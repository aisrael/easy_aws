module EasyAWS
  module CloudFormation
    class Template
      class Resource
        include EasyAWS::ParameterizedInitializer

        TYPES = [:sqs_queue]
        TYPES_MAP = { 
          sqs_queue: 'AWS::SQS::Queue' 
        }

        attr_accessor :name, :type

        def properties(&block)
          @properties ||= Properties.new
          @properties.instance_eval(&block) if block_given?
          @properties
        end

        def to_h
          h = { 'Type' => type }
        end

        class Properties < Hash
          def add(name, value)
            store(name, value)
          end
        end

        # A Resource::Collection provides some convenience methods over a standard Array
        class Collection < Array
          def add(name, type, options = {})
            Resource.new(options.merge({name: name, type: type})).tap { |parameter| push parameter }
          end

          TYPES_MAP.each {|method, type|
            define_method method do |name, options = {}|
              add(name, type, options)
            end
          }

          def to_h
            each_with_object({}) {|parameter, h| h[parameter.name] = parameter.to_h }
          end
        end
      end
    end
  end
end
