class RenameToMakeSenseForRepos < ActiveRecord::Migration[5.2]
  def change
    rename_column :repos, :locale_exist?, :locale_exist
    rename_column :repos, :multi_language_support?, :multi_language_support
  end
end
