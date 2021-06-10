class UserMailerPreview < ActionMailer::Preview
    
  def password_reset
    UserMailer.password_reset(User.first)
  end
  
  def confirmation_instructions
    MyMailer.confirmation_instructions(User.first, "faketoken", {})
  end
end