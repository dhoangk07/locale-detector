class AddReceiveEmailForUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :receive_email?, :boolean, default: true
  end
end
