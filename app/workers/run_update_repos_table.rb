class RunUpdateReposTable
  @queue = :default

  def self.perform
    Repo.update_repos_table
  end
end
