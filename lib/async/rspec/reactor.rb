# Copyright, 2017, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

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
			
			include_context Async::RSpec::Leaks
			
			around(:each) do |example|
				duration = example.metadata.fetch(:timeout, 10)
				
				begin
					Sync do |task|
						@reactor = task.reactor
						
						task.annotate(self.class)
						
						run_in_reactor(@reactor, duration) do
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
