class User < ApplicationRecord
  has_many :transactions
  has_many :user_categories
  has_secure_password :validations => false
  VALID_NAME = /\A[A-z\u{0400}-\u{04FF}'\-]*\z/

  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable, :jwt_authenticatable, jwt_revocation_strategy: JwtBlacklist
  
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: true, presence: true, length: { maximum: 50 }
  validates_exist_email_of :email
  validates :first_name, presence: true, length: { maximum: 30, minimum: 2 }, format: {with: VALID_NAME, message: "must only contain letters and hyphens."}
  validates :last_name, presence: true, length: { maximum: 30, minimum: 2 }, format: {with: VALID_NAME, message: "must only contain letters and hyphens."}
  validates :encrypted_password, presence: true, length: { maximum: 256 }
  validates :balance, numericality: {less_than: 999_999_999_999.99}
  validate :balance_decimal_validation
  # has_secure_password
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  def balance_decimal_validation
    decimals = balance.to_s.split('.')
    if decimals.size == 2 && decimals.last.size > 2
      errors.add(:balance, "can't be more than 2 decimal places")
    end
  end
end
