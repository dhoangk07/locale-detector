class RunDeleteLocaleKeysOfRepo
  @queue = :default
  
  def self.perform(repo_id)
    LocaleKey.where(repo_id: repo_id).delete_all
  end
end



