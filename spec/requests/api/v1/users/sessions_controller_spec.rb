require 'rails_helper'

RSpec.describe Api::V1::Users::SessionsController, type: :controller do
  @controller = Api::V1::Users::SessionsController.new
  before :each do
    @request.env['devise.mapping'] = Devise.mappings[:api_v1_user]
    @user_params = attributes_for(:user)
    @user = User.create!(@user_params)
    @token = authenticated_header(@user)
  end
  let(:user_login_params) do {
    "email": @user_params[:email],
    "password": @user_params[:password]
  } end
  describe "POST #create" do
    it 'logs in with valid credentials' do
      post :create, params: {api_v1_user: user_login_params}
      puts response.headers
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
      post :create, params: {api_v1_user: user_login_params}
      request.headers['Authorization'] = @token
      puts @token
      delete :destroy
      puts response.body
      expect(response).to have_http_status(:success)
    end
  end
end