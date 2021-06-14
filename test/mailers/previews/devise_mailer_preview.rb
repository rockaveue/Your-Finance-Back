class DeviseMailerPreview < ActionMailer::Preview
  def reset_password_instructions
    user = User.first
    PasswordMailer.reset_password_instructions(user, "faketoken", {})
  end
end