class RunFetchDescriptionFromGithub
  @queue = :default

  def self.perform(repo_id)
    repo = Repo.find(repo_id)
    repo.convert_to_git_path
    repo.fetch_description_from_github
  end
end
