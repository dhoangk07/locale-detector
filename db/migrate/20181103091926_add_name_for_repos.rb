class AddNameForRepos < ActiveRecord::Migration[5.2]
  def change
    add_column :repos, :name, :string
  end
end
