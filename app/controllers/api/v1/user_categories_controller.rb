class Api::V1::UserCategoriesController < ApplicationController

    # GET users/:user_id/categories
    # Хэрэглэгчийн категор авах
    def index
        categories = UserCategory.where(:user_id => params[:user_id])
        render json: categories
    end
end
