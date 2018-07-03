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

RSpec.describe "memory context" do
	include_context Async::RSpec::Memory
	
	if Async::RSpec::Memory::Trace.supported?
		# The following fails:
		it "should exceed specified count limit", pending: 'it should fail' do
			expect do
				6.times{String.new}
			end.to limit_allocations(String => 4)
		end
	end
	
	it "should not exceed specified count limit" do
		expect do
			2.times{String.new}
		end.to limit_allocations(String => 4)
	end
	
	it "should be within specified count range" do
		expect do
			2.times{String.new}
		end.to limit_allocations(String => 1..3)
	end
	
	it "should not exceed specified size limit" do
		expect do
			"a" * 100_000
		end.to limit_allocations(size: 101_000)
	end
end
