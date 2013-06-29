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

    autoload :Parameter, 'easy_aws/cloud_formation/template/parameter'

    attr_reader :aws_template_format_version, :mappings, :resources, :outputs
    attr_accessor :description

    def initialize(params = {}, &block)
      super
      [:mappings, :resources, :outputs].each {|s| self.instance_variable_set("@#{s}", [])}
      DSL.new(self).instance_eval(&block) if block_given?
    end

    def parameters(&block)
      @parameters ||= Parameter::Collection.new
      @parameters.instance_eval(&block) if block_given?
      @parameters
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
