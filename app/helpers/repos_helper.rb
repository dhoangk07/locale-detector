module ReposHelper
  def subscribed_by_user?(user, repo)
    repo.subscribes.where(user_id: user.id).present? if user.present?
  end
end
