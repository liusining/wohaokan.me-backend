class ChangeDefaultsOfOrderColumns < ActiveRecord::Migration[5.1]
  def up
    change_column_default :orders, :is_paid, from: nil, to: false
    Order.where(is_paid: nil).each do |o|
      o.is_paid = false
      o.save!
    end
  end

  def down
    change_column_default :orders, :is_paid, from: false, to: nil
  end
end
