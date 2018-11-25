class RunDetectDaily
  @queue = :default
  def self.perform
    Repo.detect_missing_keys_daily
  end
end

