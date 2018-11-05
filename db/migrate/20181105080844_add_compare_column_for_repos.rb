class AddCompareColumnForRepos < ActiveRecord::Migration[5.2]
  def change
    add_cloumn :repos, :compare, :text
  end
end
