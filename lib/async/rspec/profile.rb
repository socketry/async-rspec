# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2017-2018, by Samuel Williams.

module Async
	module RSpec
		module Profile
		end
		
		begin
			require 'ruby-prof'
			
			::RSpec.shared_context Profile do
				around(:each) do |example|
					profile = RubyProf::Profile.new
					
					begin
						profile.start
						
						example.run
					ensure
						profile.stop
						
						printer = RubyProf::FlatPrinter.new(profile)
						printer.print(STDOUT)
					end
				end
			end
		rescue LoadError
			::RSpec.shared_context Profile do
				before(:all) do
					warn "Profiling not enabled/supported."
				end
			end
		end
	end
end
