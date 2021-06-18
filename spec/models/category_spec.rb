require 'rails_helper'

RSpec.describe Category, type: :model do
  it 'is valid with valid attributes' do
    category = build(:category)
    expect(category).to be_valid
  end
  it 'is not valid without category_name' do
    category = build(:category)
    category.category_name = nil
    expect(category).to_not be_valid
  end
  it 'is not valid without is_income' do
    category = build(:category)
    category.is_income = nil
    expect(category).to_not be_valid
  end
end