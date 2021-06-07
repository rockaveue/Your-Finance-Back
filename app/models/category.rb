class Category < ApplicationRecord
  has_many :user_categories
  has_one :transactions

  validates :category_name, presence: true, length: { maximum: 30 }
  validates :is_income, inclusion: { in: [ true, false ] }

  def self.getUserCategories(user_id)
    joins(:user_categories).where('user_categories.user_id = ?', user_id)
    # includes(:user_categories).where(user_categories:{user_id: user_id})
  end
end
