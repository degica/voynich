require 'securerandom'

module Voynich
  module ActiveRecord
    class Value < ::ActiveRecord::Base
      self.table_name_prefix = 'voynich_'

      attr_accessor :plain_value, :context

      belongs_to :data_key, required: true, class_name: "Voynich::ActiveRecord::DataKey"

      validates :uuid, presence: true, uniqueness: true
      validates :ciphertext, presence: true

      before_validation :generate_uuid, on: :create
      before_validation :find_or_create_data_key
      before_validation :encrypt

      def decrypt
        encrypted_data = JSON.parse(self.ciphertext, symbolize_names: true)
        @plain_value = AES.new(data_key.plaintext, (context || {}).to_json).decrypt(
          encrypted_data[:c],
          iv: encrypted_data[:iv],
          tag: encrypted_data[:t]
        )
      end

      def encrypt
        return if plain_value.nil?
        encrypted = AES.new(data_key.plaintext, (context || {}).to_json).encrypt(plain_value)
        self.ciphertext = {
          c:  encrypted[:content],
          t:  encrypted[:tag],
          iv: encrypted[:iv],
          ad: encrypted[:auth_data]
        }.to_json
      end

      private

      def find_or_create_data_key
        if data_key.nil?
          self.data_key = DataKey.find_or_create_by!(name: random_key_name, cmk_id: Voynich.kms_cmk_id)
        end
      end

      def random_key_name
        "auto:#{Random.rand(Voynich.auto_data_key_count)}"
      end

      def generate_uuid
        self.uuid ||= SecureRandom.uuid
      end
    end
  end
end
