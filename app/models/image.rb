class Image < ApplicationRecord
  belongs_to :user
  enum gender: [:Female, :Male]
end
