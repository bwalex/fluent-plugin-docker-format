# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "fluent-plugin-docker-format"
  spec.version       = File.read("VERSION").strip
  spec.authors       = ["Alex Hornung"]
  spec.email         = ["alex@alexhornung.com"]
  spec.description   = %q{fluentd output filter plugin to parse the docker config.json related to a container log file.}
  spec.summary       = spec.description
  spec.homepage      = "https://github.com/bwalex/fluent-plugin-docker-format"
  spec.license       = "MIT"
  spec.has_rdoc      = false

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake", "~> 10.4.2"
end
