class RenameForReceiveEmailOfRepos < ActiveRecord::Migration[5.2]
  def change
    rename_column :repos, :receive_email?, :receive_email
  end
end
