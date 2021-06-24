class Transaction < ApplicationRecord
  belongs_to :category
  belongs_to :user

  validates :category, presence: true
  validates :user, presence: true
  validates :is_income, inclusion: { in: [ true, false ] }
  validates :amount, presence: true, numericality: true
  validates :transaction_date, presence: true
  validate :transaction_date_is_valid_datetime
  validates :note, length: { maximum: 255 }
  validates :is_repeat, inclusion: { in: [true, false] }

  def transaction_date_is_valid_datetime
    errors.add(:transaction_date, 'must be a valid datetime') if ((transaction_date.is_a?(Date) rescue ArgumentError) == ArgumentError)
  end

  def self.getTransactions(param, selected, user_id)
    query = joins(:category)
      .where(:user_id => user_id)
      .where(is_deleted: false)
      .order(:transaction_date)

    if param[:date_from].present?
      query = query.where('DATE(transaction_date) BETWEEN ? AND ?', param[:date_from], param[:date_to])
    elsif param[:number_of_days].present?
      query = query.where('DATE(transaction_date) BETWEEN ? AND ?', param[:number_of_days].days.ago, Time.now)
    elsif param[:transaction_date].present?
      query = query.where(:transaction_date => param[:transaction_date])
    end

    if selected == 1
      query = query.select('transaction_date, sum(amount) as amount, transactions.is_income')
    elsif selected == 2
      query = query.select('sum(amount) as total_amount, transactions.is_income')
    elsif selected == 3
      query = query.select('transactions.is_income, transaction_date, amount, is_repeat, note, category_name')
    elsif selected == 4
      query = query.select('categories.id as category_id, category_name, amount, transaction_date, transactions.is_income')
    elsif selected == 5
      query = query.select('transactions.id, user_id, transactions.is_income, transaction_date, amount, is_repeat, note, category_name')
      selected = nil
    end

    if !selected.nil?
      query = query.as_json(:except => :id)
    end
    
    return query
  end

  # Өдрөөр ангилан өдөр болон нийт дүнг бодох
  def self.group_by_date(transaction)
    transaction = transaction
      .group_by{|h| h["transaction_date"]}
      .map do |k,v| {
        :transaction_date => k.to_s,
        :amount => v
          .map {|h1| h1["amount"]}
          .inject(:+)
      }end
  end
  # Нийт дүнг олох
  def self.map_inject_amount(transaction)
    transaction = transaction
      .map {|k| k[:amount]}
      .inject(:+)
  end
  # is_income-оор 2 хуваах
  def self.partition_by_is_income(transaction)
    transaction = transaction
      .partition{|v| v["is_income"]}
  end
  # category_id-аар ангилан id, category_name, transaction_date болон дүнгийн нийлбэр бодох
  def self.group_by_category_and_map(transaction)
    transaction = transaction
      .group_by{|t| t["category_id"]}
      .map do |k, v| {
        id: k,
        category_name: v[0]["category_name"],
        amount: v
          .map{|h| h["amount"]}
          .reduce(:+),
        transaction_date: v[0]["transaction_date"]
      }end
  end
end
