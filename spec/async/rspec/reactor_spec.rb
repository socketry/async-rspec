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

require 'async/rspec/reactor'
require 'async/io/generic'

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
end
