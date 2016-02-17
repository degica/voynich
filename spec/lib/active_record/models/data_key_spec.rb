require 'spec_helper'

module Voynich::ActiveRecord
  describe DataKey do
    before do
      allow_any_instance_of(Voynich::KMSDataKeyClient).to receive(:plaintext) {
        'plaintext-data-key-generated-by-amazon-kms'
      }
      allow_any_instance_of(Voynich::KMSDataKeyClient).to receive(:ciphertext) {
        "encrypted-data-key"
      }
      allow_any_instance_of(Voynich::KMSDataKeyClient).to receive(:reencrypt) {
        "encrypted-data-key-new"
      }
    end

    describe "#reencrypt!" do
      let(:data_key) { DataKey.create!(name: 'data_key', cmk_id: Voynich.kms_cmk_id) }

      it "re-encrypt and save ciphertext" do
        data_key.reencrypt!
        expect(data_key.ciphertext).to eq "encrypted-data-key-new"
      end
    end
  end
end
