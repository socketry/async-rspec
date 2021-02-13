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

require 'openssl'

module Async
	module RSpec
		module SSL
			module CertificateAuthority
			end
			
			module ValidCertificate
			end
			
			module InvalidCertificate
			end
			
			module VerifiedContexts
			end
			
			module HostCertificates
			end
		end
		
		::RSpec.shared_context SSL::CertificateAuthority do
			# This key size is generally considered insecure, but it's fine for testing.
			let(:certificate_authority_key) {OpenSSL::PKey::RSA.new(2048)}
			let(:certificate_authority_name) {OpenSSL::X509::Name.parse("O=TestCA/CN=localhost")}

			# The certificate authority is used for signing and validating the certificate which is used for communciation:
			let(:certificate_authority) do
				certificate = OpenSSL::X509::Certificate.new
				
				certificate.subject = certificate_authority_name
				# We use the same issuer as the subject, which makes this certificate self-signed:
				certificate.issuer = certificate_authority_name
				
				certificate.public_key = certificate_authority_key.public_key
				
				certificate.serial = 1
				certificate.version = 2
				
				certificate.not_before = Time.now
				certificate.not_after = Time.now + 3600
				
				extension_factory = OpenSSL::X509::ExtensionFactory.new
				extension_factory.subject_certificate = certificate
				extension_factory.issuer_certificate = certificate
				certificate.add_extension extension_factory.create_extension("basicConstraints", "CA:TRUE", true)
				certificate.add_extension extension_factory.create_extension("keyUsage", "keyCertSign, cRLSign", true)
				certificate.add_extension extension_factory.create_extension("subjectKeyIdentifier", "hash")
				certificate.add_extension extension_factory.create_extension("authorityKeyIdentifier", "keyid:always", false)
				
				certificate.sign certificate_authority_key, OpenSSL::Digest::SHA256.new
			end
			
			let(:certificate_store) do
				# The certificate store which is used for validating the server certificate:
				OpenSSL::X509::Store.new.tap do |certificates|
					certificates.add_cert(certificate_authority)
				end
			end
		end
		
		::RSpec.shared_context SSL::ValidCertificate do
			include_context SSL::CertificateAuthority
			
			# The private key to use on the server side:
			let(:key) {OpenSSL::PKey::RSA.new(2048)}
			let(:certificate_name) {OpenSSL::X509::Name.parse("O=Test/CN=localhost")}

			# The certificate used for actual communication:
			let(:certificate) do
				certificate = OpenSSL::X509::Certificate.new
				certificate.subject = certificate_name
				certificate.issuer = certificate_authority.subject
				
				certificate.public_key = key.public_key
				
				certificate.serial = 2
				certificate.version = 2
				
				certificate.not_before = Time.now
				certificate.not_after = Time.now + 3600
				
				extension_factory = OpenSSL::X509::ExtensionFactory.new()
				extension_factory.subject_certificate = certificate
				extension_factory.issuer_certificate = certificate_authority
				certificate.add_extension extension_factory.create_extension("keyUsage", "digitalSignature", true)
				certificate.add_extension extension_factory.create_extension("subjectKeyIdentifier", "hash")
				
				certificate.sign certificate_authority_key, OpenSSL::Digest::SHA256.new
			end
		end
		
		::RSpec.shared_context SSL::HostCertificates do
			include_context SSL::CertificateAuthority
			
			let(:keys) do
				Hash[
					hosts.collect{|name| [name, OpenSSL::PKey::RSA.new(2048)]}
				]
			end
			
			# The certificate used for actual communication:
			let(:certificates) do
				Hash[
					hosts.collect do |name|
						certificate_name = OpenSSL::X509::Name.parse("O=Test/CN=#{name}")
						
						certificate = OpenSSL::X509::Certificate.new
						certificate.subject = certificate_name
						certificate.issuer = certificate_authority.subject
						
						certificate.public_key = keys[name].public_key
						
						certificate.serial = 2
						certificate.version = 2
						
						certificate.not_before = Time.now
						certificate.not_after = Time.now + 3600
						
						extension_factory = OpenSSL::X509::ExtensionFactory.new
						extension_factory.subject_certificate = certificate
						extension_factory.issuer_certificate = certificate_authority
						certificate.add_extension extension_factory.create_extension("keyUsage", "digitalSignature", true)
						certificate.add_extension extension_factory.create_extension("subjectKeyIdentifier", "hash")
						
						certificate.sign certificate_authority_key, OpenSSL::Digest::SHA256.new
						
						[name, certificate]
					end
				]
			end
			
			let(:server_context) do
				OpenSSL::SSL::SSLContext.new.tap do |context|
					context.servername_cb = Proc.new do |socket, name|
						if hosts.include? name
							socket.hostname = name
							
							OpenSSL::SSL::SSLContext.new.tap do |context|
								context.cert = certificates[name]
								context.key = keys[name]
							end
						end
					end
				end
			end
			
			let(:client_context) do
				OpenSSL::SSL::SSLContext.new.tap do |context|
					context.cert_store = certificate_store
					context.verify_mode = OpenSSL::SSL::VERIFY_PEER
				end
			end
		end
		
		::RSpec.shared_context SSL::InvalidCertificate do
			include_context SSL::CertificateAuthority
			
			# The private key to use on the server side:
			let(:key) {OpenSSL::PKey::RSA.new(2048)}
			let(:invalid_key) {OpenSSL::PKey::RSA.new(2048)}
			let(:certificate_name) {OpenSSL::X509::Name.parse("O=Test/CN=localhost")}

			# The certificate used for actual communication:
			let(:certificate) do
				certificate = OpenSSL::X509::Certificate.new
				certificate.subject = certificate_name
				certificate.issuer = certificate_authority.subject
				
				certificate.public_key = key.public_key
				
				certificate.serial = 2
				certificate.version = 2
				
				certificate.not_before = Time.now - 3600
				certificate.not_after = Time.now
				
				extension_factory = OpenSSL::X509::ExtensionFactory.new()
				extension_factory.subject_certificate = certificate
				extension_factory.issuer_certificate = certificate_authority
				certificate.add_extension extension_factory.create_extension("keyUsage", "digitalSignature", true)
				certificate.add_extension extension_factory.create_extension("subjectKeyIdentifier", "hash")
				
				certificate.sign invalid_key, OpenSSL::Digest::SHA256.new
			end
		end
		
		::RSpec.shared_context SSL::VerifiedContexts do
			let(:server_context) do
				OpenSSL::SSL::SSLContext.new.tap do |context|
					context.cert = certificate
					context.key = key
				end
			end

			let(:client_context) do
				OpenSSL::SSL::SSLContext.new.tap do |context|
					context.cert_store = certificate_store
					context.verify_mode = OpenSSL::SSL::VERIFY_PEER
				end
			end
		end
	end
end
