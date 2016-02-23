module Voynich
  module SpecSupport
    module StubKMS
      def stub_kms_request
        allow(Voynich).to receive(:kms_client) do
          client = Aws::KMS::Client.new(stub_responses: true)
          client.stub_responses(:generate_data_key,
                                plaintext: 'fourty length encoded plaintext data key',
                                ciphertext_blob: 'generated ciphertext blob')
          client.stub_responses(:decrypt, plaintext: 'fourty length encoded plaintext data key')
          client.stub_responses(:re_encrypt, ciphertext_blob: 'reencrypted ciphertext blob')
          client
        end
      end
    end
  end
end
