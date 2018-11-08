class AddDescriptionForReposTable < ActiveRecord::Migration[5.2]
  def change
    add_column :repos, :description, :string
  end
end
