class CreateSubscribes < ActiveRecord::Migration[5.2]
  def change
    create_table :subscribes do |t|
      t.references :user, foreign_key: true
      t.references :repo, foreign_key: true

      t.timestamps
    end
  end
end
