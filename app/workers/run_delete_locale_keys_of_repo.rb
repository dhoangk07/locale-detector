class RunDeleteLocaleKeysOfRepo
  @queue = :default
  
  def self.perform(locale_key_id)
    repo_id = LocaleKey.find(locale_key_id).repo_id
    LocaleKey.delete_locale_keys_of_specific_repo(repo_id)
  end
end



