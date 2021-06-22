require 'rails_helper'

RSpec.describe Api::V1::Users::SessionsController, type: :controller do
  @controller = Api::V1::Users::SessionsController.new
  before :each do
    request.env['devise.mapping'] = Devise.mappings[:api_v1_user]
  end
  describe "POST #create" do
    let (:user_params) do
      {
        "api_v1_user":{
          "email": "dwight@christiansen-rutherford.io",
          "password": "123456789a"
        }
      }
    end
    it 'logs in with valid credentials' do
      post :create, params: user_params
      expect(response).to have_http_status(:success)
    end
    it 'does not log in without valid credentials' do
      user_params[:api_v1_user][:password] = '123456'
      post :create, body: user_params.to_json
      expect(response).to have_http_status(:unauthorized)
    end
  end
end


def auth_spec_request(user)
  request.headers.merge!(user.create_new_auth_token) if sign_in(user)
end