module Voynich
  module ActiveRecord
    class DataKey < ::ActiveRecord::Base
      self.table_name_prefix = 'voynich_'

      has_many :values, class_name: "Voynich::ActiveRecord::Value"

      validates :name, presence: true, uniqueness: true
      validates :cmk_id, presence: true
      validates :ciphertext, presence: true

      before_validation :generate_data_key, if: -> (m) { m.ciphertext.nil? }

      def plaintext
        kms_data_key_client.plaintext
      end

      def reencrypt!
        self.ciphertext = kms_data_key_client.reencrypt
        save!
      end

      private

      def kms_data_key_client
        @kms_data_key_client ||= KMSDataKeyClient.new(cmk_id: cmk_id, ciphertext: ciphertext)
      end

      def generate_data_key
        self.ciphertext = kms_data_key_client.ciphertext
      end
    end
  end
end
