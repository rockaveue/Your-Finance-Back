require 'rails_helper'

RSpec.describe Transaction, type: :model do
  it {
    should belong_to(:user)
  }
  it 'is valid with valid attributes' do
    user = build(:user)
    category = build(:category)
    transaction = build(:transaction, user: user, category: category)
    expect(transaction).to be_valid
  end
end