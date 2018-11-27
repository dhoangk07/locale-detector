class LocaleKey < ApplicationRecord
  # Schema of LocaleKeys table
  #   t.string "locale"
  #   t.string "key"
  #   t.string "value"
  #   t.datetime "created_at", null: false
  #   t.datetime "updated_at", null: false
  #   t.integer "repo_id"
  belongs_to :repo
  def change_data_of_locale_key(change, file, key, value, repo)
    LocaleKey.change(locale:  file.remove('.yml'), 
                     key:     key, 
                     value:   value,
                     repo_id: repo.id)
  end
end