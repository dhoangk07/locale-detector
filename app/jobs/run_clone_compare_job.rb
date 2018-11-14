class RunCloneCompareJob < ApplicationJob
  queue_as :default

  def perform(repo)
    repo.run_clone
    repo.run_compare
  end
end
