# Copyright, 2018, by Samuel G. D. Williams. <http://www.codeotaku.com>
# Copyright, 2018, by Janko Marohnić.
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

require_relative 'trace'

require 'rspec/expectations'

module Async
	module RSpec
		module Memory
			# expect{...}.to allocate < 10.megabytes
			#
			class LimitAllocations
				include ::RSpec::Matchers::Composable
				
				def initialize(allocations = {}, count: nil, size: nil)
					@count = count
					@size = size
					
					@allocations = {}
					@errors = []
					
					allocations.each do |klass, count|
						self.of(klass, count: count)
					end
				end
				
				def supports_block_expectations?
					true
				end
				
				def of(klass, **limits)
					@allocations[klass] = limits
					
					return self
				end
				
				private def check(value, limit)
					case limit
					when Range
						unless limit.include? value
							yield "expected within #{limit}"
						end
					when Integer
						unless value == limit
							yield "expected exactly #{limit}"
						end
					end
				end
				
				def matches?(given_proc)
					return true unless trace = Trace.capture(@allocations.keys, &given_proc)
					
					if @count or @size
						# If the spec specifies a total limit, we have a limit which we can enforce which takes all allocations into account:
						total = trace.total
						
						check(total.count, @count) do |expected|
							@errors << "allocated #{total.count} instances, #{total.size} bytes, #{expected} instances"
						end if @count
						
						check(total.size, @size) do |expected|
							@errors << "allocated #{total.count} instances, #{total.size} bytes, #{expected} bytes"
						end if @size
					else
						# Otherwise unspecified allocations are considered an error:
						trace.ignored.each do |klass, allocation|
							@errors << "allocated #{allocation.count} #{klass} instances, #{allocation.size} bytes, but it was not specified"
						end
					end
					
					trace.allocated.each do |klass, allocation|
						next unless acceptable = @allocations[klass]
						
						check(allocation.count, acceptable[:count]) do |expected|
							@errors << "allocated #{allocation.count} #{klass} instances, #{allocation.size} bytes, #{expected} instances"
						end
						
						check(allocation.size, acceptable[:size]) do |expected|
							@errors << "allocated #{allocation.count} #{klass} instances, #{allocation.size} bytes, #{expected} bytes"
						end
					end
					
					return @errors.empty?
				end
				
				def failure_message
					"exceeded allocation limit: #{@errors.join(', ')}"
				end
			end
			
			def limit_allocations(*args)
				LimitAllocations.new(*args)
			end
		end
	end
end
