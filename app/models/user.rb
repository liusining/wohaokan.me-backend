class User < ApplicationRecord
  belongs_to :current_image, class_name: 'Image', optional: true
  delegate :signed_url, to: :current_image, prefix: 'image', allow_nil: true
  delegate :gender, :beauty, to: :current_image, allow_nil: true

  INVITATION_MSG = '点击 wohaokan.me/personalHome/info，你也可以参与「我好看么」'.freeze

  before_create :init_uid

  def self.init_from_mixin(mixin)
    mixin_id          = mixin['identity_number'].to_i
    user              = find_by_mixin_id(mixin_id) || new(mixin_id: mixin_id)
    user.session_key  = SecureRandom.base58(24)
    user.avatar_url   = mixin['avatar_url']
    user.mixin_name   = mixin['full_name']
    user.access_token = mixin['access_token']
    user.pin_token    = mixin['pin_token'] unless mixin['pin_token'].blank?
    user.scope        = mixin['scope']
    user.session_id   = mixin['session_id']
    user.mixin_uid    = mixin['user_id']
    user.save!
    user
  end

  def name
    if nickname.blank?
      mixin_name
    else
      nickname
    end
  end

  def age
    if super
      super
    elsif current_image
      current_image.age
    else
      0
    end
  end

  def likes_count
    Order.where(endpoint_id: current_user.id, money_delivered: true).count
  end

  private

  def init_uid
    self.uid = SecureRandom.base58(24)
  end
end
