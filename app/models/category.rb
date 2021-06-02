class Category < ApplicationRecord
  has_many :user_categories
  has_one :transactions

  def self.getUserCategories(params)
    query = joins(:user_categories).where('user_categories.user_id = ?', params[:user_id])

    if params[:is_income].in? [true, false]
      query = query.where('is_income = ?', params[:is_income])
    end
    
    return query
  end
end
