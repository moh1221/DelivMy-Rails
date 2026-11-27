class WelcomeMailer < ApplicationMailer
  def sample_email(user)
    @user = user
    @profile = user.profile
    @url = login_url
    mail(to: user.email, subject: "Welcome to DelivMy")
  end
end
