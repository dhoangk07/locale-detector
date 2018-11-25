class AddRepoIdToLocaleKeys < ActiveRecord::Migration[5.2]
  def change
    add_column :locale_keys, :repo_id, :integer
  end
end
