class RunDeleteFolderGithubJob < ApplicationJob
  queue_as :default
  
  def perform(repo)
    repo.delete_folder_github
  end
end