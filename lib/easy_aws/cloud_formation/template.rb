module EasyAWS::CloudFormation
  class Template
    DEFAULT_AWS_TEMPLATE_FORMAT_VERSION = '2010-09-09'

    attr_reader :aws_template_format_version
    attr_accessor :description

    def initialize(params = {})
      params.each {|k, v|
        setter = "#{k}=".intern 
        self.send(setter, v) if self.respond_to?(setter)
      }
    end
  end
end
