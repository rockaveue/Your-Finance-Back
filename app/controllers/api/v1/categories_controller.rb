class Api::V1::CategoriesController < ApplicationController

  before_action :authorization, except: :defaultAllCategory
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
    # categories = Category.where(is_default: true)
    # render json: categories
    income = Category.where(is_default: true, is_income: true, is_deleted: false)
    expense = Category.where(is_default: true, is_income: false, is_deleted: false)
    render json: {"income" => income, "expense" => expense}
  end

  # POST users/:user_id/categories/getCategory
  # Хэрэглэгчийн категор авах, төрөл тусгавал төрлөөр авах
  def getCategory
    categories = Category.getUserCategories(params)
    
    income = Category.where(is_default: true, is_income: true, is_deleted: false)
    expense = Category.where(is_default: true, is_income: false, is_deleted: false)
    
    render json: {user: categories, default: [income, expense]}
  end

  # POST users/:user_id/categories
  # Категор нэмэх
  def create
    ActiveRecord::Base.transaction do
      category = Category.new(category_params)
      if category.save
        userCategory = UserCategory.new(
          :category_id => category.id,
          :user_id => params[:user_id]
        )
        if userCategory.save
          render json: {status: 'category created', data: category.to_json}    
        else            
          render json: {message: userCategory.errors}, status: 422
        end
      else
        render json: {message: category.errors}, status: 422
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
    return render json: { 'message' => 'Категор олдсонгүй'}, status: 404 unless category
    if category.update(is_deleted: true)
      render json: {message: "Category is deleted", category: category}
    else
      render json: {message: category.errors}, status: 422
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
    income = Transaction
      .getTransactions(params, true, 2, 4)
    expense = Transaction
      .getTransactions(params, false, 2, 4)
    render json: {
      income: income,
      expense: expense
    }
  end
  
  private

  def category_params       
    params.require(:category).permit(:category_name, :is_income, :is_default, :number_of_days, :date_from, :date_to)
  end
end
