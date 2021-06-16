class UserMailer < ApplicationMailer
  default from: ENV["GMAIL_SMTP_USER"]
  layout 'mailer'

  def welcome_email(user)
    @user = user
    mail(to: @user.email, subject: "Your-Finance-Back-д тавтай морил")
  end
end
