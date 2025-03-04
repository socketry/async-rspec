# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2017-2023, by Samuel Williams.
# Copyright, 2023, by Robin Goos.

require 'async/rspec/reactor'

RSpec.describe Async::RSpec::Reactor do
	context "with shared context", timeout: 1 do
		include_context Async::RSpec::Reactor
		
		# The following fails:
		it "has reactor" do
			expect(reactor).to be_kind_of Async::Reactor
		end
		
		it "doesn't time out" do
			reactor.async do |task|
				expect do
					task.sleep(0.1)
				end.to_not raise_error
			end.wait
		end
		
		# it "times out" do
		# 	reactor.async do |task|
		# 		task.sleep(2)
		# 	end.wait
		# end
		# 
		# it "propagates errors" do
		# 	reactor.async do |task|
		# 		raise "Boom!"
		# 	end.wait
		# end
	end
	
	context "timeouts", timeout: 1 do
		include Async::RSpec::Reactor
		
		it "times out" do
			expect do
				Sync do |task|
					run_in_reactor(task.reactor, 0.05) do |spec_task|
						spec_task.sleep(0.1)
					end
				end
			end.to raise_error(Async::TimeoutError)
		end
		
		it "doesn't time out" do
			expect do
				Sync do |task|
					run_in_reactor(task.reactor, 0.05) do |spec_task|
						spec_task.sleep(0.01)
					end
				end
			end.to_not raise_error
		end
		
		# it "propagates errors" do
		# 	expect do
		# 		run_in_reactor(reactor, 0.05) do
		# 			raise "Boom!"
		# 		end
		# 	end.to raise_error("Boom!")
		# end
	end

	context "rspec metadata", timeout: 1 do
		include_context Async::RSpec::Reactor	

		it "should have access to example metadata" do
			expect(RSpec.current_example).not_to be_nil
			expect(RSpec.current_example.metadata[:described_class]).to eq(Async::RSpec::Reactor)
		end
	end
end
