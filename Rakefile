# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts 'Run `bundle install` to install missing gems'
  exit e.status_code
end
require 'rake'

require 'jeweler'
require './lib/easy_aws/version.rb'

Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = 'easy_aws'
  gem.version = EasyAWS::Version::STRING
  gem.homepage = 'http://github.com/AlistairIsrael/easy_aws'
  gem.license = 'MIT'
  gem.summary = %Q{A Ruby gem that provides a convenient, object-oriented wrapper around the 'low-level' aws-sdk API}
  gem.description = %Q{Amazon's Ruby SDK, aws-sdk exposes relatively low-level AWS API operations. easy_aws provides an easier to use, object-oriented wrapper around those.}
  gem.email = 'aisrael@gmail.com'
  gem.authors = ['Alistair A. Israel']

  gem.files = `git ls-files`.split("\n").reject {|s| File.basename(s).chars.first == '.' }
  gem.test_files = `git ls-files -- {test,spec}/*`.split("\n")
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

# Replace with simplecov
# require 'rcov/rcovtask'
# Rcov::RcovTask.new do |test|
  # test.libs << 'test'
  # test.pattern = 'test/**/test_*.rb'
  # test.verbose = true
  # test.rcov_opts << '--exclude "gems/*"'
# end

task :default => :test

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ''

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "easy_aws #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
