# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dalli/keys_match/version'

Gem::Specification.new do |spec|
  spec.name          = 'dalli-keys-match'
  spec.version       = Dalli::KeysMatch::VERSION
  spec.authors       = ['Marcos G. Zimmermann']
  spec.email         = ['marcos@marcosz.com.br']
  spec.license       = 'MIT'

  spec.summary       = %q{Dalli::KeysMatch extends Dalli with functions to deal with keys}
  spec.description   = %q{Dalli::KeysMatch extends Dalli with a function that allow you to list or remove keys using optional filters}
  spec.homepage      = 'https://github.com/marcosgz/dalli-keys-match'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'net-telnet', '~> 0.1.1'
  spec.add_runtime_dependency 'dalli', '>= 1.0.0'
  spec.add_development_dependency 'bundler', '~> 1.15'
  spec.add_development_dependency 'rake', '~> 12.1', '>= 12.1.0'
  spec.add_development_dependency 'rspec', '~> 3.6'
end
