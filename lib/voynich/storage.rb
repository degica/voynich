require 'voynich'

module Voynich
  class Storage
    def initialize
    end

    def create(plain_value, key_name: nil, context: {})
      data_key = fetch_data_key(key_name) unless key_name.nil?
      value = ActiveRecord::Value.create!(plain_value: plain_value, data_key: data_key, context: context)
      value.uuid
    end

    def update(uuid, plain_value, context: {})
      value = ActiveRecord::Value.find_by!(uuid: uuid)
      value.plain_value = plain_value
      value.context = context
      value.save!
      uuid
    end

    def decrypt(uuid, context: {})
      value = ActiveRecord::Value.find_by!(uuid: uuid)
      value.context = context
      value.decrypt
    end

    private

    def fetch_data_key(key_name)
      ActiveRecord::DataKey.find_or_create_by!(name: key_name, cmk_id: Voynich.kms_cmk_id)
    end
  end
end
