# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2017-2023, by Samuel Williams.

source 'https://rubygems.org'

# Specify your gem's dependencies in async-rspec.gemspec
gemspec

# gem "async", path: "../async"

gem "rugged", "= 1.4.4"

group :maintenance, optional: true do
	gem "bake-modernize"
	gem "bake-gem"
end

group :test do
	gem "bake-test"
	
	gem "ruby-prof", git: "https://github.com/ruby-prof/ruby-prof"
end
