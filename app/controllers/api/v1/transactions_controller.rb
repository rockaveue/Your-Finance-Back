
class Api::V1::TransactionsController < ApplicationController

  # before_action :authorization
    
  # GET /users/:user_id/transactions
  # Хэрэглэгчийн бүх гүйлгээ авах
  def index
    # Pagy::VARS[:items]  = 2
    user = User.find_by_id(params[:user_id])
    return render json: { 'message' => 'Хэрэглэгч олдсонгүй'}, status: 404 unless user
    transactions = Transaction.select('*').joins(:category).where(:user_id => user.id)
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
        if params[:transaction_type] == true
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
      last_type = transaction.transaction_type
      if transaction.update(transaction_params)
        user = User.find(params[:user_id])
        # хэрэглэгчийн баланс
        user_balance = user.balance
        # хуучин төрөл болон дүн
        # хуучин төрөл шинэ төрөлтэй ижил байвал
        if last_type == params[:transaction_type]
          # төрөл нь орлого бол
          if params[:transaction_type] == true
            # одоогийн дүнгээс хуучин дүнг хасаж баланс дээр нэмнэ
            user.update(balance: user_balance + (params[:amount] - last_amount))
          else
            user.update(balance: user_balance - (params[:amount] - last_amount))
          end
        else
          if params[:transaction_type] == true
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
      if transaction.transaction_type == true
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

  # POST /users/:user_id/get_data_by_date
  # Өдрөөр анализ мэдээлэл авах
  def getDataByDate
    # Орлого авч байгаа хэсэг
    income = Transaction.select('transaction_date, sum(amount) as amount')
      .where(:user_id => params[:user_id])
      .where(:transaction_type => 1)
      .where('DATE(transaction_date) BETWEEN ? AND ?', params[:number_of_days].days.ago, Time.now)
      .group(:transaction_date).as_json(:except => :id)

    total_income = Transaction.select('sum(amount) as total_amount')
      .where(:user_id => params[:user_id])
      .where(:transaction_type => 1)
      .where('DATE(transaction_date) BETWEEN ? AND ?', params[:number_of_days].days.ago, Time.now).as_json(:except => :id)
    
    # Зарлага авч байгаа хэсэг
    expense = Transaction
      .select('transaction_date, sum(amount) as amount')
      .where(:user_id => params[:user_id])
      .where(:transaction_type => 0)
      .where('DATE(transaction_date) BETWEEN ? AND ?', params[:number_of_days].days.ago, Time.now)
      .group(:transaction_date).as_json(:except => :id)
    
    total_expense = Transaction
      .select('sum(amount) as total_amount')
      .where(:user_id => params[:user_id])
      .where(:transaction_type => 0)
      .where('DATE(transaction_date) BETWEEN ? AND ?', params[:number_of_days].days.ago, Time.now).as_json(:except => :id)
    
    user = User.find(params[:user_id])
        
    transactions = Transaction.select('*')
      .where(:user_id => params[:user_id])
      .where('DATE(transaction_date) BETWEEN ? AND ?', params[:number_of_days].days.ago, Time.now)
      .order(transaction_date: :desc)

    balance = user.balance
    balanceArray = Array.new
    transactions.each do |transaction|
      if transaction.transaction_type == true
        balance -= transaction.amount
      else
        balance += transaction.amount
      end
      balanceArray.append({"balance" => balance, "date" => transaction.transaction_date})
    end

    # render json: transactions
    # balance
    render json: {"income" => [income, total_income], "expense" => [expense, total_expense], "balance" => balanceArray}
  end

  # POST /users/:user_id/get_data_by_between_date
  # Хоёр он сарын хоорондох гүйлгээн мэдээлэл
  def getDataByBetweenDate
    # Орлого авч байгаа хэсэг
    income = Transaction.select('transaction_date, sum(amount) as amount')
      .where(:user_id => params[:user_id])
      .where(:transaction_type => 1)
      .where('DATE(transaction_date) BETWEEN ? AND ?', params[:date_from], params[:date_to])
      .group(:transaction_date).as_json(:except => :id)

    total_income = Transaction.select('sum(amount) as total_amount')
      .where(:user_id => params[:user_id])
      .where(:transaction_type => 1)
      .where('DATE(transaction_date) BETWEEN ? AND ?', params[:date_from], params[:date_to]).as_json(:except => :id)
    
    # Зарлага авч байгаа хэсэг
    expense = Transaction
      .select('transaction_date, sum(amount) as amount')
      .where(:user_id => params[:user_id])
      .where(:transaction_type => 0)
      .where('DATE(transaction_date) BETWEEN ? AND ?', params[:date_from], params[:date_to])
      .group(:transaction_date).as_json(:except => :id)
    
    total_expense = Transaction
      .select('sum(amount) as total_amount')
      .where(:user_id => params[:user_id])
      .where(:transaction_type => 0)
      .where('DATE(transaction_date) BETWEEN ? AND ?', params[:date_from], params[:date_to]).as_json(:except => :id)
    
    user = User.find(params[:user_id])
    return render json: { 'message' => 'Хэрэглэгч олдсонгүй'}, status: 404 unless user

    transactions = Transaction.select('*')
      .where(:user_id => params[:user_id])
      .where('DATE(transaction_date) BETWEEN ? AND ?', params[:date_from], params[:date_to])
      .order(transaction_date: :desc)

    balance = user.balance
    balanceArray = Array.new
    transactions.each do |transaction|
      if transaction.transaction_type == true
          balance -= transaction.amount
      else
          balance += transaction.amount
      end
      balanceArray.append({"balance" => balance, "date" => transaction.transaction_date})
    end

    # render json: transactions
    # balance

    render json: {"income" => [income, total_income], "expense" => [expense, total_expense], "balance" => balanceArray}
  end

  def date_transactions
      
    income = Transaction.select('*').where(:transaction_date => params[:transaction_date])
      .where(:transaction_type => 1)

    expense = Transaction.select('*').where(:transaction_date => params[:transaction_date])
      .where(:transaction_type => 0)
    transactions = {
      "income" => income,
      "expense" => expense,
    }
    render json:transactions
  end

  private
  def transaction_params
      params.require(:transaction).permit(:category_id, :is_income, :transaction_date, :amount, :is_repeat, :note)
  end
end
