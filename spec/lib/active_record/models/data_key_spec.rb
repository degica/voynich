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

    describe "#rotate!" do
      before do
        allow_any_instance_of(Voynich::KMSDataKeyClient).to receive(:generate) {
          plaintext = SecureRandom.hex
          allow_any_instance_of(Voynich::KMSDataKeyClient).to receive(:decrypt) {
            Voynich::KMSDataKeyClient::Result.new(plaintext, "encoded ciphertext")
          }
          Voynich::KMSDataKeyClient::Result.new(plaintext, "encoded generated ciphertext")
        }
      end

      let!(:value1) { Value.create!(plain_value: "plain1", data_key: data_key) }
      let!(:value2) { Value.create!(plain_value: "plain2", data_key: data_key, context: {uuid: "uuid"}) }

      it "rotates data key and values" do
        old_plaintext = data_key.plaintext
        data_key.rotate!
        expect(data_key.plaintext).to_not eq old_plaintext
        expect(value1.reload.decrypt).to eq "plain1"
        expect(value2.reload.decrypt).to eq "plain2"
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
