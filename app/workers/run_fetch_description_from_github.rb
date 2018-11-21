class RunFetchDescriptionFromGithub
  @queue = :fetch_description_queue

  def self.perform(repo_id)
    repo = Repo.find(repo_id)
    repo.conver_to_git_path
    repo.fetch_description_from_github
  end
end
