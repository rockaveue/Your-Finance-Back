require 'rails_helper'

RSpec.describe Api::V1::CategoriesController, type: :controller do
  @controller = Api::V1::CategoriesController.new
  before :each do
    @user = create(:user)
    @token = authenticated_header(@user)
    @category_params = attributes_for(:category)
    @transaction_params = attributes_for(:transaction)
    request.headers['Authorization'] = @token
  end
  describe "POST #create" do
    it 'creates new category with valid values' do
      post :create, params: {category: @category_params}
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['category_name']).to eq("test name")
    end
    it 'does not create category with long name' do
      @category_params[:category_name] = "1234567891234567891234567891234"
      @category_params[:is_income] = "123"
      post :create, params: {category: @category_params}
      expect(response).to have_http_status(:unprocessable_entity)      
      expect(JSON.parse(response.body)['message']['category_name']).to eq(["is too long (maximum is 30 characters)"])
    end
    it 'does not create category without empty is_income' do
      @category_params[:is_income] = nil
      post :create, params: {category: @category_params}
      expect(response).to have_http_status(:unprocessable_entity)      
      expect(JSON.parse(response.body)['message']['is_income']).to eq(["is not included in the list"])
    end
  end
  describe "PUT #update" do
    it 'updates category' do
      # Шинээр үүсгэсэн категороо өөрчлөхийг шалгах
      post :create, params: {category: @category_params}
      category_id = JSON.parse(response.body)['id']
      @category_params[:category_name] = 'edited name'
      put :update, params: {category: @category_params, id: category_id}
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['category_name']).to eq('edited name')
    end
    it 'does not update with empty params' do
      # Шинээр үүсгэсэн категороо өөрчлөхийг шалгах
      post :create, params: {category: @category_params}
      category_id = JSON.parse(response.body)['id']
      @category_params[:category_name] = ''
      put :update, params: {category: @category_params, id: category_id}
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['message']['category_name']).to eq(["can't be blank"])
    end
    it 'does not update without valid params' do
      post :create, params: {category: @category_params}
      category_id = JSON.parse(response.body)['id']
      @category_params[:category_name] = '1234567891234567891234567891234'
      put :update, params: {category: @category_params, id: category_id}
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['message']['category_name']).to eq(["is too long (maximum is 30 characters)"])
    end
  end
  describe "DELETE #destroy" do
    it 'deletes category' do
      post :create, params: {category: @category_params}
      category_id = JSON.parse(response.body)['id']
      delete :destroy, params: {id: category_id}
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['message']).to eq("Category is deleted")
    end
    it 'does not deletes other categories' do
      delete :destroy, params: {id: 1}
      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)['message']).to eq("unauthorized")
    end
  end
  describe "GET #getCategoryAmountByParam" do
    it 'gets category by date from and to' do
      analyse_params = {date_from: "2021-03-01", date_to: "2020-04-01"}
      post :getCategoryAmountByParam, params: analyse_params
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['income']).to eq([])
    end
    it 'gets category by transaction date' do
      analyse_params = {transaction_date: 123}
      post :getCategoryAmountByParam, params: analyse_params
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['income']).to eq([])
    end
    it 'gets category by number of days' do
      analyse_params = {number_of_days: 90}
      post :getCategoryAmountByParam, params: analyse_params
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['income']).to eq([])
    end
    it 'gets categories by number of days param in string' do
      analyse_params = {number_of_days: "123"}
      post :getCategoryAmountByParam, params: analyse_params
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['income']).to eq([])
    end
    it 'does not get categories without valid number of days param' do
      analyse_params = {number_of_days: "testtest"}
      post :getCategoryAmountByParam, params: analyse_params
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['message']).to eq("number_of_days can only be integer")
    end
  end
  describe "GET #default_category" do
    it 'gets default categories' do
      get :defaultAllCategory, params: {use_route: 'api/v1'}
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['income']).to eq([])
    end
  end
  describe "POST #getCategory" do
    it 'gets user categories' do
      post :getCategory
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['user']).to eq([])
    end
    it 'gets user categories' do
      post :getCategory
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['user']).to eq([])
    end
  end
end