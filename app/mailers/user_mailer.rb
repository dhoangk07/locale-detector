class UserMailer < ApplicationMailer
   default from: 'notifications@example.com'
 
  def notify_missing_key_on_locale_for_owner(user, repo)
    @user = user
    @repo = repo
    # @url  = 'http://example.com/login'
    # mail(to: @user.email, subject: 'Notify Missing Key on Locale')
    mail(to: @user.email, subject: "Welcome!").tap do |message|
      message.mailgun_options = {
        "tag" => ["abtest-option-a", "beta-user"],
        "tracking-opens" => true,
        "tracking-clicks" => "htmlonly"
      }
    end
  end

  def notify_missing_key_on_locale_for_subscribe(user, repo)
    @user = user
    @repo = repo
    @url  = 'http://example.com/login'
    mail(to: @user.email, subject: 'Notify Missing Key on Locale')
  end
end
  