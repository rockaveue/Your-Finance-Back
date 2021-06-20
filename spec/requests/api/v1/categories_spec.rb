require 'rails_helper'

RSpec.describe Api::V1::CategoriesController, type: :controller do
  @controller = Api::V1::CategoriesController.new
  before :each do
    @user = create(:user)
    @token = authenticated_header(@user)
    @category_params = attributes_for(:category)
    @expected = {
      category_name: "test name"
    }
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
    end
    it 'does not create category without empty is_income' do
      @category_params[:is_income] = nil
      post :create, params: {category: @category_params}
      expect(response).to have_http_status(:unprocessable_entity)      
    end
  end
  describe "PUT #update" do
    it 'updates category' do
      # Шинээр үүсгэсэн категороо өөрчлөхийг шалгах
      post :create, params: {category: @category_params}
      id = JSON.parse(response.body)['id']
      @category_params[:category_name] = 'edited name'
      put :update, params: {category: @category_params, id: id}
      expect(response).to have_http_status(:success)
    end
  end
  describe "DELETE #destroy" do
    
  end
  describe "GET #getCategoryAmountByParam" do
    
  end
  describe "GET #default_category" do
    it 'gets default categories' do
      get :defaultAllCategory, params: {use_route: 'api/v1'}
      expect(response).to have_http_status(:success)
    end
  end
  describe "GET #transactionCategory" do
    
  end
  describe "POST #getCategory" do
    
  end
end


def authenticated_header(user)
  token = Warden::JWTAuth::UserEncoder.new.call(user, :api_v1_user, nil).first
  return "Bearer #{token}"
end