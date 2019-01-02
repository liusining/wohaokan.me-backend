class AddUidToUsers < ActiveRecord::Migration[5.1]
  def up
    add_column :users, :uid, :string, limit: 30
    User.all.each do |u|
      u.uid = SecureRandom.base58(24)
      u.save!
    end
    add_index :users, :uid, unique: true
  end

  def down
    remove_index :users, :uid
    remove_column :users, :uid
  end
end
