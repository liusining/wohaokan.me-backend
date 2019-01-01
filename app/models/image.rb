class Image < ApplicationRecord
  belongs_to :user
  enum gender: [:Female, :Male]

  def assign_to_user!
    self.user.current_image = img
    self.user.save!
  end
end
