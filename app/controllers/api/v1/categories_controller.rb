class Api::V1::CategoriesController < ApplicationController
    before_action :add_to_blacklist
    
    # GET users/:user_id/transactions/:transactions_id/categories
    # Гүйлгээний категор авах
    def transactionCategory
        transaction = Transaction.find(params[:transaction_id])
        category = Category.find(transaction.category_id)
        render json: category
    end

    # GET /default_category
    # Default Category авах
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

    # GET users/:user_id/categories
    # Хэрэглэгчийн категор авах
    def index
        categories = Category.select('*').joins(:user_categories).where(:'user_categories.user_id' => params[:user_id])
        render json: categories
    end

    # POST users/:user_id/categories_by_type
    # 
    def getCategoryByType
        categories = Category.select('*').joins(:user_categories).where(:'user_categories.user_id' => params[:user_id], :category_type => params[:category_type])
        render json: categories
    end

    # POST users/:user_id/categories
    # Категор нэмэх
    def create
        categor = Category.new(category_params)
        if categor.save
            # token = user.generate_jwt
            userCategor = UserCategory.new(
                :category_id => categor.id,
                :user_id => params[:user_id]
            )
            if userCategor.save
                render json: {status: 'category created', data: categor.to_json}    
            else            
                render json: {errors: 'Алдаа гарлаа', data: userCategor.errors}, status: :unprocessable_entity
            end
        else
            render json: {errors: 'Алдаа гарлаа', data: categor.errors}, status: :unprocessable_entity
        end 
    end

    # PUT /users/:user_id/categories/:id
    # Категор өөрчлөх
    def update
        categor = Category.find(params[:id])
        if categor.update(category_params)
            render json: categor
        else
            render json: categor.errors, status: :unprocessable_entity
        end
    end
    
    # DELETE /users/:user_id/categories/:id
    # Категор устгах
    def destroy
        categor = Category.find(params[:id])
        categor.destroy
        render json: categor
    end


    # POST /users/:user_id/get_type_amount_by_date
    # Өдрөөр нийт дүнг ангиллаар авах
    def getAmountByType
        # render json: params[:transaction_date]
        # categor = Category.select('*').joins(:transactions)
        categor = Transaction.select('categories.id, categories.category_name, SUM(transactions.amount) as amount, transactions.transaction_date').joins(:category).where(:transaction_date => params[:transaction_date], :user_id => params[:user_id]).group(:category_id)
        render json: categor
    end
    private

    def category_params       
        params.require(:category).permit(:category_name, :category_type, :is_default)
    end
end
