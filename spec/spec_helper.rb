require 'easy_aws'
require 'dotenv'
require 'vcr'

Dotenv.load

VCR.configure do |c|
  c.cassette_library_dir = File.expand_path('../../fixtures/cassettes', __FILE__)
  c.hook_into :webmock

  c.filter_sensitive_data('{{AWS_ACCESS_KEY}}') { ENV['AWS_ACCESS_KEY'] }

  c.default_cassette_options = {
    # IF NOT RUNNING IN CI:
    #   If no cassette exists for a spec, VCR will record. Afterwards, VCR will
    #   stop recording for that spec. If new requests are made that are not
    #   matched by anything in the cassette, an error is thrown
    #
    # IF RUNNING IN CI:
    # Test should immediately throw an error if no cassette exists for a
    # given example that needs one.
    record: (ENV['CI'] || ENV['TRAVIS'] ? :none : :once),

    match_requests_on: [:method, :uri, :host, :path, :query],

    # Strict mocking
    # Inspired by: http://myronmars.to/n/dev-blog/2012/06/thoughts-on-mocking
    allow_unused_http_interactions: false,

    # Enable ERB in the cassettes.
    # Reference: http://goo.gl/aPXYk
    erb: true
  }
end

require 'yaml'

SAMPLE_CONFIG = <<END
access_key_id: YOUR_ACCESS_KEY_ID
secret_access_key: YOUR_SECRET_ACCESS_KEY
domain_name: YOUR_DOMAIN_NAME
END

def load_config
  config_file = File.join(File.dirname(__FILE__), 'config.yml')
  unless File.exist?(config_file)
    puts <<END
To run the samples, put your credentials in config.yml as follows:

#{SAMPLE_CONFIG}
END
    exit 1
  end

  config = YAML.load(File.read(config_file))

  unless config.kind_of?(Hash)
    puts <<END
config.yml is formatted incorrectly.  Please use the following format:

#{SAMPLE_CONFIG}
END
    exit 1
  end

  config
end

def config_aws
  load_config.tap {|config| AWS.config(config)}
end

RSpec.configure do |config|
  config.filter_run_excluding :skip => true, :integration => true
  config_aws if config.inclusion_filter[:integration]

  config.before(vcr: true) do |x|
    normalized_class_name = x.class.to_s.sub(/^RSpec::Core::ExampleGroup::/, '').gsub(/Nested_\d+/, 'Nested').split('::')
    example_file_basename = x.example.file_path[%r{./spec/easy_aws/(.*)\.rb}, 1]
    normalized_description = x.example.description.gsub(/\s/, '_')
    cassette_name = File.join([example_file_basename] + normalized_class_name + [normalized_description])

    ::VCR.insert_cassette cassette_name

    AWS.config
  end
  config.after(vcr: true) do
    ::VCR.eject_cassette
  end
end
