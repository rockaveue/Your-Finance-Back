require 'rails_helper'


RSpec.describe Api::V1::TransactionsController, type: :controller do
  @controller = Api::V1::TransactionsController.new
  before :each do
    @user = create(:user)
    @token = authenticated_header(@user)
    @category_params = attributes_for(:category)
    @category = create(:category)
    @transaction_params = attributes_for(:transaction)
    @transaction_params[:category_id] = @category.id
    request.headers['Authorization'] = @token
  end
  describe "GET #index" do
    it 'checks authentication with JWT' do
      get :index
      expect(response).to have_http_status(:success)
    end
    it 'checks authentication without JWT' do
      request.headers['Authorization'] = nil
      get :index
      expect(response).to have_http_status(:unauthorized)
    end
  end
  describe "POST #create" do
    it 'creates new transaction with valid values' do
      post :create, params: {transaction: @transaction_params}
      expect((JSON.parse(response.body))['amount']).to eq(100)
      expect(response).to have_http_status(:success)
    end
    it 'does not create transaction with empty date' do
      @transaction_params[:transaction_date] = nil
      post :create, params: {transaction: @transaction_params}
      expect(response).to have_http_status(:unprocessable_entity) 
    end
    it 'does not create transaction with amount value of -1' do
      @transaction_params[:amount] = -1
      post :create, params: {transaction: @transaction_params}
      expect(response).to have_http_status(:unprocessable_entity) 
    end
    it 'does not create transaction with amount value of string' do
      @transaction_params[:amount] = "qwert"
      post :create, params: {transaction: @transaction_params}
      expect(response).to have_http_status(:unprocessable_entity) 
    end
  end
  describe "PUT #update" do
    it 'updates transaction' do
      post :create, params: {transaction: @transaction_params}
      transaction_id = JSON.parse(response.body)['id']
      @transaction_params[:amount] = 5000
      put :update, params: {transaction: @transaction_params, id: transaction_id}
      expect((JSON.parse(response.body))['amount']).to eq(5000)
      expect(response).to have_http_status(:success)
    end
    it 'can not update transaction with amount value with -1' do
      post :create, params: {transaction: @transaction_params}
      transaction_id = JSON.parse(response.body)['id']
      @transaction_params[:amount] = -1
      put :update, params: {transaction: @transaction_params, id: transaction_id}
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
  describe "DELETE #destroy" do
    it 'deleting transaction' do
      post :create, params: {transaction: @transaction_params}
      transaction_id = JSON.parse(response.body)['id']
      delete :destroy, params: {id: transaction_id}
      expect(response).to have_http_status(:success)
    end
  end
  describe "POST #getTransactionsByParam" do
    it 'returns transaction by params' do
      post :create, params: {transaction: @transaction_params}
      post :getTransactionsByParam
      expect(response).to have_http_status(:success)
    end
  end
  describe "POST #getTransactionsByDate" do
    it 'returns transactions by date' do
      post :create, params: {transaction: @transaction_params}
      post :getTransactionsByDate
      expect(response).to have_http_status(:success)
    end
  end
end

def authenticated_header(user)
  token = Warden::JWTAuth::UserEncoder.new.call(user, :api_v1_user, nil).first
  return "Bearer #{token}"
  # request.headers['Authorization'] = "Bearer #{token}"
end