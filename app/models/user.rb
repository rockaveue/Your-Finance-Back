class User < ApplicationRecord
  has_many :transactions
  has_many :user_categories

  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable, :jwt_authenticatable, jwt_revocation_strategy: JwtBlacklist
  
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: true, presence: true, length: { maximum: 256 }
  validates :first_name, presence: true, length: { maximum: 256 }
  validates :last_name, presence: true, length: { maximum: 256 }
  validates :encrypted_password, presence: true, length: { maximum: 256 }
  # has_secure_password
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  def reset_password(param)
    if param[:password].present?
      self.password = param[:password]
      self.password_confirmation = param[:password_confirmation]
      save
    else
      errors.add(:password, :blank)
      false
    end
  end
end