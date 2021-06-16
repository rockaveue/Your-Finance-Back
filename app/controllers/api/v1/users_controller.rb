class Api::V1::UsersController < ApplicationController


  # GET /users/:id
  # Хэрэглэгчийн сонгох
  def show
    user = User.find(current_api_v1_user.id)
    # cache middleware
    if stale?(last_modified: user.updated_at)
        render json: user
    end
  end

  # PUT /users/:id
  # Хэрэглэгч өөрчлөх
  def update
    user = User.find(current_api_v1_user.id)
    if user.update(user_params)
        render json: user
    else
        render json: {message: user.errors}, status: 422
    end
  end

  # PATCH /users/:id
  def update_password
    @user = User.find(current_api_v1_user.id)
    if @user.update_with_password(password_params)
      # Sign in the user by passing validation in case their password changed
      bypass_sign_in(@user)
      render json: {message:"Password has changed."}
    else
      render json: {message: @user.errors}, status: 422
    end
  end

  # DELETE /users/:id
  # Хэрэглэгч устгах
  def destroy
    user = User.find(current_api_v1_user.id)
    if user.update(is_deleted: true)
        render json: {message: 'User is deleted', data: user}
    else
        render json: {message: user.errors}, status: 422
    end
  end

  private
  def password_params
      params.permit(:current_password, :password, :password_confirmation)
  end

  def user_params
      params.require(:user).permit(:email, :password, :balance, :last_name, :first_name)
  end
end
