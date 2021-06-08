# class UserMailer < ApplicationMailer
class UserMailer < Devise::Mailer
  default from: ENV["EMAIL"]
  layout 'mailer'
  include Devise::Controllers::UrlHelpers
  # default template_path: 'devise/mailer'

  def welcome_email(user)
    @user = user

    mail(to: @user.email, subject: "Your-Finance-Back-д тавтай морил")
  end

  def send_reset_password_instructions(user)
    raw, hashed = Devise.token_generator.generate(User, :reset_password_token)
    @token = raw
    user.reset_password_token = hashed
    user.reset_password_sent_at = Time.now.utc
    user.save
    @user = user
    mail(to: user.email, subject: 'Your-Finance-Back Password reset')
  end
  
end
