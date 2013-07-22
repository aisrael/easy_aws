# A helper module that just makes writing initializers that accept a hash of
# attribute => value pairs easier.

module EasyAWS
  module ParameterizedInitializer extend ActiveSupport::Concern
    def initialize(params = {})
      params.each {|k, v|
        setter = "#{k}=".intern
        self.send(setter, v) if self.respond_to?(setter)
      }
    end
  end
end
