require 'rails_helper'


RSpec.describe Api::V1::UsersController, type: :controller do
  @controller = Api::V1::UsersController.new
  before:each do
    @user = create(:user)
    @token = authenticated_header(@user)
    @user_params = attributes_for(:user)
    request.headers['Authorization'] = @token
  end
  let(:password_params) do
    {
      "current_password": @user.password,
      "password": 12345678,
      "password_confirmation": 12345678
    }
  end
  describe "GET #show" do
    it 'should return user data' do
      get :show
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['id']).to eq(@user.id)
    end
  end
  describe "PUT #update" do
    it 'should update the user' do
      @user_params[:first_name] = "dorj"
      put :update, params: {user: @user_params}
      expect(JSON.parse(response.body)['email']).to eq(@user.email)
      expect(response).to have_http_status(:success)
    end
    it 'should update the users first name with exactly 30 chars' do
      @user_params[:first_name] = "dorjasdjasdladjkdjakskssasdasd"
      put :update, params: {user: @user_params}
      expect(JSON.parse(response.body)['email']).to eq(@user.email)
      expect(response).to have_http_status(:success)
    end
    it 'shouldnt update the users first name with exceeded length' do
      @user_params[:first_name] = "dorjasdjasdladjkdjakskssasdasdsdss"
      put :update, params: {user: @user_params}
      expect(JSON.parse(response.body)['message']['first_name']).to eq(['is too long (maximum is 30 characters)'])
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
  describe "PATCH #update_password" do
    it 'should update the user password with current password' do
      patch :update_password, params: password_params
      expect((JSON.parse(response.body))['message']).to eq('Password has changed.')
      expect(response).to have_http_status(:success)
    end
    it 'shouldnt update the user password with wrong current password' do
      password_params[:current_password] = 1235661
      patch :update_password, params: password_params
      expect((JSON.parse(response.body))['message']).to eq("current_password" => ["is invalid"])
      expect(response).to have_http_status(:unprocessable_entity)
    end
    it 'shouldnt update the user password with wrong password confirmation' do
      password_params[:password_confirmation] = 1234567899
      patch :update_password, params: password_params
      expect((JSON.parse(response.body))['message']).to eq("password_confirmation" => ["doesn't match Password"])
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
  describe "DELETE #destroy" do
    it 'should delete user' do
      delete :destroy, params: {id: @user.id}
      expect((JSON.parse(response.body))['data']['is_deleted']).to eq(true)
      expect(response).to have_http_status(:success)
    end
  end
end