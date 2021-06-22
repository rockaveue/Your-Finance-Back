require 'rails_helper'

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