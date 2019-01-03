class AddConversationIdToOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :orders, :conversation_id, :string
    add_column :orders, :message_id, :string
  end
end
