class AddVerifiedToImages < ActiveRecord::Migration[5.1]
  def change
    add_column :images, :verified, :boolean
    add_column :images, :biz_token, :string
  end
end
