class AddImageNoToImages < ActiveRecord::Migration[5.1]
  def change
    # NOTE: there is no need to use image_no, since face++ will return biz_token
    add_column :images, :image_no, :string, limit: 30
    change_column :images, :biz_token, :string, limit: 50
    add_index :images, :biz_token, unique: true
    add_column :images, :verify_msg, :string
  end
end
