# coding: utf-8
spec = File.expand_path('../spec', __FILE__)
$LOAD_PATH.unshift(spec) unless $LOAD_PATH.include?(spec)

Gem::Specification.new do |spec|
  spec.name          = "end_to_end"
  spec.version       = '0.1'
  spec.authors       = ["Dax"]
  spec.email         = ["d.dax@email.com"]
  spec.summary       = %q{end-to-end test for quotes}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency 'minitest'
  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"

end
