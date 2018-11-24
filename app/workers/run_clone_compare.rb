include AASM
class RunCloneCompare
  @queue = :clone_queue

  def self.perform(repo_id)
    repo = Repo.find(repo_id)
    repo.run_clone
    repo.cloned!
    repo.run_compare
    repo.compared!
    repo.send_email_if_missing_keys
  end
end