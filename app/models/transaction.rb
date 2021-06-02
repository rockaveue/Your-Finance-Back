class Transaction < ApplicationRecord
  belongs_to :category
  belongs_to :user

  def self.getTransactionCategory(params)
    query = joins(:category).where('user_id = ?', params[:user_id])
    
    if params[:transaction_date].present?
      query = query.where('transaction_date = ?', params[:transaction_date])
    end

    if params[:is_income].in? [true, false]
      query = query.where('is_income = ?', params[:is_income])
    end

    if params[:group_column].present?
      query = query.group(params[:group_column])
    end

    return query
  end
end
