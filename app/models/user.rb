class User < ApplicationRecord
  has_many :transactions
  has_many :user_categories
  
  validates :email, presence: true, length: {minimum: 7}
  validates :first_name, presence: true, length: {minimum: 2}
  validates :last_name, presence: true, length: {minimum: 2}
  validates :encrypted_password, presence: true, length: {minimum: 3}
  # has_secure_password
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable, :confirmable, :jwt_authenticatable, jwt_revocation_strategy: JwtBlacklist

    # jwt_revocation_strategy: JwtDenylist
    
    # JWT үүсгэх функц
    # def generate_jwt
    #     JWT.encode({id: id, exp: 10.days.from_now.to_i}, Rails.application.secrets.secret_key_base)
    # end
    
end
