# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'voynich/version'

Gem::Specification.new do |spec|
  spec.name          = "voynich"
  spec.version       = Voynich::VERSION
  spec.authors       = ["Kazunori Kajihiro"]
  spec.email         = ["kkajihiro@degica.com"]

  spec.summary       = "KMS backed secret management library"
  spec.description   = "KMS backed secret management library."
  spec.homepage      = "https://github.com/degica/voynich"
  spec.licenses      = ['MIT']

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.4"
  spec.add_dependency "aws-sdk-kms", "~> 1.36"
  spec.add_dependency "activesupport", ">= 4.2"
  spec.add_dependency "activerecord", ">= 4.2"
  spec.add_dependency "libxml-ruby"
end
