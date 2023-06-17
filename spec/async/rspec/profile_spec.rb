# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2017-2023, by Samuel Williams.

require 'async'
require 'async/rspec/profile'

RSpec.describe Async::RSpec::Profile do
	include_context Async::RSpec::Profile
	
	it "profiles the function" do
		Async do |parent|
			Async do |child|
				child.sleep(1)
			end.wait
		end
	end
end
