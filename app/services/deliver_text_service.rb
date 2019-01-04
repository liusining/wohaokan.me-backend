class DeliverTextService
  URL = "#{Rails.application.secrets['mixin_service']}/deliver_text".freeze

  def initialize(user, text, request_id)
    @user = user
    @text = text
    @request_id = request_id
  end

  def perform
    Rails.logger.tagged(self.class.to_s.freeze) {|logger| logger.info "texting user##{@user.id}"}
    start_time = Time.now
    payload = {
      mixin_uid: @user.mixin_uid,
      msg: @text,
      request_id: @request_id
    }
    resp = RestClient.post(URL, payload) {|res, _req, _result| res}
    Rails.logger.tagged(self.class.to_s.freeze) {|logger| logger.info "response: #{resp}"}
    Rails.logger.tagged(self.class.to_s.freeze) {|logger| logger.info "time used: #{Time.now - start_time}"}
  end
end