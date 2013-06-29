module EasyAWS
  module CloudFormation  
    autoload :Template, 'easy_aws/cloud_formation/template'
    
    class << self
      def template(params = {}, &block)
        Template::Builder.new(params).tap {|builder|
          builder.instance_eval(&block) if block_given?
        }.build
      end
    end
  end
end
