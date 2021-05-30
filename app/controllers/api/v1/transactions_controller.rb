class Api::V1::TransactionsController < ApplicationController
    before_action :process_token
    
    # GET /users/:id/transactions
    def index
        # ApplicationController.process_token
        user = User.find_by_id(params[:user_id])
        transactions = Transaction.where(:user_id => user.id)
        render json: transactions
    end

    private
    def transaction_params
        params.require(:transaction).permit(:category_id, :user_id, :transaction_type, :transaction_date, :amount, :is_repeat, :note)
    end
end
