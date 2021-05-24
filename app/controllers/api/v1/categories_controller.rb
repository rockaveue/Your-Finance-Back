class Api::V1::CategoriesController < ApplicationController
    
    # GET users/:user_id/transactions/:transactions_id/categories
    # Гүйлгээний категор авах
    def show
        transaction = Transaction.find(params[:transaction_id])
        category = Category.find(transaction.category_id)
        render json: category
    end
end
