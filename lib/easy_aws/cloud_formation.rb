module EasyAWS
  module CloudFormation  
    autoload :Template, 'easy_aws/cloud_formation/template'

    class << self
      def template(params = {}, &block)
        Template.new(params, &block)
      end
    end
  end
end
