class Api::V1::SessionsController < ApplicationController
    def create
        user = User.find_by_email(params[:email])
        # render json: user
        if user && user.valid_password?(params[:password])
            token = user.generate_jwt
            render json: token.to_json
        else
            render json: { errors: 'email эсвэл password буруу байна'}, status: :unprocessable_entity
        end
    end
    def destroy
        
    end
end