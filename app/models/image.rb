class Image < ApplicationRecord
  H5_LIVENESS_URL = 'https://openapi.faceid.com/lite/v1/do/'.freeze
  belongs_to :user
  enum gender: [:Female, :Male]

  def assign_to_user!
    self.user.current_image = self
    self.user.save!
  end

  def verify_url
    "#{H5_LIVENESS_URL}#{biz_token}"
  end
end
