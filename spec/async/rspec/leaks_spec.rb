# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2017-2023, by Samuel Williams.

require 'async/rspec/leaks'

RSpec.describe "leaks context" do
	include_context Async::RSpec::Leaks
	
	it "leaks io" do
		expect(before_ios).to be == current_ios
		
		input, output = IO.pipe
		
		expect(before_ios).to_not be == current_ios
		
		input.close
		output.close
		
		expect(before_ios).to be == current_ios
	end
end
