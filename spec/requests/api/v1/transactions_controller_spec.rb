require 'rails_helper'


RSpec.describe Api::V1::TransactionsController, type: :controller do
  @controller = Api::V1::TransactionsController.new
  before :each do
    @user = create(:user)
    @token = authenticated_header(@user)
    @category_params = attributes_for(:category)
    @transaction_params = attributes_for(:transaction)
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
      old_controller = @controller
      @controller = Api::V1::CategoriesController.new
      post :create, params: {category: @category_params}
      puts response.body
      category_id = JSON.parse(response.body)['id']
      puts category_id
      @controller = old_controller
      user_id = @user.id
      @transaction_params[:category_id] = category_id
      @transaction_params[:user_id] = user_id
      puts @transaction_params
      post :create, params: {transaction: @transaction_params}
      expect(response).to have_http_status(:success)
    end
    it 'does not create transaction with empty date' do
      old_controller = @controller
      @controller = Api::V1::CategoriesController.new
      post :create, params: {category: @category_params}
      category_id = JSON.parse(response.body)['id']
      @controller = old_controller
      @transaction_params[:category_id] = category_id
      @transaction_params[:transaction_date] = nil
      post :create, params: {transaction: @transaction_params}
      expect(response).to have_http_status(:unprocessable_entity) 
    end
    it 'does not create transaction with amount value of -1' do
      old_controller = @controller
      @controller = Api::V1::CategoriesController.new
      post :create, params: {category: @category_params}
      category_id = JSON.parse(response.body)['id']
      @controller = old_controller
      @transaction_params[:category_id] = category_id
      @transaction_params[:amount] = -1
      post :create, params: {transaction: @transaction_params}
      expect(response).to have_http_status(:unprocessable_entity) 
    end
    it 'does not create transaction with amount value of string' do
      old_controller = @controller
      @controller = Api::V1::CategoriesController.new
      post :create, params: {category: @category_params}
      category_id = JSON.parse(response.body)['id']
      @controller = old_controller
      @transaction_params[:category_id] = category_id
      @transaction_params[:amount] = "123"
      post :create, params: {transaction: @transaction_params}
      expect(response).to have_http_status(:unprocessable_entity) 
    end
  end
  describe "PUT #update" do
    it 'updates transaction' do
      old_controller = @controller
      @controller = Api::V1::CategoriesController.new
      post :create, params: {category: @category_params}
      category_id = JSON.parse(response.body)['id']
      @controller = old_controller
      @transaction_params[:category_id] = category_id
      post :create, params: {transaction: @transaction_params}
      transaction_id = JSON.parse(response.body)['id']
      @transaction_params[:amount] = 5000
      put :update, params: {transaction: @transaction_params, id: transaction_id}
      expect(response).to have_http_status(:success)
    end
  end
  describe "DELETE #destroy" do
    it 'deleting transaction' do
      old_controller = @controller
      @controller = Api::V1::CategoriesController.new
      post :create, params: {category: @category_params}
      category_id = JSON.parse(response.body)['id']
      @controller = old_controller
      @transaction_params[:category_id] = category_id
      post :create, params: {transaction: @transaction_params}
      transaction_id = JSON.parse(response.body)['id']
      delete :destroy, params: {id: transaction_id}
      expect(response).to have_http_status(:success)
    end
  end
  describe "POST #getTransactionsByParam" do
    it 'returns transaction by params' do
      post :getTransactionsByParam
      expect(response).to have_http_status(:success)
    end
  end
  describe "POST #getTransactionsByDate" do
    it 'returns transactions by date' do
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