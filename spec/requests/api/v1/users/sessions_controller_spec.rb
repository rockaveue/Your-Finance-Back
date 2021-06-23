require 'rails_helper'

RSpec.describe Api::V1::Users::SessionsController, type: :controller do
  @controller = Api::V1::Users::SessionsController.new
  before :each do
    request.env['devise.mapping'] = Devise.mappings[:api_v1_user]
    @user = create(:user)
    @user_params = attributes_for(:user)
  end
  describe "POST #create" do
    let(:user_login_params) do {
      "email": @user_params.email,
      "password": @user_params.password
    } end
    it 'logs in with valid credentials' do
      puts @user_params
      post :create, params: {api_v1_user: @user_login_params}
      puts response.body
      expect(response).to have_http_status(:success)
    end
    it 'does not log in without valid credentials' do
      @user_params[:password] = '123456'
      post :create, body: {api_v1_user: @user_params}
      expect(response).to have_http_status(:unauthorized)
    end
  end
end


def auth_spec_request(user)
  request.headers.merge!(user.create_new_auth_token) if sign_in(user)
end