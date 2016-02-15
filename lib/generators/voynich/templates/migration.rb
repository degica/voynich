class CreateVoynichTables < ActiveRecord::Migration
  def change
    create_table(:voynich_data_keys) do |t|
      t.string :name, null: false
      t.string :cmk_id, null: false
      t.text :ciphertext, null: false
    end

    create_table(:voynich_values) do |t|
      t.references :data_key, index: true, null: false
      t.string :uuid, null: false
      t.text :ciphertext, null: false
    end

    add_index :voynich_data_keys, :name, unique: true
    add_index :voynich_values, :uuid, unique: true
  end
end
