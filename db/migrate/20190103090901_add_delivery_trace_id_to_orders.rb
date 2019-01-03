class AddDeliveryTraceIdToOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :orders, :delivery_trace_id, :string
  end
end
