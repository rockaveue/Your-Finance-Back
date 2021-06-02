class Api::V1::CategoriesController < ApplicationController

  before_action :user_authorization

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
    income = Category.where(is_default: true, is_income: true)
    expense = Category.where(is_default: true, is_income: false)
    render json: {"income" => income, "expense" => expense}
  end

  # POST users/:user_id/categories/getCategory
  # Хэрэглэгчийн категор авах, төрөл тусгавал төрлөөр авах
  def getCategory
    if params[:is_income].present?
        categories = Category.getUserCategories(params[:user_id]).where('is_income = ?', params[:is_income])
    else
        categories = Category.getUserCategories(params[:user_id])
    end
    render json: categories
  end

  # POST users/:user_id/categories
  # Категор нэмэх
  def create
    ActiveRecord::Base.transaction do
      category = Category.new(category_params)
      if category.save
        # token = user.generate_jwt
        userCategory = UserCategory.new(
          :category_id => category.id,
          :user_id => params[:user_id]
        )
        if userCategory.save
          render json: {status: 'category created', data: category.to_json}    
        else            
          render json: {errors: 'Алдаа гарлаа', data: userCategory.errors}, status: :unprocessable_entity
        end
      else
        render json: {errors: 'Алдаа гарлаа', data: category.errors}, status: :unprocessable_entity
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
      render json: category.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/:user_id/categories/:id
  # Категор устгах
  def destroy
    category = Category.find(params[:id])
    if category.update(is_deleted: true)
      render json: {message: "Устгагдлаа", category: category}
    else
      render json: category.errors
    end
  end

  # POST /users/:user_id/get_type_amount_by_date
  # Өдрөөр нийт дүнг ангиллаар авах
  def getAmountByType
    # render json: params[:transaction_date]
    # category = Category.select('*').joins(:transactions)
    category = Transaction.select('categories.id, categories.category_name, SUM(transactions.amount) as amount, transactions.transaction_date')
      .joins(:category)
      .where(:transaction_date => params[:transaction_date], 
            :user_id => params[:user_id])
      .group(:category_id)
    render json: category
  end
  private

  def category_params       
    params.require(:category).permit(:category_name, :is_income, :is_default)
  end
end
