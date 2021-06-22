require 'rails_helper'

RSpec.describe User, type: :model do
  it 'is valid with valid attributes' do
    user = build(:user)
    expect(user).to be_valid
  end
  it 'is not valid without attributes' do
    user = User.new
    expect(user).to_not be_valid
  end
  it 'is not valid without email' do
    user = build(:user)
    user.email = nil
    expect(user).to_not be_valid
  end
  it 'is not valid with wrong email' do
    user = build(:user)
    user.email = 'test'
    expect(user).to_not be_valid
  end
  it 'is not valid without first_name' do
    user = build(:user)
    user.first_name = nil
    expect(user).to_not be_valid
  end
  it 'is not valid without last_name' do
    user = build(:user)
    user.last_name = nil
    expect(user).to_not be_valid
  end
  it 'is not valid without password' do
    user = build(:user)
    user.password = nil
    expect(user).to_not be_valid
  end
  it 'is not valid if first_name length is longer than 30' do
    user = build(:user)
    user.first_name = 'asdqweasdqweasdqweasdqweasdqwee'
    expect(user).to_not be_valid
  end
  it 'is not valid if password is shorter than 6' do
    user = build(:user)
    user.password = '12345'
    expect(user).to_not be_valid
  end
end