class AddNewCloumnToRepos < ActiveRecord::Migration[5.2]
  def change
    add_column :repos, :multi_language_support?, :boolean
  end
end
