class RunDetectDaily
  @queue = :queue_detect_daily
  def self.perform
    Repo.detect_missing_keys_daily
  end
end

