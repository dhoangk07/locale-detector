class RunCloneCompare
  @queue = :default

  def self.perform(repo_id)
    repo = Repo.find(repo_id)
    repo.run_clone
    repo.run_compare
    repo.send_email_if_missing_keys
  end
end