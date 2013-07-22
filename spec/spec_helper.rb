require 'easy_aws'

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
end
