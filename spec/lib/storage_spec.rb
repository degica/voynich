require 'spec_helper'

module Voynich
  describe Storage do
    let(:storage) { Storage.new }
    before do
      stub_kms_request
    end

    describe "#encrypt" do
      it "creates an auto key and a value" do
        uuid = storage.create({foo: "value"})
        expect(uuid).to be_a String
        expect(ActiveRecord::DataKey.last).to be_present
        value = ActiveRecord::Value.find_by(uuid: uuid)
        expect(value.decrypt).to eq({foo: "value"})
      end
    end

    describe "#decrypt" do
      it "decrypts the encrypted data" do
        uuid = Storage.new.create({foo: "value"})
        data = Storage.new.decrypt(uuid)

        expect(data).to eq({foo: "value"})
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
