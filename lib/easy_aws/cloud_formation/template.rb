require 'active_support/core_ext'
require 'active_support/concern'

require 'easy_aws/parameterized_initializer'

module EasyAWS
  module CloudFormation
    class Template
      include EasyAWS::ParameterizedInitializer

      DEFAULT_AWS_TEMPLATE_FORMAT_VERSION = '2010-09-09'

      autoload :DSLBlock, 'easy_aws/cloud_formation/template/dsl_block'
      autoload :Parameter, 'easy_aws/cloud_formation/template/parameter'
      autoload :Mappings, 'easy_aws/cloud_formation/template/mappings'
      autoload :Resource, 'easy_aws/cloud_formation/template/resource'

      module Referrer
        # You can also just use Ref: 'Name' directly
        def ref(to)
          { Ref: to }
        end
      end

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

      def resources(&block)
        @resources ||= Resource::Collection.new
        @resources.instance_eval(&block) if block_given?
        @resources
      end

      require 'delegate'

      # Where the magic inside a Template.new {} block happens
      class DSL < DelegateClass(Template)
        attr_accessor :template
        def initialize(template)
          super(@template = template)
        end
        def description(description)
          @template.description = description
        end
        def parameter(name, type, options = {})
          parameters.add(name, type, options)
        end
        def mapping(*args)
          mappings.map(*args)
        end
      end

      def to_h
        {'AWSTemplateFormatVersion' => DEFAULT_AWS_TEMPLATE_FORMAT_VERSION}.tap {|h|
          h['Description'] = @description unless @description.nil?
          [:parameters, :mappings, :resources].each {|sym|
            v = instance_variable_get("@#{sym}")
            h[sym.to_s.capitalize] = v.to_h unless v.nil? || v.empty?
          }
        }
      end

      def to_json(*args)
        pretty = args.include?(:pretty)
        pretty ? JSON.pretty_generate(to_h) : to_h.to_json
      end
    end
  end
end

# Here we get clever
module Fn
  class << self
    def Base64(s)
      { 'Fn::Base64' => s }
    end
    def FindInMap(map_name, top_level_key, second_level_key)
      { 'Fn::FindInMap' => [ map_name, top_level_key, second_level_key ] }
    end
    def GetAtt(resource_name, attr_name)
      { 'Fn::GetAtt' => [ resource_name, attr_name ] }
    end
    def GetAZs(region)
      { 'Fn::GetAZs' => region }
    end
    def Join(delim, *args)
      { 'Fn::Join' => [ delim, args ] }
    end
    def Select(index, list)
      { 'Fn::Select' => [ index, list ] }
    end
  end
end
