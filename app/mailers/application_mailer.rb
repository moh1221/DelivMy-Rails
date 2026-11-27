class ApplicationMailer < ActionMailer::Base
  default from: -> { ENV.fetch("MAIL_FROM", "no-reply@delivmy.example") }
  layout "mailer"
end
