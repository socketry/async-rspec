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

require 'async/rspec/memory'

RSpec.describe Async::RSpec::Memory do
	include_context Async::RSpec::Memory
	
	it "should execute code in block" do
		string = nil
		
		expect do
			string = String.new
		end.to limit_allocations(String => 1)
		
		expect(string).to_not be_nil
	end
	
	context "on supported platform", if: Async::RSpec::Memory::Trace.supported? do
		it "should not exceed specified count limit" do
			expect do
				2.times{String.new}
			end.to limit_allocations(String => 2)
			
			expect do
				2.times{String.new}
			end.to limit_allocations.of(String, count: 2)
		end
		
		it "should fail if there are untracked allocations" do
			expect do
				expect do
					Array.new
				end.to limit_allocations
			end.to raise_error(RSpec::Expectations::ExpectationNotMetError, /it was not specified/)
		end
		
		it "should exceed specified count limit" do
			expect do
				expect do
					6.times{String.new}
				end.to limit_allocations(String => 4)
			end.to raise_error(RSpec::Expectations::ExpectationNotMetError, /expected exactly 4 instances/)
		end if Async::RSpec::Memory::Trace.supported?
		
		it "should be within specified count range" do
			expect do
				2.times{String.new}
			end.to limit_allocations(String => 1..3)

			expect do
				2.times{String.new}
			end.to limit_allocations.of(String, count: 1..3)
		end
		
		it "should exceed specified count range" do
			expect do
				expect do
					6.times{String.new}
				end.to limit_allocations(String => 1..3)
			end.to raise_error(RSpec::Expectations::ExpectationNotMetError, /expected within 1..3 instances/)
		end
		
		it "should not exceed specified size limit" do
			expect do
				"a" * 100_000
			end.to limit_allocations.of(String, size: 100_001)
		end
		
		it "should exceed specified size limit" do
			expect do
				expect do
					"a" * 120_000
				end.to limit_allocations(size: 100_000)
			end.to raise_error(RSpec::Expectations::ExpectationNotMetError, /expected exactly 100000 bytes/)
		end
	end
end
