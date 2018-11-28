class AddReadmeToRepos < ActiveRecord::Migration[5.2]
  def change
    add_column :repos, :readme, :text
  end
end
