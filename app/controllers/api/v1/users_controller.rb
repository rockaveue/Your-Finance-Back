class Api::V1::UsersController < ApplicationController

  before_action :user_authorization

  # GET /users/:id
  # Хэрэглэгчийн сонгох
  def show
    user = User.find(params[:id])
    # cache middleware
    if stale?(last_modified: user.updated_at)
        render json: user
    end
  end

  # PUT /users/:id
  # Хэрэглэгч өөрчлөх
  def update
    user = User.find(params[:id])
    if user.update(user_params)
        render json: user
    else
        render json: {message: user.errors}, status: 422
    end
  end

  # POST /users/:id/soft_delete
  # Хэрэглэгч устгах
  def soft_delete
    user = User.find(params[:id])
    if user.update(is_deleted: true)
        render json: {message: 'User is deleted', data: user}
    else
        render json: {message: user.errors}, status: 422
    end
  end

  private
  def user_params
      params.require(:user).permit(:email, :password, :balance, :last_name, :first_name)
  end
end
