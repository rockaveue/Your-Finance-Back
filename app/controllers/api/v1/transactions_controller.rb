
class Api::V1::TransactionsController < ApplicationController
    before_action :decode_token
    
    # GET /users/:id/transactions
    # Хэрэглэгчийн гүйлгээ авах
    def index
        # Pagy::VARS[:items]  = 2
        user = User.find_by_id(params[:user_id])
        transactions = Transaction.select('*').joins(:category).where(:user_id => user.id)

        render json: transactions
    end

    # GET /users/:id/transaction/:id
    # Хэрэглэгчийн гүйлгээ сонгох
    def show
        user = User.find(params[:user_id])
        transaction = Transaction.find(params[:id])
        if user.id == transaction.user_id
            render json: transaction
        else
            render json: "Aldaa", status: :unauthorized
        end
    end
    
    # POST /users/:id/transaction
    # 
    def create
        transaction = Transaction.new(transaction_params)
        if transaction.save
            render json: transaction.to_json
        else
            render json: transaction.errors, status: :unprocessable_entity
        end 
    end
    
    # PUT /users/:user_id/transaction/:id
    # Хэрэглэгчийн гүйлгээ өөрчлөх
    def update
        transaction = Transaction.find(params[:id])
        if transaction.update(transaction_params)
            render json: transaction
        else
            render json: transaction.errors, status: :unprocessable_entity
        end
    end

    def destroy
        transaction = Transaction.find(params[:id])
        transaction.destroy
        render json: transaction
    end

    private
    def transaction_params
        params.require(:transaction).permit(:category_id, :user_id, :transaction_type, :transaction_date, :amount, :is_repeat, :note)
    end
end
