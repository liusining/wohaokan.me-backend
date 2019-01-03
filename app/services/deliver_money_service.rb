class DeliverMoneyService
  URL = "#{Rails.application.secrets['mixin_service']}/deliver_money"

  def initialize(order, request_id)
    @order = order
    @request_id = request_id
  end

  def perform
    Rails.logger.tagged(self.class.to_s.freeze) {|logger| logger.info "delivering money received in order##{@order.id}"}
    start_time = Time.now
    params = {
      asset_id: Order::EOS_ASSET_ID,
      endpoint: @order.endpoint.mixin_uid,
      amount: Order::AMOUNT,
      memo: "#{@order.issuer.name}（#{@order.issuer.mixin_id}）喜欢了您，并打赏 0.1 EOS",
      request_id: @request_id
    }
    resp = RestClient.post(URL, params) {|res, _req, _result| res}
    Rails.logger.tagged(self.class.to_s.freeze) {|logger| logger.info "response: #{resp}"}
    Rails.logger.tagged(self.class.to_s.freeze) {|logger| logger.info "time used: #{Time.now - start_time}s"}
    JSON.parse(resp.body)['trace_id']
  end
end