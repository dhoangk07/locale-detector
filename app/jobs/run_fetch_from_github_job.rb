class RunFetchFromGithubJob < ApplicationJob
  queue_as :default

  def perform(repo)
    repo.decorate_repo
    repo.fetch_from_github
  end
end
