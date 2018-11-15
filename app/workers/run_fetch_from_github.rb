class RunFetchFromGithub
  @queue = :fetch_queue

  def self.perform(repo)
    repo.decorate_repo
    repo.fetch_from_github
  end
end
