class CreateImages < ActiveRecord::Migration[5.1]
  def change
    create_table :images do |t|
      t.string :url
      t.float :beauty
      t.integer :gender
      t.integer :age

      t.timestamps
    end
  end
end
