class PasswordMailer < Devise::Mailer
  include Devise::Controllers::UrlHelpers
  default template_path: 'devise/mailer'
    
  def reset_password_instructions(record, token, opts = {})
    @token = token
    @user = record
    devise_mail(record, :reset_password_instructions, opts)
  end
end