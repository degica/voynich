module Voynich
  module ActiveRecord
    class DataKey < ::ActiveRecord::Base
      self.table_name_prefix = 'voynich_'

      has_many :values, class_name: "Voynich::ActiveRecord::Value"

      validates :name, presence: true, uniqueness: true
      validates :cmk_id, presence: true
      validates :ciphertext, presence: true

      before_validation :generate_data_key, if: -> (m) { m.ciphertext.nil? }

      def generate_data_key
        self.ciphertext = data_key.ciphertext
      end

      def data_key
        @data_key ||= KMSDataKeyClient.new(cmk_id: cmk_id, ciphertext: ciphertext)
      end

      def plaintext
        data_key.plaintext
      end

      def reencrypt!
        self.ciphertext = data_key.reencrypt
        save!
      end
    end
  end
end
