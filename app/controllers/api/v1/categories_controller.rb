class Api::V1::CategoriesController < ApplicationController

  before_action :category_authorization, only: [:update, :destroy]
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
    categories = Category
      .is_default_and_not_deleted
    income, expense = Transaction
      .partition_by_is_income(categories)
    render json: {
      income: income, 
      expense: expense
    }
  end
  
  # POST users/:user_id/categories/getCategory
  # Хэрэглэгчийн категор авах, төрөл тусгавал төрлөөр авах
  def getCategory
    categories = Category
      .getUserCategories(category_analyse_params, current_api_v1_user.id)
    default_category = Category
      .is_default_and_not_deleted
    income, expense = Transaction
      .partition_by_is_income(default_category)
    
    render json: {user: categories, default: [income, expense]}
  end

  # POST users/:user_id/categories
  # Категор нэмэх
  def create
    ActiveRecord::Base.transaction do
      category = Category.new(category_params)
      user_categories = Category.getUserCategories(category_params, current_api_v1_user.id)
      user_categories_name = user_categories.map {|v| v.category_name}
      if !category_params[:category_name].in? user_categories_name
        if category.save
          userCategory = UserCategory.new(
            :category_id => category.id,
            :user_id => current_api_v1_user.id
          )
          if userCategory.save
            render json: category  
          else            
            render json: {message: userCategory.errors}, status: 422
          end
        else
          render json: {message: category.errors}, status: 422
        end 
      else
        render json: {message: "Duplicate category name"}, status: 422
      end
    end
  end

  # PUT /users/:user_id/categories/:id
  # Категор өөрчлөх
  def update
    category = Category.find(params[:id])
    if category.update(category_params)
      render json: category
    else
      render json: {message: category.errors}, status: 422
    end
  end

  # DELETE /users/:user_id/categories/:id
  # Категор устгах
  def destroy
    category = Category.find(params[:id])
    transactions = Transaction.getTransactions(category_analyse_params, nil, current_api_v1_user)
    ActiveRecord::Base.transaction do
      if category.update(is_deleted: true)
        if transactions.present?
          transactions.each do |transaction|
            category_id = transaction.is_income ? ENV['CATEGORY_OTHER_INCOME'].to_i : ENV['CATEGORY_OTHER_EXPENSE'].to_i
            transaction.update(category_id: category_id)
          end
        end
        render json: {message: "Category is deleted", category: category}
      else
        render json: {message: category.errors}, status: 422
      end
    end
  end

  # POST /users/:user_id/getCategoryAmountByDate
  # Оруулсан он сараар нийт дүнг ангиллаар авах
  # :transaction_date param оруулна
  # Хоёр он сарын хоорондох гүйлгээн дүнг ангиллаар авах
  # :date_from, :date_to оруулах
  # Өдрөөр нийт дүнг ангиллаар авах
  # :number_of_days оруулах
  def getCategoryAmountByParam
    transactions = Transaction
      .getTransactions(category_analyse_params, 4, current_api_v1_user.id)
    category_income, category_expense = Transaction
      .partition_by_is_income(transactions)
    income = Transaction
      .group_by_category_and_map(category_income)
    expense = Transaction
      .group_by_category_and_map(category_expense)
    render json: {
      income: income,
      expense: expense
    }
  end
  
  private

  def category_params       
    params.require(:category).permit(:category_name, :is_income)
  end
  def category_analyse_params
    params.permit(:date_from, :date_to, :number_of_days, :transaction_date, :user_id, :is_income, :id)
  end  
end
