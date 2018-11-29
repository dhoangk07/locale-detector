class RemoveIndexOfLocaleKeys < ActiveRecord::Migration[5.2]
  def change
    remove_index :locale_keys, :key
    remove_index :locale_keys, :locale
    remove_index :locale_keys, :value
  end
end
