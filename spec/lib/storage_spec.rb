require 'spec_helper'

module Voynich
  describe Storage do
    before do
      allow(KMSDataKey).to receive(:new) {
        double(
          plaintext: 'plaintext-data-key-generated-by-amazon-kms',
          ciphertext: 'encrypted-data-key'
        )
      }
    end

    describe "encrypt and decrypt" do
      it "encrypts plaintext and decrypt ciphertext" do
        uuid = Storage.new.create({foo: "plaintext"})
        data = Storage.new.decrypt(uuid)

        expect(data).to eq({foo: "plaintext"})
      end
    end

    describe "#update" do
      it "updates voynich value" do
        uuid = Storage.new.create({foo: "plaintext"})
        Storage.new.update(uuid, {bar: "plaintext2"})
        data = Storage.new.decrypt(uuid)

        expect(data).to eq({bar: "plaintext2"})
      end
    end
  end
end
