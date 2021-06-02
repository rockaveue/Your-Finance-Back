class Transaction < ApplicationRecord
  belongs_to :category
  belongs_to :user

  def self.getTransactionCategory(user_id)
    joins(:category).where('categories.user_id = ?', user_id)
    # includes(:user_categories).where(user_categories:{user_id: user_id})
  end
end
