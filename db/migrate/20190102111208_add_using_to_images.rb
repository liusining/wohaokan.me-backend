class AddUsingToImages < ActiveRecord::Migration[5.1]
  def up
    add_column :images, :using, :boolean
    User.where.not(current_image_id: nil).each do |u|
      u.current_image.using = true
      u.current_image.save!
    end
  end

  def down
    remove_column :images, :using
  end
end
