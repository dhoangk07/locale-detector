class RunDeleteFolderGithub 
  @queue = :delete_folder_queue
  
  def self.perform(path)
    Repo.delete_folder_github(path)
  end
end
