class RunClone
  @queue = :default

  def self.perform(repo_id)
    repo = Repo.find(repo_id)
    repo.run_clone
  end
end