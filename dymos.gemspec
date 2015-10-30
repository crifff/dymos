# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dymos/version'

Gem::Specification.new do |spec|
  spec.name          = "dymos"
  spec.version       = Dymos::VERSION
  spec.authors       = ["hoshina85"]
  spec.email         = ["hoshina85@gmail.com"]
  spec.summary       = %q{aws-sdk-core-ruby dynamodb client wrapper}
  spec.description   = %q{aws-sdk-core-ruby dynamodb client wrapper}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "fake_dynamo"
  spec.add_development_dependency "coveralls"
  spec.add_development_dependency "timecop"

  spec.add_dependency "activemodel", '~> 4.1.5'
  spec.add_dependency "aws-sdk-core"
end
