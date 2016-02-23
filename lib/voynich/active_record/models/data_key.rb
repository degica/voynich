module Voynich
  module ActiveRecord
    class DataKey < ::ActiveRecord::Base
      self.table_name_prefix = 'voynich_'

      attr_writer :plaintext

      has_many :values, class_name: "Voynich::ActiveRecord::Value"

      validates :name, presence: true, uniqueness: true
      validates :cmk_id, presence: true
      validates :ciphertext, presence: true

      before_validation :generate_data_key, if: -> (m) { m.ciphertext.nil? }

      def reencrypt!
        result = client.reencrypt(ciphertext)
        self.ciphertext = result.ciphertext
        save!
      end

      def plaintext
        return @plaintext unless @plaintext.nil?
        if ciphertext.nil?
          generate_data_key
        else
          decrypt_data_key
        end
        @plaintext
      end

      private

      def client
        KMSDataKeyClient.new(cmk_id)
      end

      def generate_data_key
        result = client.generate
        self.ciphertext = result.ciphertext
        self.plaintext  = result.plaintext
      end

      def decrypt_data_key
        result = client.decrypt(ciphertext)
        self.ciphertext = result.ciphertext
        self.plaintext  = result.plaintext
      end
    end
  end
end
