class RunCloneCompare
  @queue = :clone_queue

  def self.perform(repo_id)
    repo = Repo.find(repo_id)
    repo.run_clone
    repo.run_compare
  end
end