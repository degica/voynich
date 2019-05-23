require 'securerandom'

module Voynich
  module ActiveRecord
    class Value < ::ActiveRecord::Base
      self.table_name_prefix = 'voynich_'

      attr_accessor :plain_value, :context, :serializer

      belongs_to :data_key, required: true, class_name: "Voynich::ActiveRecord::DataKey"

      validates :uuid, presence: true, uniqueness: true
      validates :ciphertext, presence: true

      before_validation :generate_uuid, on: :create
      before_validation :find_or_create_data_key
      before_validation :encrypt

      def decrypt
        self.plain_value = encrypter.decrypt(self.ciphertext)
      end

      def encrypt
        return if plain_value.nil?
        self.ciphertext = encrypter.encrypt(plain_value)
      end

      private

      def encrypter
        @encrypter ||= Encrypter.new(data_key.plaintext, (context || {}).to_json, serializer: serializer)
      end

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
