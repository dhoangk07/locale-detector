class AddIndexForLocaleKeys < ActiveRecord::Migration[5.2]
  def change
    add_index :locale_keys, :locale
    add_index :locale_keys, :key
    add_index :locale_keys, :value
    add_index :locale_keys, :repo_id
  end
end
