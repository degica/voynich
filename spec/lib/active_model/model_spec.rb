require 'spec_helper'

module Voynich::ActiveModel
  class Target < ::ActiveRecord::Base
    self.table_name_prefix = 'voynich_active_model_'

    include Model

    after_initialize do |t| 
      t.uuid ||= SecureRandom.hex
    end

    voynich_attribute :secret
    voynich_attribute :auth_secret, context: ->(m) { {uuid: m.uuid} }
  end

  describe Model do
    let(:target) { Target.new }

    before do
      stub_kms_request
    end

    describe "instance variable setter and getter" do
      it "is nil if value doesn't exist" do
        expect(target.secret).to be_nil
      end

      it "assigns instance variable" do
        target.secret = "super secret information"
        expect(target.secret).to eq "super secret information"
      end
    end

    describe "saving attributes" do
      context "when secret is nil" do
        it "doesn't create value record" do
          target.save!
          expect(Voynich::ActiveRecord::Value.count).to eq 0
        end
      end

      context "when secret value is assigned" do
        before do
          target.secret = "super secret information"
          target.save!
        end

        it "stores secret in voynich table" do
          expect(Voynich::ActiveRecord::Value.count).to eq 1
          value = Voynich::ActiveRecord::Value.first
          expect(value.decrypt).to eq "super secret information"
          expect(value.data_key).to be_a Voynich::ActiveRecord::DataKey
        end

        it "updates secret" do
          target.secret = "yet another secret information"
          expect(target.secret).to eq  "yet another secret information"
          target.save!

          expect(Voynich::ActiveRecord::Value.count).to eq 1
          value = Voynich::ActiveRecord::Value.first
          expect(value.decrypt).to eq "yet another secret information"
        end

        it "can decrypt the attribute" do
          reloaded_target = Target.find_by!(voynich_secret_value: target.voynich_secret_value)
          expect(reloaded_target.secret).to eq "super secret information"
        end
      end

      context "with context" do
        before do
          target.auth_secret = "authenticated secret"
          target.save!
        end

        it "encrypts secret with context" do
          value = target.voynich_auth_secret_value
          value.context = {uuid: target.uuid}
          expect(value.decrypt).to eq "authenticated secret"
        end

        it "updates secret with context" do
          target.auth_secret = "yet another authenticated secret"
          target.save!

          value = target.voynich_auth_secret_value
          value.context = {uuid: target.uuid}
          expect(value.decrypt).to eq "yet another authenticated secret"
        end

        it "can decrypt the attribute" do
          reloaded_target = Target.find_by!(voynich_secret_value: target.voynich_secret_value)
          expect(reloaded_target.auth_secret).to eq "authenticated secret"
        end
      end
    end
  end
end
