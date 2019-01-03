class DeliverContactService
  URL = "#{Rails.application.secrets['mixin_service']}/deliver_contact"

  def initialize(order, request_id)
    @order = order
    @request_id = request_id
  end

  def perform
    Rails.logger.tagged(self.class.to_s.freeze) {|logger| logger.info ""}
    start_time = Time.now
    params = {
      mixin_uid: @order.issuer.mixin_uid,
      contact_id: @order.endpoint.mixin_uid,
      request_id: @request_id
    }
    resp = RestClient.post(URL, params) {|res, _req, _result| res}
    Rails.logger.tagged(self.class.to_s.freeze) {|logger| logger.info "response: #{resp}"}
    Rails.logger.tagged(self.class.to_s.freeze) {|logger| logger.info "time used: #{Time.now - start_time}s"}
    resp_hash = JSON.parse(resp.body)
    [resp_hash['conversation_id'], resp_hash['message_id']]
  end
end