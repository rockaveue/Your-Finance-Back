class CreateTransactions < ActiveRecord::Migration[6.1]
  def change
    create_table :transactions do |t|
      t.references :category, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.boolean :transaction_type
      t.date :transaction_date
      t.float :amount
      t.boolean :is_repeat
      t.string :note

      t.timestamps
    end
  end
end
