class RemoveIndexOfRepos < ActiveRecord::Migration[5.2]
  def change
    remove_index :repos, :url
    remove_index :repos, :user_id
  end
end
