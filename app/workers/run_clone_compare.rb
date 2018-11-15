class RunCloneCompare
  @queue = :repo_queue

  def self.perform(repo)
    repo.run_clone
    repo.run_compare
  end
end