source 'https://rubygems.org'

# Specify your gem's dependencies in async-rspec.gemspec
gemspec

# gem "async", path: "../async"

group :maintenance, optional: true do
	gem "bake-modernize"
	gem "bake-bundler"
end

group :test do
	gem "ruby-prof", git: "https://github.com/ruby-prof/ruby-prof"
end
