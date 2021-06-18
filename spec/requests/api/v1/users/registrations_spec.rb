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
    user = User.new
    user.first_name = 'Dulguun'
    user.last_name = 'Tuguldur'
    user.password = '1234567'
    expect(user).to_not be_valid
  end
  it 'is not valid with wrong email' do
    user = User.new
    user.email = 'test'
    user.first_name = 'Dulguun'
    user.last_name = 'Tuguldur'
    user.password = '1234567'
    expect(user).to_not be_valid
  end
  it 'is not valid without some attribute' do
    user = User.new
    user.email = 'test@gmail.com'
    expect(user).to_not be_valid
  end
end


RSpec.describe "Api::V1::Users::Registrations", type: :request do
  describe "POST #create" do
    let (:user_params) do
      {
        "api_v1_user":{
          "email": "mail8@yahoo.com",
          "first_name": "dulguun",
          "last_name": "tuguldur",
          "password": "123456"
        }
      }
    end
    it 'registers a user' do
      post '/api/v1/users/signup', params: user_params
      expect(response).to have_http_status(:success)
    end
  end
end


def auth_spec_request(user)
  request.headers.merge!(user.create_new_auth_token) if sign_in(user)
end