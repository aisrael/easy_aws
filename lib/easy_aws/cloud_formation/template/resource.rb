module EasyAWS
  module CloudFormation
    class Template
      class Resource
        include EasyAWS::ParameterizedInitializer

        attr_accessor :name, :type

        def properties(&block)
          @properties ||= Properties.new
          @properties.instance_eval(&block) if block_given?
          @properties
        end

        class Properties < Hash
          def add(name, value)
            store(name, value)
          end 
        end

        # A Resource::Collection provides some convenience methods over a standard Array
        class Collection < Array
          def build(name, type, options = {})
            Parameter.new(options.merge({name: name, type: type})).tap { |parameter| push parameter }
          end

          def to_h
            each_with_object({}) {|parameter, h| h[parameter.name] = parameter.to_h }
          end
        end
      end
    end
  end
end
