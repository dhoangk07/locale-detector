class LocaleKey < ApplicationRecord
  # Schema of LocaleKeys table
  #   t.string "locale"
  #   t.string "key"
  #   t.string "value"
  #   t.datetime "created_at", null: false
  #   t.datetime "updated_at", null: false
  #   t.integer "repo_id"
  belongs_to :repo
end