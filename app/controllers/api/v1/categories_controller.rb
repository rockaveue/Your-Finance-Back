class Api::V1::CategoriesController < ApplicationController
    
    # GET users/:user_id/transactions/:transactions_id/categories
    # Гүйлгээний категор авах
    def show
        transaction = Transaction.find(params[:transaction_id])
        category = Category.find(transaction.category_id)
        render json: category
    end

    def defaultAllCategory
        expense = Array.new
        income = Array.new
        Category.all.each do |category|
            if category.is_default == true
                if category.category_type == true
                    income.append(category)
                else
                    expense.append(category)                   
                end
            end
        end
        categories = {
            "Орлого" => income,
            "Зарлага" => expense,
        }

        render json: categories
    end
end
