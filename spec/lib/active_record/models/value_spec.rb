require 'spec_helper'

module Voynich::ActiveRecord
  describe Value do
    let(:data_key) { DataKey.create!(name: 'data_key', cmk_id: Voynich.kms_cmk_id) }

    before do
      allow(Voynich::KMSDataKey).to receive(:new) {
        double(
          plaintext: 'plaintext-data-key-generated-by-amazon-kms',
          ciphertext: 'encrypted-data-key'
        )
      }
    end

    it do
      Value.create!(plain_value: {a: 1}, data_key: data_key, context: {abc: 1})
      v = Value.first
      v.context = {abc: 1}
      expect(v.decrypt).to eq({a: 1})
    end
  end
end
