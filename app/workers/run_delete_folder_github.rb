class RunDeleteFolderGithub 
  @queue = :default
  
  def self.perform(path)
    Repo.delete_folder_github(path)
  end
end
