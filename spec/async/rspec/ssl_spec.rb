# Copyright, 2018, by Samuel G. D. Williams. <http://www.codeotaku.com>
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

require 'async/rspec/ssl'

RSpec.describe Async::RSpec::SSL do
	context Async::RSpec::SSL::CertificateAuthority do
		include_context Async::RSpec::SSL::CertificateAuthority
		
		it "has a valid certificate authority" do
			expect(certificate_authority.verify(certificate_authority_key)).to be_truthy
		end
	end
	
	context Async::RSpec::SSL::ValidCertificate do
		include_context Async::RSpec::SSL::ValidCertificate
		
		it "can validate client certificate" do
			expect(certificate_store.verify(certificate)).to be_truthy
		end
	end

	context Async::RSpec::SSL::InvalidCertificate do
		include_context Async::RSpec::SSL::InvalidCertificate
		
		it "fails to validate certificate" do
			expect(certificate_store.verify(certificate)).to be_falsey
		end
	end
end
