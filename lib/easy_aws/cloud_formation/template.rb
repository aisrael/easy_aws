require 'active_support/core_ext'
require 'active_support/concern'
require 'json'

require 'easy_aws/parameterized_initializer'

module EasyAWS::CloudFormation
  class Template
    include EasyAWS::ParameterizedInitializer

    DEFAULT_AWS_TEMPLATE_FORMAT_VERSION = '2010-09-09'

    autoload :Parameter, 'easy_aws/cloud_formation/template/parameter'
    autoload :Mappings, 'easy_aws/cloud_formation/template/mappings'

    attr_reader :aws_template_format_version, :resources, :outputs
    attr_accessor :description

    def initialize(params = {}, &block)
      super
      DSL.new(self).instance_eval(&block) if block_given?
    end

    def parameters(&block)
      @parameters ||= Parameter::Collection.new
      @parameters.instance_eval(&block) if block_given?
      @parameters
    end

    def mappings(&block)
      @mappings ||= Mappings.new
      @mappings.instance_eval(&block) if block_given?
      @mappings
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
      def parameter(name, type, options = {})
        parameters.build(name, type, options)
      end
      def mapping(*args)
        mappings.map(*args)
      end
    end

    def to_h
      {'AWSTemplateFormatVersion' => DEFAULT_AWS_TEMPLATE_FORMAT_VERSION}.tap {|h|
        h['Description'] = @description unless @description.nil?
        h['Parameters'] = @parameters.to_h unless @parameters.nil? || @parameters.empty?
        h['Mappings'] = @mappings.to_h unless @mappings.nil? || @mappings.empty?
      }
    end

    def to_json
      to_h.to_json
    end
  end
end
