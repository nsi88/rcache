# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rcache/version'

Gem::Specification.new do |spec|
  spec.name          = "rcache"
  spec.version       = Rcache::VERSION
  spec.authors       = ["novikov"]
  spec.email         = ["novikov@inventos.ru"]
  spec.description   = %q{ActiveRecord redis query cache}
  spec.summary       = %q{ActiveRecord redis query cache}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "json"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
