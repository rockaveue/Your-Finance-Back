class Category < ApplicationRecord
  has_many :user_categories
  has_one :transactions

  validates :category_name, presence: true, length: { maximum: 30 }
  validates :is_income, inclusion: { in: [ true, false ] }
  
  scope :is_default_and_not_deleted, -> { where(is_default: true, is_deleted: false)}

  def self.getUserCategories(params, user_id)
    query = joins(:user_categories)
      .where('user_categories.user_id = ?', user_id)
      .where(is_deleted: false)

    if params[:is_income].in? [true, false]
      query = query.where('is_income = ?', params[:is_income])
    end
    
    return query
  end

  def self.getUserCategoriesByCategory(category_id)
    query = joins(:user_categories)
      .where(:"user_categories.category_id" => category_id)
      .where(is_default: false)
      .where(is_deleted: false)
      .select('*')
  end
end
