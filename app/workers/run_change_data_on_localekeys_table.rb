class RunChangeDataOnLocaleKeysTable
  @queue = :default

  def self.perform(repo_id)
    repo = Repo.find(repo_id)
    repo.change_data_on_localekeys_table
  end
end