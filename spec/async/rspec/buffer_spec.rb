# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2023, by Samuel Williams.

require 'async/rspec/buffer'

RSpec.describe Async::RSpec::Buffer do
	include_context Async::RSpec::Buffer
	
	it "behaves like a file" do
		expect(buffer).to be_instance_of(File)
	end
	
	it "should not exist on disk" do
		expect(File).to_not be_exist(buffer.path)
	end
end
