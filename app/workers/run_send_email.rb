class RunSendEmail
  @queue = :default

  def self.perform(repo_id)
    repo = Repo.find(repo_id)
    repo.send_email_if_missing_keys
  end
end