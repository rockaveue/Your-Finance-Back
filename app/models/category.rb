class Category < ApplicationRecord
    has_many :user_categories
    has_one :transactions
end
