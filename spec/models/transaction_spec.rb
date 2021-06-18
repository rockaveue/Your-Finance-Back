require 'rails_helper'

RSpec.describe Transaction, type: :model do
  describe "Associations" do
    it { should belong_to(:user) }
    it { should belong_to(:category) }
  end
  describe "Validations" do
    it 'is valid with valid attributes' do
      transaction = build(:transaction, user: build(:user), category: build(:category))
      expect(transaction).to be_valid
    end
    it 'is not valid without user' do
      transaction = build(:transaction, category: build(:category))
      expect(transaction).to_not be_valid
    end
    it 'is not valid without category' do
      user = build(:user)
      category = build(:category)
      transaction = build(:transaction, user: build(:user))
      expect(transaction).to_not be_valid
    end
    it 'is not valid without is_income' do
      transaction = build(:transaction, user: build(:user), category: build(:category))
      transaction.is_income = nil
      expect(transaction).to_not be_valid
    end
    it 'is not valid without amount' do
      transaction = build(:transaction, user: build(:user), category: build(:category))
      transaction.amount = nil
      expect(transaction).to_not be_valid
    end
    it 'is not valid if amount is not number' do
      transaction = build(:transaction, user: build(:user), category: build(:category))
      transaction.amount = 'test'
      expect(transaction).to_not be_valid
    end
    it 'is not valid without transaction_date' do
      transaction = build(:transaction, user: build(:user), category: build(:category))
      transaction.transaction_date = nil
      expect(transaction).to_not be_valid
    end
    it 'is not valid if transaction_date is not date' do
      transaction = build(:transaction, user: build(:user), category: build(:category))
      transaction.transaction_date = 'test'
      expect(transaction).to_not be_valid
    end
    it 'is not valid if note is longer than 255' do
      transaction = build(:transaction, user: build(:user), category: build(:category))
      transaction.note = 'testtesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttestttesttesttesttesttesttesttestesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttesttest'
      expect(transaction).to_not be_valid
    end
    it 'is not valid without is_repeat' do
      transaction = build(:transaction, user: build(:user), category: build(:category))
      transaction.is_repeat = nil
      expect(transaction).to_not be_valid
    end
  end
end