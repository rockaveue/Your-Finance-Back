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

  def self.getTransactionsByDay(params, is_income, groupByDate)
    query = where(:user_id => params[:user_id])
      .where('DATE(transaction_date) BETWEEN ? AND ?', params[:number_of_days].days.ago, Time.now)
      .where('is_income = ?', is_income)

    if groupByDate
      query = query.group(:transaction_date)
        .as_json(:except => :id)
    end
    
    return query
  end
end
