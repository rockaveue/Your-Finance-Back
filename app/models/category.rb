class Category < ApplicationRecord
    has_many :user_categories
    has_one :transactions


    def self.getUserCategories(user_id)
        joins(:user_categories).where('user_categories.user_id = ?', user_id)
        # includes(:user_categories).where(user_categories:{user_id: user_id})
    end
end
