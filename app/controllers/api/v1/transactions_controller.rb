
class Api::V1::TransactionsController < ApplicationController

  before_action :authorization
    
  # GET /users/:user_id/transactions
  # Хэрэглэгчийн бүх гүйлгээ авах
  def index
    # Pagy::VARS[:items]  = 2
    user = User.find_by_id(params[:user_id])
    return render json: { 'message' => 'Хэрэглэгч олдсонгүй'}, status: 404 unless user
    transactions = Transaction
      .getTransactions(params, 0, [true, false], false)
      .select('*')
    return render json: { 'message' => 'Хэрэглэгчийн гүйлгээ олдсонгүй'}, status: 404 unless transactions
    render json: transactions
  end

  # GET /users/:user_id/transaction/:id
  # Хэрэглэгчийн гүйлгээ сонгох
  def show
    user = User.find(params[:user_id])
    return render json: { 'message' => 'Хэрэглэгч олдсонгүй'}, status: 404 unless user
    transaction = Transaction.find(params[:id])
    return render json: { 'message' => 'Хэрэглэгчийн гүйлгээ олдсонгүй'}, status: 404 unless transaction

    if user.id == transaction.user_id
      render json: transaction
    else
      render json: "Aldaa", status: :unauthorized
    end
  end

  # POST /users/:user_id/transaction
  # Гүйлгээ нэмэх
  def create
    user = User.find(params[:user_id])
    return render json: { 'message' => 'Хэрэглэгч олдсонгүй'}, status: 404 unless user
    transaction = Transaction.new(transaction_params)
    transaction.user_id = params[:user_id]
    # render json: transaction    
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
          render json: transaction.to_json
        else
          render json: user.errors.full_messages
        end
      else
        render json: transaction.errors.full_messages, status: :unprocessable_entity
      end
    rescue ActiveRecord::RecordInvalid
      render json: {"message": transaction.errors.full_messages}, status: :unprocessable_entity
    end
  end

  # PUT /users/:user_id/transaction/:id
  # Хэрэглэгчийн гүйлгээ өөрчлөх
  def update
    user = User.find(params[:user_id])
    return render json: { 'message' => 'Хэрэглэгч олдсонгүй'}, status: 404 unless user
    transaction = Transaction.find(params[:id])
    return render json: { 'message' => 'Хэрэглэгчийн гүйлгээ олдсонгүй'}, status: 404 unless transaction

    ActiveRecord::Base.transaction do
      last_amount = transaction.amount
      last_type = transaction.is_income
      if transaction.update(transaction_params)
        user = User.find(params[:user_id])
        # хэрэглэгчийн баланс
        user_balance = user.balance
        # хуучин төрөл болон дүн
        # хуучин төрөл шинэ төрөлтэй ижил байвал
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
        
        render json: transaction.to_json
      else
        render json: transaction.errors.full_messages, status: :unprocessable_entity
      end
    end
  end

  # POST /users/:user_id/transaction/:id/soft_delete
  # Хэрэглэгчийн гүйлгээ устгах
  def soft_delete
    user = User.find(params[:user_id])
    return render json: { 'message' => 'Хэрэглэгч олдсонгүй'}, status: 404 unless user
    transaction = Transaction.find(params[:id])
    return render json: { 'message' => 'Хэрэглэгчийн гүйлгээ олдсонгүй'}, status: 404 unless transaction
    
    ActiveRecord::Base.transaction do
      if transaction.is_income == true
        user.update(balance: user.balance - transaction.amount)
      else
        user.update(balance: user.balance + transaction.amount)
      end
      
      if transaction.update(is_deleted: true)
        render json: {message: "Устгагдлаа", transaction: transaction}
      else
        render json: transaction.errors.full_messages
      end
    end
  end

  # POST /users/:user_id/transactions/getTransactionsByDay
  # Өдрөөр анализ мэдээлэл авах
  def getTransactionsByDay
    income = Transaction
      .getTransactions(params, true, true)
      .select('transaction_date, sum(amount) as amount')
      .as_json(:except => :id)
    total_income = Transaction
      .getTransactions(params, true, false)
      .select('sum(amount) as total_amount')
      .as_json(:except => :id)
    expense = Transaction
      .getTransactions(params, false, true)
      .select('transaction_date, sum(amount) as amount')
      .as_json(:except => :id)
    total_expense = Transaction
      .getTransactions(params, false, false)
      .select('sum(amount) as total_amount')
      .as_json(:except => :id)
    transactions = Transaction
      .getTransactions(params, [true, false], false)
      .select('*')
      .order(transaction_date: :desc)
    render json: {
      "income" => [income, total_income],
      "expense" => [expense, total_expense]
    }
  end

  # POST /users/:user_id/transactions/getTransactionsByBetweenDate
  # Хоёр он сарын хоорондох гүйлгээн мэдээлэл
  def getTransactionsByBetweenDate
    income = Transaction
      .getTransactions(params, true, true)
      .select('transaction_date, sum(amount) as amount')
      .as_json(:except => :id)
    total_income = Transaction
      .getTransactions(params, true, false)
      .select('sum(amount) as total_amount')
      .as_json(:except => :id)
    expense = Transaction
      .getTransactions(params, false, true)
      .select('transaction_date, sum(amount) as amount')
      .as_json(:except => :id)
    total_expense = Transaction
      .getTransactions(params, false, false)
      .select('sum(amount) as total_amount')
      .as_json(:except => :id)
    transactions = Transaction
      .getTransactions(params, [true, false], false)
      .order(transaction_date: :desc)
    render json: {
      "income" => [income, total_income],
      "expense" => [expense, total_expense]
    }
  end

  # POST /users/:user_id/transactions/getTransactionsByDate
  # Оруулсан он сар дахь гүйлгээний мэдээлэл
  def getTransactionsByDate
    income = Transaction
      .getTransactions(params, true, false)
    expense = Transaction
      .getTransactions(params, false, false)
    render json: {
      "income" => income,
      "expense" => expense
    }
  end

  private
  def transaction_params
      params.require(:transaction).permit(:category_id, :is_income, :transaction_date, :amount, :is_repeat, :note)
  end
end
