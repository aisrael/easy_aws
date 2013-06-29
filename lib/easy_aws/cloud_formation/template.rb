require 'active_support/concern'

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

    def initialize(params = {})
      super
      [:mappings, :resources, :outputs].each {|s| self.instance_variable_set("@#{s}", [])}
    end

    def parameters(&block)
      @parameters ||= ParameterCollection.new
      @parameters.instance_eval(&block) if block_given?
      @parameters
    end
    
    class Parameter
      include ParameterizedInitializer
      TYPES = [:string, :number, :list]
      attr_accessor :name, :type, :default
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
    end

    class Builder
      def initialize(params = {})
        params.each {|k, v| self.instance_variable_set("@#{k}", v)}
      end
      def build
        Template.new.tap {|template|
          template.description = @description unless @description.nil?
        }
      end
      def method_missing(field, value)
        instance_variable_set("@#{field}", value)
      end
    end
  end
end
