class AuthInfoService
  URL = "#{Rails.application.secrets.mixin_service}/auth_info".freeze

  def self.perform(auth_code, request_id)
    Rails.logger.tagged('AuthInfoService'.freeze) {|logger| logger.info "Applying for user authentication"}
    payload = {
      auth_code: auth_code,
      request_id: request_id
    }
    ret = RestClient.post(URL, payload) {|resp, _req, _result| resp}
    Rails.logger.tagged('AuthInfoService'.freeze) {|logger| logger.info "auth info response: #{ret}"}
    ret
  end
end