# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'repro/api/client/version'

Gem::Specification.new do |spec|
  spec.name          = 'repro-api-client'
  spec.version       = Repro::Api::Client::VERSION
  spec.authors       = ['Takafumi Hirata']
  spec.email         = ['takhirata6@gmail.com']

  spec.summary       = 'Repro API client'
  spec.description   = 'Repro API client'
  spec.post_install_message = '!!! v0.2.0 has BREAKING CHANGE. Repro::Api::Client is not a module anymore. !!!'
  spec.homepage      = 'https://github.com/totem3/repro-api-client'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'webmock'
end
