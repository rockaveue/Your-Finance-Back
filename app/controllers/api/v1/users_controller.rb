class Api::V1::UsersController < ApplicationController

    # respond_to :json
    # GET /users
    def index
        users = User.all
        render json: {data: users}
        # json_response(@users)
    end

    # GET /users/:id
    def show
        user = User.find(params[:id])
        # cache middleware
        if stale?(last_modified: user.updated_at)
            render json: {status: 'success', data: user}
        end
    end
    # POST /users
    def create
        user = User.new(user_params)
        if user.save
            render json: {message: 'Хадгалагдсан', data: user}
        else
            render json: {message: 'Алдаа гарлаа', data: user.errors}, status: :unprocessable_entity
        end 
    end
    # PUT /users/:id
    def update
        user = User.find(params[:id])
        if user.update(user_params)
            render json: {message: "Өөрчлөгдсөн", data: user}
        else
            render json: {message: 'Алдаа гарлаа', data: user.errors}, status: :unprocessable_entity
        end
    end
    # DELETE /users/:id
    def destroy
        user = User.find(params[:id])
        user.destroy
        render json: {message: 'Устгагдсан', data: user}
    end

    private
    def user_params
        params.require(:user).permit(:email, :password, :balance, :last_name, :first_name)
    end
end
