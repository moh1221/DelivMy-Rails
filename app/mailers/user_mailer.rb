class UserMailer < ApplicationMailer
  def password_reset(user, token)
    @token = token
    mail(to: user.email, subject: "Password Reset")
  end
end
