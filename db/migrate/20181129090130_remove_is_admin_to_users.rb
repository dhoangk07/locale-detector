class RemoveIsAdminToUsers < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :is_admin?, :boolean, default: false
  end
end
