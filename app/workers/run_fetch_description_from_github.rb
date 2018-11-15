class RunFetchDescriptionFromGithub
  @queue = :fetch_queue

  def self.perform(repo_id)
    repo = Repo.find(repo_id)
    repo.decorate_repo
    repo.fetch_description_from_github
  end
end
