class RenameLocaleExistOfRepos < ActiveRecord::Migration[5.2]
  def change
    rename_column :repos, :locale_exist, :locale_exist?
  end
end
