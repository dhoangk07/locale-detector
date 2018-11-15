class RunDeleteFolderGithub 
  @queue = :delete_queue
  
  def self.perform(repo_id)
    repo = Repo.find(repo_id)
    repo.delete_folder_github
  end
end