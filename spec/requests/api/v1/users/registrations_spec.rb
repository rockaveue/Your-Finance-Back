require 'rails_helper'

RSpec.describe Api::V1::Users::RegistrationsController, type: :controller do
  @controller = Api::V1::Users::RegistrationsController.new
  before :each do
    @request.env['devise.mapping'] = Devise.mappings[:api_v1_user]
    @user_params = attributes_for(:user)
  end
  describe "POST #create" do
    it 'registers a user and sends email' do
      post :create, params: {api_v1_user: @user_params}
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['message']).to eq("Signed in successfully.")
      expect(ActionMailer::Base.deliveries.size).to eq(1)
    end
    it 'does not registers a user without valid email' do
      @user_params[:email] = "myemail"
      post :create, params: {api_v1_user: @user_params}
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['message']['email']).to eq(["is invalid"])
      expect(ActionMailer::Base.deliveries.size).to eq(0)
    end
    it 'does not registers a user without email' do
      @user_params[:email] = nil
      post :create, params: {api_v1_user: @user_params}
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['message']['email'][0]).to eq("can't be blank")
      expect(ActionMailer::Base.deliveries.size).to eq(0)
    end
    it 'does not registers a user without valid first_name' do
      @user_params[:first_name] = 'adhasdkjlfhkjasdhfkjsahdfasdfas'
      post :create, params: {api_v1_user: @user_params}
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['message']['first_name'][0]).to eq("is too long (maximum is 30 characters)")
      expect(ActionMailer::Base.deliveries.size).to eq(0)
    end
  end
end

def auth_spec_request(user)
  request.headers.merge!(user.create_new_auth_token) if sign_in(user)
end