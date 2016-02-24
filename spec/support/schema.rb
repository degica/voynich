require File.dirname(__FILE__) + '/active_record.rb'
ActiveRecord::Schema.define do
  self.verbose = false

  create_table(:voynich_data_keys) do |t|
    t.string :name
    t.string :cmk_id
    t.text :ciphertext
  end

  create_table(:voynich_values) do |t|
    t.integer :data_key_id
    t.string :uuid
    t.text :ciphertext
  end

  create_table(:voynich_active_model_targets) do |t|
    t.string :uuid
    t.integer :voynich_secret_value_id
    t.integer :voynich_auth_secret_value_id
  end
end
