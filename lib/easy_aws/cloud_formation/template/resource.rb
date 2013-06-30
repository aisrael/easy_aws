module EasyAWS
  module CloudFormation
    class Template
      class Resource
        include EasyAWS::ParameterizedInitializer

        attr_accessor :name, :type

        def properties
          @properties ||= Properties.new
        end

        class Properties < Array
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
