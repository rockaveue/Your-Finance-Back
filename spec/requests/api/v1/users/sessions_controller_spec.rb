require 'rails_helper'

RSpec.describe Api::V1::Users::SessionsController, type: :controller do
  @controller = Api::V1::Users::SessionsController.new
  before :each do
    @request.env['devise.mapping'] = Devise.mappings[:api_v1_user]
    @user_params = attributes_for(:user)
    @user = User.create!(@user_params)
    @user2 = create(:user)
    @token = authenticated_header(@user2)
  end
  let(:user_login_params) do {
    "email": @user_params[:email],
    "password": '123456789a'
  } end
  describe "POST #create" do
    it 'logs in with valid credentials' do
      post :create, params: {api_v1_user: user_login_params}
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['message']).to eq("Logged in.")
    end
    it 'does not log in without valid credentials' do
      user_login_params[:password] = '123456'
      post :create, body: {api_v1_user: user_login_params}
      expect(response).to have_http_status(:unauthorized)
      expect(response.body).to eq('You need to sign in or sign up before continuing.')
    end
  end
  describe "Delete #destroy" do
    it 'logs out logged in user' do
      request.headers['Authorization'] = @token
      delete :destroy
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['message']).to eq("Logged out successfully.")
    end
    it 'does not log out without token' do
      delete :destroy
      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)['message']).to eq("Errors occured while logging out.")
    end
  end
end