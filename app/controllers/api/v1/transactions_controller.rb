
class Api::V1::TransactionsController < ApplicationController
  before_action :transaction_authorization, only: [:show, :update, :destroy]
  # GET /users/transactions
  # Хэрэглэгчийн бүх гүйлгээ авах
  def index
    transactions = Transaction
      .getTransactions(transactions_analyse_params, 5, current_api_v1_user.id)
    render json: transactions
  end
  # GET /users/transaction/:id
  # Хэрэглэгчийн гүйлгээ сонгох
  def show
    user = User.find(current_api_v1_user.id)
    transaction = Transaction.find(params[:id])
    if user.id == transaction.user_id
      render json: transaction
    else
      render json: {message: transaction.errors}, status: 422
    end
  end
  # POST /users/transaction
  # Гүйлгээ нэмэх
  def create
    user = User.find(current_api_v1_user.id)
    transaction = Transaction.new(transaction_params)
    transaction.user_id = current_api_v1_user.id
    user_balance = user.balance
    ActiveRecord::Base.transaction do
      if transaction.save
        if transaction.is_income == true
          user_balance += transaction.amount
        else
          user_balance -= transaction.amount
        end
        user.balance = user_balance
        if user.save
          render json: transaction
        else
          render json: {message: user.errors}, status: 422
        end
      else
        render json: {message: transaction.errors}, status: 422
      end
    end
  end
  # PUT /users/transaction/:id
  # Хэрэглэгчийн гүйлгээ өөрчлөх
  def update
    user = User.find(current_api_v1_user.id)
    transaction = Transaction.find(params[:id])
    ActiveRecord::Base.transaction do
      last_amount = transaction.amount
      last_type = transaction.is_income
      if transaction.update(transaction_params)
        user = User.find(current_api_v1_user.id)
        # хэрэглэгчийн баланс
        user_balance = user.balance
        # хуучин төрөл шинэ төрөлтэй ижил байвал
        if params[:is_income].present?
          if last_type == params[:is_income]
            # төрөл нь орлого бол
            if params[:is_income] == true
              # одоогийн дүнгээс хуучин дүнг хасаж баланс дээр нэмнэ
              user.update(balance: user_balance + (params[:amount] - last_amount))
            else
              user.update(balance: user_balance - (params[:amount] - last_amount))
            end
          else
            if params[:is_income] == true
              user.update(balance: user_balance + (params[:amount] + last_amount))
            else
              user.update(balance: user_balance - (params[:amount] + last_amount))
            end
          end
        end
        render json: transaction.to_json
      else
        render json: {message: transaction.errors}, status: 422
      end
    end
  end
  # DELETE /users/transaction/:id
  # Хэрэглэгчийн гүйлгээ устгах
  def destroy
    user = User.find(current_api_v1_user.id)
    transaction = Transaction.find(params[:id])
    ActiveRecord::Base.transaction do
      if transaction.is_income == true
        user.update(balance: user.balance - transaction.amount)
      else
        user.update(balance: user.balance + transaction.amount)
      end
      if transaction.update(is_deleted: true)
        render json: {message: "transaction is deleted", transaction: transaction}
      else
        render json: {message: transaction.errors}, status: 422
      end
    end
  end
  # POST /users/transactions/getTransactionsByBetweenDate
  # Хоёр он сарын хоорондох гүйлгээн мэдээлэл
  def getTransactionsByParam
    transactions = Transaction
      .getTransactions(transactions_analyse_params, 5, current_api_v1_user.id)
    income, expense = Transaction
      .partition_by_is_income(transactions)
    grouped_income = Transaction
      .group_by_date(income)
    total_income = Transaction
      .map_inject_amount(grouped_income)
    grouped_expense = Transaction
      .group_by_date(expense)
    total_expense = Transaction
      .map_inject_amount(grouped_expense)
    render json: {
      income: [grouped_income, [{total_amount:total_income}]],
      expense: [grouped_expense, [{total_amount:total_expense}]],
      transactions: transactions
    }
  end
  # POST /users/transactions/getTransactionsByDate
  # Оруулсан он сар дахь гүйлгээний мэдээлэл
  def getTransactionsByDate
    transactions = Transaction
      .getTransactions(transactions_analyse_params, 5, current_api_v1_user.id)
    render json: transactions
  end
  private
  def transaction_params
      params.require(:transaction).permit(:user_id, :category_id, :is_income, :transaction_date, :amount, :is_repeat, :note)
  end
  def transactions_analyse_params
    params.permit(:date_from, :date_to, :number_of_days, :transaction_date, :user_id)
  end
end