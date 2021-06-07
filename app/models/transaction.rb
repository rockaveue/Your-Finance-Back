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

  def self.getTransactionCategory(user_id)
    joins(:category).where('categories.user_id = ?', user_id)
    # includes(:user_categories).where(user_categories:{user_id: user_id})
  end
end
