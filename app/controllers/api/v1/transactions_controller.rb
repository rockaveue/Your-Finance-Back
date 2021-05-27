
class Api::V1::TransactionsController < ApplicationController
    # before_action :decode_token
    
    # GET /users/:id/transactions
    # Хэрэглэгчийн бүх гүйлгээ авах
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
    # Гүйлгээ нэмэх
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

    # DELETE /users/:user_id/transaction/:id
    # Хэрэглэгчийн гүйлгээ устгах
    def destroy
        transaction = Transaction.find(params[:id])
        transaction.destroy
        render json: transaction
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

    private
    def transaction_params
        params.require(:transaction).permit(:category_id, :user_id, :transaction_type, :transaction_date, :amount, :is_repeat, :note)
    end
end
