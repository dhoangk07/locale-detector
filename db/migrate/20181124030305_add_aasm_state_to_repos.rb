class AddAasmStateToRepos < ActiveRecord::Migration[5.2]
  def change
    add_column :repos, :aasm_state, :string
  end
end
