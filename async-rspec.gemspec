# coding: utf-8
require_relative 'lib/async/rspec/version'

Gem::Specification.new do |spec|
	spec.name          = "async-rspec"
	spec.version       = Async::RSpec::VERSION
	spec.authors       = ["Samuel Williams"]
	spec.email         = ["samuel.williams@oriontransfer.co.nz"]

	spec.summary       = "Helpers for writing specs against the async gem."
	spec.homepage      = "https://github.com/socketry/async-rspec"

	spec.files         = `git ls-files -z`.split("\x0").reject do |f|
		f.match(%r{^(test|spec|features)/})
	end
	
	spec.require_paths = ["lib"]
	
	spec.add_dependency "rspec", "~> 3.0"
	
	# Since we test the shared contexts, we need some bits of async:
	spec.add_development_dependency "async", "~> 1.8"
	
	spec.add_development_dependency "covered"
	spec.add_development_dependency "bundler"
	spec.add_development_dependency "rake", "~> 10.0"
end
