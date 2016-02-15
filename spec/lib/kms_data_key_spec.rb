require 'spec_helper'

module Voynich
  describe KMSDataKey do
    before do
      allow(kms_data_key).to receive(:kms_client) do
        client = Aws::KMS::Client.new(stub_responses: true)
        client.stub_responses(:generate_data_key,
                              plaintext: 'generated plaintext blob',
                              ciphertext_blob: 'generated ciphertext blob')
        client.stub_responses(:decrypt, plaintext: 'decrypted plaintext blob')
        client
      end
    end

    describe "#plaintext" do
      subject { kms_data_key.plaintext }

      context "when cmk_id is passed" do
        let(:kms_data_key) { KMSDataKey.new(cmk_id: "cmk_id") }
        it { is_expected.to eq Base64.strict_encode64('generated plaintext blob') }
      end

      context "when encrypted_data_key is passed" do
        let(:kms_data_key) { KMSDataKey.new(cmk_id: "cmk_id", ciphertext: Base64.strict_encode64('encrypted data key')) }
        it { is_expected.to eq Base64.strict_encode64('decrypted plaintext blob') }
      end
    end

    describe "#encrypted_data_key" do
      subject { kms_data_key.ciphertext }

      context "when encrypted data key is not passed to initializer" do
        let(:kms_data_key) { KMSDataKey.new(cmk_id: "cmk_id") }
        it { is_expected.to eq Base64.strict_encode64('generated ciphertext blob') }
      end

      context "when encrypted data key is passed to initializer" do
        let(:kms_data_key) { KMSDataKey.new(cmk_id: "cmk_id", ciphertext: Base64.strict_encode64('encrypted data key')) }
        it { is_expected.to eq Base64.strict_encode64('encrypted data key') }
      end
    end
  end
end
