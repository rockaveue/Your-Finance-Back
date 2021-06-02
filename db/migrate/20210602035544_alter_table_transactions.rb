class AlterTableTransactions < ActiveRecord::Migration[6.1]
  def self.up
    change_table :transactions do |t|
      t.rename :transaction_type, :is_income
      t.boolean :is_deleted, default: false
    end
  end
  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
