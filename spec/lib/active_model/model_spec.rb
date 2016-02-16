require 'spec_helper'

module Voynich::ActiveModel
  class Target
    def self.before_save(method, options={})
      @@before_save_callbacks[method.to_sym] = options
    end
    @@before_save_callbacks = {}

    def save
      @@before_save_callbacks.each do |method, options|
        send(method)
      end
    end

    include Model

    attr_accessor :voynich_secret_uuid
    voynich_attribute :secret
  end

  describe Model do
    before do
      allow(Voynich::KMSDataKey).to receive(:new) {
        double(
          plaintext: 'plaintext-data-key-generated-by-amazon-kms',
          ciphertext: 'encrypted-data-key'
        )
      }
    end

    it "stores secret in voynich table" do
      target = Target.new
      target.secret = "super secret information"
      expect(target.secret).to eq "super secret information"
      target.save

      expect(Voynich::ActiveRecord::Value.count).to eq 1
      value = Voynich::ActiveRecord::Value.first
      expect(value.decrypt).to eq "super secret information"
      expect(value.data_key).to be_a Voynich::ActiveRecord::DataKey
    end

    it "updates secret" do
      target = Target.new
      target.secret = "super secret information"
      target.save

      target.secret = "yet another secret information"
      expect(target.secret).to eq  "yet another secret information"
      target.save

      expect(Voynich::ActiveRecord::Value.count).to eq 1
      value = Voynich::ActiveRecord::Value.first
      expect(value.decrypt).to eq "yet another secret information"
    end
  end
end
