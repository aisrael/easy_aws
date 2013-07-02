require 'easy_aws/dsl_block'

module EasyAWS
  module CloudFormation
    class Template
      class Parameter
        include EasyAWS::ParameterizedInitializer

        TYPES = [:string, :number, :list]
        TYPES_MAP = {string: 'String', number: 'Number', list: 'CommaDelimitedList'}

        attr_accessor :name, :type

        FIELDS_MAP = [:description, :default, :no_echo, :allowed_values, :allowed_pattern,
          :min_length, :max_length, :min_value, :max_value, :constraint_description].each_with_object({}) {|s, h|
            attr_accessor s
            h[s] = s.to_s.camelize
        }

        def to_h
          FIELDS_MAP.each_with_object('Type' => TYPES_MAP[type]) do |(method, key), h|
            if v = self.send(method)
              h[key] = v
            end
          end
        end

        class Collection < Array
          def add(name, type, options = {})
            Parameter.new(options.merge({name: name, type: type})).tap { |parameter| push parameter }
          end

          # define helper methods 'string()', 'number()', 'list()'
          Parameter::TYPES.each {|type|
            module_eval <<-EOF
              def #{type}(name, options = {}, &block)
                parameter = add(name, :#{type}, options)
                DSLBlock.eval_using(parameter, block) if block_given?
                parameter
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
