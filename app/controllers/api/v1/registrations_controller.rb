class Api::V1::RegistrationsController < Devise::RegistrationsController
    def create
        user = User.new(user_params)
        if user.save
            token = user.generate_jwt
            render json: token.to_json
        else
            render json: {errors: 'Алдаа гарлаа', data: user.errors}, status: :unprocessable_entity
        end 
    end

    private 
    
    private
    def user_params
        params.require(:user).permit(:email, :password, :balance, :last_name, :first_name)
    end
end