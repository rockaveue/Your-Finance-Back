namespace :transaction do
  desc 'Adding repeatable transactions into transaction table'
  task :repeat => [ :environment ] do
    currentDate = Date.today.to_s
    currentDay = currentDate[8..9]
    repeatableTransactions = Transaction.where(is_repeat: true).where('extract(day   from transaction_date) = ?', currentDay).select(Transaction.attribute_names - ['id'])
    if repeatableTransactions.present?
      repeatableTransactions.each do |t|
        user = User.find(t.user_id)
        user_balance = user.balance
        transaction = Transaction.new(t.attributes)
        transaction.transaction_date = currentDate
        transaction.is_repeat = false
        transaction.save
        if t.is_income == true
          user_balance += t.amount
        else
          user_balance -= t.amount
        end
        user.balance = user_balance
        user.save
      end 
    else 
      puts 'Error has occured'
    end
  end
end