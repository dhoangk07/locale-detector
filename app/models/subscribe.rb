class Subscribe < ApplicationRecord
  # create_table "subscribes", force: :cascade do |t|
  #   t.bigint "user_id"
  #   t.bigint "repo_id"
  #   t.datetime "created_at", null: false
  #   t.datetime "updated_at", null: false
  #   t.index ["repo_id"], name: "index_subscribes_on_repo_id"
  #   t.index ["user_id"], name: "index_subscribes_on_user_id"
  # end
  belongs_to :user
  belongs_to :repo
  validates_uniqueness_of :user_id, scope: :repo_id
end
