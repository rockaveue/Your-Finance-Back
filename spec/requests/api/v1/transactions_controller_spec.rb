require 'rails_helper'


RSpec.describe Api::V1::TransactionsController, type: :controller do
  @controller = Api::V1::TransactionsController.new
  before :each do
    @user = create(:user)
    # @user = User.find(1)
    # sign_in @user
    @token = authenticated_header(@user)
  end
  describe "GET #index" do
    it 'checks authentication with JWT' do
      request.headers['Authorization'] = @token
      get :index
      expect(response).to have_http_status(:success)
    end
    it 'checks authentication without JWT' do
      get :index
      expect(response).to have_http_status(:unauthorized)
    end
  end
  describe "POST #getTransactionsByParam" do
    it 'returns transaction' do
      request.headers['Authorization'] = @token
      post :getTransactionsByParam
      # puts JSON.parse(response.body)['income'][0]
      # expect(JSON.parse(response.body)['income'][0]).to be_present, "expected to give records"
      expect(response).to have_http_status(:success)
    end
  end
end

def authenticated_header(user)
  token = Warden::JWTAuth::UserEncoder.new.call(user, :api_v1_user, nil).first
  return "Bearer #{token}"
  # request.headers['Authorization'] = "Bearer #{token}"
end