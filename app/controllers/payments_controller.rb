class PaymentsController < ApplicationController
  before_action :check_params, only: [:like_others, :check_order]
  before_action :load_user, only: [:like_others, :check_order]

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

  def check_order
    order = Order.find_by(trace_id: params[:trace_id], is_paid: false)
    if !order.present? || order.issuer_id != current_user.id
      render json: {error: "the order doesn't exist"}, status: 400
      return
    end
    valid = CheckTransferService.new(current_user, order).perform
    unless valid
      format_render(400, 'invalid payment')
      return
    end
    order.update!(is_paid: true)
    format_render(200, 'OK', {mixin_id: order.endpoint.mixin_id.to_s})
  end

  private

  def check_params
    if params[:action] == 'like_others'
      params.require(:user_id)
    end
    if params[:action] == 'check_order'
      params.require(:trace_id)
    end
  end
end
