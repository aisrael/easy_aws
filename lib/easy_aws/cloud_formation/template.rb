require 'active_support/core_ext'
require 'active_support/concern'

require 'json'

module ParameterizedInitializer extend ActiveSupport::Concern
  def initialize(params = {})
    params.each {|k, v|
      setter = "#{k}=".intern 
      self.send(setter, v) if self.respond_to?(setter)
    }
  end
end

module EasyAWS::CloudFormation
  class Template
    include ParameterizedInitializer
    DEFAULT_AWS_TEMPLATE_FORMAT_VERSION = '2010-09-09'

    attr_reader :aws_template_format_version, :mappings, :resources, :outputs
    attr_accessor :description

    def initialize(params = {}, &block)
      super
      [:mappings, :resources, :outputs].each {|s| self.instance_variable_set("@#{s}", [])}
      DSL.new(self).instance_eval(&block) if block_given?
    end

    def parameters(&block)
      @parameters ||= ParameterCollection.new
      @parameters.instance_eval(&block) if block_given?
      @parameters
    end

    class Parameter
      include ParameterizedInitializer
      TYPES = [:string, :number, :list]
      TYPES_MAP = {string: 'String', number: 'Number', list: 'CommaDelimitedList'}

      attr_accessor :name, :type 

      FIELDS_MAP = [:description, :default, :no_echo, :allowed_values, :allowed_pattern, 
        :min_length, :max_length, :min_value, :max_value, :constraint_description].each_with_object({}) {|s, h|
          attr_accessor s 
          h[s] = s.to_s.classify 
      }

      def to_h
        FIELDS_MAP.each_with_object('Type' => TYPES_MAP[type]) do |(method, key), h|
          if v = self.send(method)
            h[key] = v
          end
        end
      end
    end

    class ParameterCollection < Array
      def build(options = {})
        Parameter.new(options).tap { |parameter| push parameter }
      end
      Parameter::TYPES.each {|type|
        define_method type do |name, options = {}|
          build(options.merge(name: name, type: type))
        end
      }
      def to_h
        each_with_object({}) {|parameter, h| h[parameter.name] = parameter.to_h }
      end
    end

    require 'delegate'

    class DSL < DelegateClass(Template)
      attr_accessor :template
      def initialize(template)
        super(@template = template)
      end
      def description(description)
        @template.description = description
      end
    end

    def to_h
      {'AWSTemplateFormatVersion' => DEFAULT_AWS_TEMPLATE_FORMAT_VERSION}.tap {|h|
        h['Description'] = @description unless @description.nil?
        h['Parameters'] = @parameters.to_h unless @parameters.nil? || @parameters.empty?
      }
    end

    def to_json
      to_h.to_json
    end
  end
end
