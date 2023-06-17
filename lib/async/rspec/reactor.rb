# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2017-2023, by Samuel Williams.
# Copyright, 2023, by Robin Goos.

require_relative 'leaks'

require 'kernel/sync'
require 'kernel/async'
require 'async/reactor'
require 'async/task'

module Async
	module RSpec
		module Reactor
			def notify_failure(exception = $!)
				::RSpec::Support.notify_failure(exception)
			end
			
			def run_in_reactor(reactor, duration = nil)
				result = nil
				timer_task = nil
				
				if duration
					timer_task = reactor.async do |task|
						# Wait for the timeout, at any point this task might be cancelled if the user code completes:
						task.annotate("Timer task duration=#{duration}.")
						task.sleep(duration)
						
						# The timeout expired, so generate an error:
						buffer = StringIO.new
						reactor.print_hierarchy(buffer)
						
						# Raise an error so it is logged:
						raise TimeoutError, "Run time exceeded duration #{duration}s:\n#{buffer.string}"
					end
				end
				
				spec_task = reactor.async do |spec_task|
					spec_task.annotate("running example")
					
					result = yield(spec_task)
					
					# We are finished, so stop the timer task if it was started:
					timer_task&.stop
					
					# Now stop the entire reactor:
					raise Async::Stop
				end
				
				begin
					timer_task&.wait
					spec_task.wait
				ensure
					spec_task.stop
				end
				
				return result
			end
		end
		
		::RSpec.shared_context Reactor do
			include Reactor
			let(:reactor) {@reactor}
			
			# This is fiber local:
			rspec_context = Thread.current[:__rspec]
			
			include_context Async::RSpec::Leaks
			
			around(:each) do |example|
				duration = example.metadata.fetch(:timeout, 60)
				
				begin
					Sync do |task|
						@reactor = task.reactor
						
						task.annotate(self.class)
						
						run_in_reactor(@reactor, duration) do
							Thread.current[:__rspec] = rspec_context
							example.run
						end
					ensure
						@reactor = nil
					end
				end
			end
		end
	end
end
