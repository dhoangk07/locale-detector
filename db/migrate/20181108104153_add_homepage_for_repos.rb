class AddHomepageForRepos < ActiveRecord::Migration[5.2]
  def change
    add_column :repos, :homepage, :string
  end
end
