class AddUserIdToRepos < ActiveRecord::Migration[5.2]
  def change
    add_column :repos, :user_id, :integer
  end
end
