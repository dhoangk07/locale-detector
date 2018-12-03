class AddReceiveEmailForRepos < ActiveRecord::Migration[5.2]
  def change
    add_column :repos, :receive_email?, :boolean, default: true
  end
end
