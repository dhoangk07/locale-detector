module ReposHelper
  # def indentation(string)
  #   arrays = string.split(".")
  #   result = []
  #   result << arrays[0].split(" ")[1]
  #   arrays.each_with_index { |element, index|
  #     result << element.insert(0, "   "*index) if index > 0
  #   }
  # end

  def subscribed_by_user?(user, repo)
    repo.subscribes.where(user_id: user.id).present? if user.present?
  end
end
