class AddIndexForRepos < ActiveRecord::Migration[5.2]
  def change
    add_index :repos, :url
    add_index :repos, :user_id
  end
end
