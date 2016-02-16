require 'spec_helper'

module Voynich::ActiveModel
  class Target
    include ::ActiveModel::Model
    def self.before_save(method, options={})
      @@before_save_callbacks[method.to_sym] = options
    end
    @@before_save_callbacks = {}

    def save
      @@before_save_callbacks.each do |method, options|
        send(method)
      end
    end

    def uuid
      @uuid ||= SecureRandom.hex
    end

    include Model

    attr_accessor :voynich_secret_uuid
    attr_accessor :voynich_auth_secret_uuid
    voynich_attribute :secret
    voynich_attribute :auth_secret, context: ->(m) { m.uuid }
  end

  describe Model do
    before do
      stub_kms_request
    end

    describe "saving attributes" do
      let(:target) { Target.new }
      before do
        target.secret = "super secret information"
        expect(target.secret).to eq "super secret information"
      end

      it "stores secret in voynich table" do
        target.save
        expect(Voynich::ActiveRecord::Value.count).to eq 1
        value = Voynich::ActiveRecord::Value.first
        expect(value.decrypt).to eq "super secret information"
        expect(value.data_key).to be_a Voynich::ActiveRecord::DataKey
      end

      it "updates secret" do
        target.save
        target.secret = "yet another secret information"
        expect(target.secret).to eq  "yet another secret information"
        target.save

        expect(Voynich::ActiveRecord::Value.count).to eq 1
        value = Voynich::ActiveRecord::Value.first
        expect(value.decrypt).to eq "yet another secret information"
      end

      it "can decrypt the attribute" do
        target.save

        reloaded_target = Target.new(voynich_secret_uuid: target.voynich_secret_uuid)
        expect(reloaded_target.secret).to eq "super secret information"
      end

      context "with context" do
        it "encrypts secret with context" do
          target.auth_secret = "authenticated secret"
          expect(target.auth_secret).to eq "authenticated secret"
          target.save

          value = Voynich::ActiveRecord::Value.find_by(uuid: target.voynich_auth_secret_uuid)
          value.context = target.uuid
          expect(value.decrypt).to eq "authenticated secret"
        end

        it "updates secret with context" do
          target.auth_secret = "authenticated secret"
          target.save

          target.auth_secret = "yet another authenticated secret"
          target.save

          value = Voynich::ActiveRecord::Value.find_by(uuid: target.voynich_auth_secret_uuid)
          value.context = target.uuid
          expect(value.decrypt).to eq "yet another authenticated secret"
        end
      end
    end
  end
end
