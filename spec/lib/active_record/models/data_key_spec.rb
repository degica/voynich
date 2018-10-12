require 'spec_helper'

module Voynich::ActiveRecord
  describe DataKey do
    let(:data_key) { DataKey.create!(name: 'data_key', cmk_id: Voynich.kms_cmk_id) }

    before do
      allow_any_instance_of(Voynich::KMSDataKeyClient).to receive(:generate) {
        Voynich::KMSDataKeyClient::Result.new("generated plaintext", "generated ciphertext")
      }
      allow_any_instance_of(Voynich::KMSDataKeyClient).to receive(:decrypt) {
        Voynich::KMSDataKeyClient::Result.new("decrypted plaintext", "ciphertext")
      }
      allow_any_instance_of(Voynich::KMSDataKeyClient).to receive(:reencrypt) {
        Voynich::KMSDataKeyClient::Result.new(nil, "reencrypted ciphertext")
      }
    end

    describe "#reencrypt!" do
      it "re-encrypt and save ciphertext" do
        data_key.reencrypt!
        expect(data_key.ciphertext).to eq Base64.strict_encode64("reencrypted ciphertext")
      end
    end

    describe "#plaintext" do
      subject { data_key.plaintext }

      context "when plaintext exists" do
        before do
          data_key.plaintext = "aaaa"
        end
        it { is_expected.to eq "aaaa" }
      end

      context "when ciphertext doesn't exist" do
        let(:data_key) { DataKey.new(name: 'data_key', cmk_id: Voynich.kms_cmk_id) }
        it { is_expected.to eq "generated plaintext" }
      end

      context "when ciphertext exists" do
        before { data_key }
        it { expect(DataKey.first.plaintext).to eq "decrypted plaintext" }
      end
    end
  end
end
