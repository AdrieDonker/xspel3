class GameMailer < ApplicationMailer
  default from: 'notifications@example.com'
 
  def welcome_email(user)
    @user = user
    @url  = 'http://example.com/login'
    @url = 'https://a3donker-adriedonker.c9users.io'
    mail(to: @user.email, subject: 'Welkom bij XSPL')
  end
end
