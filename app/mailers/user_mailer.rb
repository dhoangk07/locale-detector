class UserMailer < ApplicationMailer
   default from: 'notifications@locale-detector.space'
 
  def notify_missing_key_on_locale_for_owner(user, repo)
    if repo.receive_email == true
      @user = user
      @repo = repo
      @url  = 'http://example.com/login'
      mail(to: @user.email, subject: 'Notify Missing Key on Locale')
    end
  end

  def notify_missing_key_on_locale_for_subscribe(user, repo)
    @user = user
    @repo = repo
    @url  = 'http://example.com/login'
    mail(to: @user.email, subject: 'Notify Missing Key on Locale')
  end
end
