class UserMailer < ApplicationMailer
   default from: 'notifications@example.com'
 
  def notify_missing_key_on_locale
    @user = params[:user]
    @url  = 'http://example.com/login'
    mail(to: @user.email, subject: 'Notify Missing Key on Locale')
  end
end
