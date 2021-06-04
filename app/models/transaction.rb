class Transaction < ApplicationRecord
  belongs_to :category
  belongs_to :user

  def self.getTransactionCategory(params, is_income, groupBy, selected)
    query = joins(:category)
      .where('user_id = ?', params[:user_id])
      .where(is_deleted: false)
    
    if params[:transaction_date].present?
      query = query.where('transaction_date = ?', params[:transaction_date])
    end

    if is_income.in? [true, false]
      query = query.where('is_income = ?', is_income)
    end

    if groupBy.present?
      query = query.group(groupBy)
    end

    if selected == 1
      query = query.select('categories.id, categories.category_name, SUM(transactions.amount) as amount, transactions.transaction_date')
    end
    return query
  end

  def self.getTransactions(params, is_income, groupByDate, selected)
    query = joins(:category)
      .where(:user_id => params[:user_id])
      .where(is_income: is_income)

    if params[:date_from].present?
      query = query.where('DATE(transaction_date) BETWEEN ? AND ?', params[:date_from], params[:date_to])
    elsif params[:number_of_days].present?
      query = query.where('DATE(transaction_date) BETWEEN ? AND ?', params[:number_of_days].days.ago, Time.now)
    elsif params[:transaction_date].present?
      query = query.where(:transaction_date => params[:transaction_date])
    end

    if groupByDate == 1
      query = query.group(:transaction_date)
    elsif groupByDate == 2
      query = query.group(:category_id)
    end

    if selected == 1
      query = query.select('transaction_date, sum(amount) as amount')
    elsif selected == 2
      query = query.select('sum(amount) as total_amount')
    elsif selected == 3
      query = query.select('transactions.is_income, amount, is_repeat, note, category_name')
    elsif selected == 4
      query = query.select('categories.id as category_id, category_name, SUM(amount) as amount')
    end

    if !selected.nil?
      query = query.as_json(:except => :id)
    end
    
    return query
  end
end
