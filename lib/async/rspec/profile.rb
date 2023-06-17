# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2017-2023, by Samuel Williams.

module Async
	module RSpec
		module Profile
		end
		
		::RSpec.shared_context Profile do
			before(:all) do
				warn "Profiling not enabled/supported."
			end
		end
	end
end
