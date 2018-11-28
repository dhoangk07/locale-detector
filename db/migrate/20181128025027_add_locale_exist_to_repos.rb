class AddLocaleExistToRepos < ActiveRecord::Migration[5.2]
  def change
    add_column :repos, :locale_exist, :boolean
  end
end
