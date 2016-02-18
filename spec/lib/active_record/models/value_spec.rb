require 'spec_helper'

module Voynich::ActiveRecord
  describe Value do
    let(:data_key) { DataKey.create!(name: 'data_key', cmk_id: Voynich.kms_cmk_id) }

    before do
      stub_kms_request
    end

    describe "callbacks" do
      it "generates random UUID" do
        value = Value.create!(plain_value: {a: 1}, data_key: data_key)
        expect(value).to be_present
      end
    end

    describe "#decrypt" do
      it "decrypts encrypted data" do
        Value.create!(plain_value: {a: 1}, data_key: data_key)
        v = Value.first
        v.decrypt
        expect(v.plain_value).to eq({a: 1})
      end

      context "with context" do
        it "decrypts encrypted data" do
          Value.create!(plain_value: {a: 1}, data_key: data_key, context: {abc: 1})
          v = Value.first
          v.context = {abc: 1}
          v.decrypt
          expect(v.plain_value).to eq({a: 1})
        end

        context "when context doesn't match" do
          it "fails to decrypt" do
            Value.create!(plain_value: {a: 1}, data_key: data_key, context: {abc: 1})
            v = Value.first
            v.context = {abc: 123}
            expect{v.decrypt}.to raise_error OpenSSL::Cipher::CipherError
          end
        end
      end
    end

    describe "#encrypt" do
      it "encrypts plain value" do
        value = Value.new(plain_value: {a: 1}, data_key: data_key)
        value.encrypt
        encrypted = JSON.load(value.ciphertext)
        expect(encrypted["c"]).to be_a String
        expect(encrypted["t"]).to be_a String
        expect(encrypted["iv"]).to be_a String
        expect(encrypted["ad"]).to be_a String
      end
    end
  end
end
