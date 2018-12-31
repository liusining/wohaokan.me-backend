class AddS3KeyToImages < ActiveRecord::Migration[5.1]
  def change
    add_column :images, :s3_key, :string
  end
end
