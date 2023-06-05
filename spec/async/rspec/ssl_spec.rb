# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2020, by Samuel Williams.

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
