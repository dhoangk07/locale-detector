class RemoveReceiveEmailFromUsers < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :receive_email?
  end
end
