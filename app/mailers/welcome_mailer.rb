class WelcomeMailer < ApplicationMailer
  default from: "delivmy@gmail.com"
  def sample_email(user)
    @user = user
    mail(to: @user.email, subject: 'Sample Email')
  end
end
