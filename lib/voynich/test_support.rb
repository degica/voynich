require 'securerandom'

module Voynich
  module TestSupport
    module StubKMS
      def stub_kms_request
        secret = SecureRandom.random_bytes(32)
        allow(Voynich).to receive(:kms_client) do
          client = Aws::KMS::Client.new(stub_responses: true)
          client.stub_responses(:generate_data_key,
                                plaintext: secret,
                                ciphertext_blob: 'generated ciphertext blob')
          client.stub_responses(:decrypt, plaintext: secret)
          client.stub_responses(:re_encrypt, ciphertext_blob: 'reencrypted ciphertext blob')
          client
        end
      end
    end
  end
end
