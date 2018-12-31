class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :session_key, limit: 30, index: true
      t.string :avatar_url, default: ''
      t.string :mixin_name
      t.string :nickname
      t.string :description, default: ''
      t.integer :mixin_id, index: true
      t.belongs_to :current_image, foreign_key: { to_table: :images }
      t.string :access_token, limit: 500
      t.string :pin_token, default: ''
      t.string :scope, default: ''
      t.string :session_id, limit: 40
      t.string :mixin_uid, limit: 40
      t.integer :age

      t.timestamps
    end
  end
end
