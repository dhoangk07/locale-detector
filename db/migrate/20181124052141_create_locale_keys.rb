class CreateLocaleKeys < ActiveRecord::Migration[5.2]
  def change
    create_table :locale_keys do |t|
      t.string :locale
      t.string :key
      t.string :value

      t.timestamps
    end
  end
end
