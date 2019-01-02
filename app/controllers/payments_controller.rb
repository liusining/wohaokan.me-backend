class PaymentsController < ApplicationController
  before_action :check_params, only: [:like_others]
  before_action :load_user, only: [:like_others]

  def like_others
    endpoint = User.find_by_uid(params[:user_id])
    unless endpoint.present?
      format_render(400, 'target user is not found')
      return
    end
    order = Order.create!(issuer: current_user, endpoint: endpoint, trace_id: UUIDTools::UUID.timestamp_create.to_s)
    result = { pay_url: order.mixin_pay_url,
               amount: Order::AMOUNT,
               asset_id: Order::EOS_ASSET_ID,
               opponent_id: Order::WOHAOKANME_CLIENT_ID,
               trace_id: order.trace_id }
    format_render(200, 'OK', result)
  end

  end

  private

  def check_params
    params.require(:user_id)
  end
end
