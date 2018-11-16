class RunDeleteFolderGithub 
  @queue = :delete_queue
  
  def self.perform(repo_id)
    repo = Repo.find(repo_id)
    Repo.delete_folder_github(repo.cloned_source_path)
  end
end
