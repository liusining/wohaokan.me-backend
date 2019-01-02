class CreateOrders < ActiveRecord::Migration[5.1]
  def change
    create_table :orders do |t|
      t.belongs_to :issuer, foreign_key: {to_table: :users}
      t.belongs_to :endpoint, foreign_key: {to_table: :users}
      t.string :trace_id
      t.boolean :is_paid
      t.boolean :contact_given
      t.boolean :money_delivered

      t.timestamps
    end
  end
end
