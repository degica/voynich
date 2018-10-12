require 'spec_helper'

module Voynich
  describe KMSDataKeyClient do
    let(:kms_data_key_client) { KMSDataKeyClient.new("cmk_id") }

    before do
      allow(Voynich).to receive(:kms_client) do
        client = Aws::KMS::Client.new(stub_responses: true)
        client.stub_responses(:generate_data_key,
                              plaintext: 'generated plaintext blob',
                              ciphertext_blob: 'generated ciphertext blob')
        client.stub_responses(:decrypt, plaintext: 'decrypted plaintext blob')
        client.stub_responses(:re_encrypt, ciphertext_blob: 'reencrypted ciphertext blob')
        client
      end
    end

    def result(plain_blob, cipher_blob)
      described_class::Result.new(plain_blob, cipher_blob)
    end

    describe "#generate" do
      subject { kms_data_key_client.generate }

      it { is_expected.to eq result("generated plaintext blob", "generated ciphertext blob") }
    end

    describe "#decrypt" do
      subject { kms_data_key_client.decrypt("ciphertext blob") }
      it { is_expected.to eq result("decrypted plaintext blob", "ciphertext blob") }
    end

    describe "#reencrypt" do
      subject { kms_data_key_client.reencrypt("old encoded ciphertext") }
      it { is_expected.to eq result(nil, "reencrypted ciphertext blob") }
    end
  end
end
