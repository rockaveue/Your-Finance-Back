
class Api::V1::TransactionsController < ApplicationController

  # before_action :authorization
    
  # GET /users/:user_id/transactions
  # Хэрэглэгчийн бүх гүйлгээ авах
  def index
    # Pagy::VARS[:items]  = 2
    user = User.find_by_id(params[:user_id])
    transactions = Transaction
      .getTransactions(params, [true, false], false, 5)
    render json: transactions
  end

  # GET /users/:user_id/transaction/:id
  # Хэрэглэгчийн гүйлгээ сонгох
  def show
    user = User.find(params[:user_id])
    transaction = Transaction.find(params[:id])
    if user.id == transaction.user_id
      render json: transaction
    else
      render json: {message: transaction.errors}, status: 422
    end
  end

  # POST /users/:user_id/transaction
  # Гүйлгээ нэмэх
  def create
    user = User.find(params[:user_id])
    transaction = Transaction.new(transaction_params)
    transaction.user_id = params[:user_id]
    user_balance = user.balance
    ActiveRecord::Base.transaction do
      if transaction.save
        if params[:is_income] == true
          user_balance += params[:amount]
        else
          user_balance -= params[:amount]
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

  # PUT /users/:user_id/transaction/:id
  # Хэрэглэгчийн гүйлгээ өөрчлөх
  def update
    user = User.find(params[:user_id])
    transaction = Transaction.find(params[:id])
    ActiveRecord::Base.transaction do
      last_amount = transaction.amount
      last_type = transaction.is_income
      if transaction.update(transaction_params)
        user = User.find(params[:user_id])
        # хэрэглэгчийн баланс
        user_balance = user.balance
        # хуучин төрөл болон дүн
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

  # DELETE /users/:user_id/transaction/:id
  # Хэрэглэгчийн гүйлгээ устгах
  def destroy
    user = User.find(params[:user_id])
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

  # POST /users/:user_id/transactions/getTransactionsByBetweenDate
  # Хоёр он сарын хоорондох гүйлгээн мэдээлэл
  def getTransactionsByParam
    transactions = Transaction
      .getTransactions(params, [true, false], nil, 3)
    income, expense = transactions.partition{|v| v["is_income"]}
    grouped_income = income
      .group_by{|h| h["transaction_date"]}
      .map do |k,v| {
        :transaction_date => k.to_s,
        :amount => v.map {|h1| h1["amount"]}.inject(:+)
      }end
    total_income = grouped_income
      .map {|k| k[:amount]}
      .inject(:+)
    grouped_expense = expense
      .group_by{|h| h["transaction_date"]}
      .map do |k,v| {
        :transaction_date => k.to_s,
        :amount => v.map {|h1| h1["amount"]}.inject(:+)
      }end
    total_expense = grouped_expense
      .map {|k| k[:amount]}
      .inject(:+)
    render json: {
      income: [grouped_income, [{total_amount:total_income}]],
      expense: [grouped_expense, [{total_amount:total_expense}]],
      transactions: transactions
    }
  end

  # POST /users/:user_id/transactions/getTransactionsByDate
  # Оруулсан он сар дахь гүйлгээний мэдээлэл
  def getTransactionsByDate
    transactions = Transaction
      .getTransactions(params, [true, false], nil, 5)
    render json: transactions
  end

  private
  def transaction_params
      params.require(:transaction).permit(:user_id, :category_id, :is_income, :transaction_date, :amount, :is_repeat, :note)
  end
end
