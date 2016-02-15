require 'securerandom'

module Voynich
  module ActiveRecord
    class Value < ::ActiveRecord::Base
      self.table_name_prefix = 'voynich_'

      attr_accessor :plain_value, :context

      belongs_to :data_key, class_name: "Voynich::ActiveRecord::DataKey"

      validates :uuid, presence: true, uniqueness: true
      validates :data_key, presence: true
      validates :ciphertext, presence: true

      before_validation :generate_uuid, on: :create
      before_validation :encrypt

      def generate_uuid
        self.uuid = SecureRandom.uuid
      end

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
    end
  end
end
