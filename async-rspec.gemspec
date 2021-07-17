
require_relative "lib/async/rspec/version"

Gem::Specification.new do |spec|
	spec.name = "async-rspec"
	spec.version = Async::RSpec::VERSION
	
	spec.summary = "Helpers for writing specs against the async gem."
	spec.authors = ["Samuel Williams"]
	spec.license = "MIT"
	
	spec.homepage = "https://github.com/socketry/async-rspec"
	
	spec.files = Dir.glob('{lib}/**/*', File::FNM_DOTMATCH, base: __dir__)
	
	spec.add_dependency "rspec", "~> 3.0"
	spec.add_dependency "rspec-files", "~> 1.0"
	spec.add_dependency "rspec-memory", "~> 1.0"
	
	spec.add_development_dependency "async"
	spec.add_development_dependency "async-io"
	spec.add_development_dependency "bundler"
	spec.add_development_dependency "covered"
end
