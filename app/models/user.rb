class User < ApplicationRecord
  has_many :transactions
  has_many :user_categories
  has_secure_password :validations => false

  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable, :jwt_authenticatable, jwt_revocation_strategy: JwtBlacklist
  
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: true, presence: true, length: { maximum: 50 }
  validates :first_name, presence: true, length: { maximum: 30 }
  validates :last_name, presence: true, length: { maximum: 30 }
  validates :password, length: { maximum: 30, minimum: 6}
  validates :encrypted_password, presence: true, length: { maximum: 256 }
  # has_secure_password
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
end
