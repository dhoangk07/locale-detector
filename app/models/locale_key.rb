class LocaleKey < ApplicationRecord
  belongs_to :repo

  def self.delete_locale_keys_of_specific_repo(repo_id)
    LocaleKey.where(repo_id: "#{repo_id}").destroy_all
  end
end