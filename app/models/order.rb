class Order < ApplicationRecord
  belongs_to :issuer, class_name: 'User'
  belongs_to :endpoint, class_name: 'User'

  WOHAOKANME_CLIENT_ID = ENV['WOHAOKANME_CLIENT_ID'] || Rails.application.secrets['wohaokanme_client_id']
  EOS_ASSET_ID = ENV['EOS_ASSET_ID'] || Rails.application.secrets['eos_asset_id']
  AMOUNT = '0.1'

  def mixin_pay_url
    "https://mixin.one/pay?recipient=#{WOHAOKANME_CLIENT_ID}&asset=#{EOS_ASSET_ID}&amount=#{AMOUNT}&trace=#{trace_id}&memo=打赏会全部转发给 Ta"
  end
end
