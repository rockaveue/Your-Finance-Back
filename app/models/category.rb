class Category < ApplicationRecord
  has_many :user_categories
  has_one :transactions

  validates :category_name, presence: true, length: { maximum: 30 }
  validates :is_income, inclusion: { in: [ true, false ] }
  
  scope :is_default_and_not_deleted, -> { where(is_default: true, is_deleted: false)}

  def self.getUserCategories(params)
    query = joins(:user_categories)
      .where('user_categories.user_id = ?', current_api_v1_user.id)
      .where(is_deleted: false)

    if params[:is_income].in? [true, false]
      query = query.where('is_income = ?', params[:is_income])
    end
    
    return query
  end
end
