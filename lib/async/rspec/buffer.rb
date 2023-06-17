# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2023, by Samuel Williams.

require 'securerandom'

module Async
	module RSpec
		module Buffer
			TMP = "/tmp"
			
			def self.open(mode = 'w+', root: TMP)
				path = File.join(root, SecureRandom.hex(32))
				file = File.open(path, mode)
				
				File.unlink(path)
				
				return file unless block_given?
				
				begin
					yield file
				ensure
					file.close
				end
			end
		end
		
		::RSpec.shared_context Buffer do
			let(:buffer) {Buffer.open}
			after(:each) {buffer.close}
		end
	end
end
