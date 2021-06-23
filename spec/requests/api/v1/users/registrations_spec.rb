require 'rails_helper'

RSpec.describe Api::V1::Users::RegistrationsController, type: :controller do
  @controller = Api::V1::Users::RegistrationsController.new
  before :each do
    @request.env['devise.mapping'] = Devise.mappings[:api_v1_user]
    @user_params = attributes_for(:user)
  end
  describe "POST #create" do
    it 'registers a user' do
      post :create, params: {api_v1_user: @user_params}
      expect(response).to have_http_status(:success)
    end
  end
end

def auth_spec_request(user)
  request.headers.merge!(user.create_new_auth_token) if sign_in(user)
end