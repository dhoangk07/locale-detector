class RunCompare
  @queue = :default

  def self.perform(repo_id)
    repo = Repo.find(repo_id)
    repo.run_compare
    repo.send_email_if_missing_keys
  end
end