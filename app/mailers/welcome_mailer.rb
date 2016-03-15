class WelcomeMailer < ApplicationMailer
  default from: "moh_abo@hotmail.com"
  def sample_email(user)
    @user = user
    @profile = @user.profile
    @url = "http://delivmy.com/login"
    mail(to: @user.email, subject: 'Welcome to DelivMy')
  end
end
