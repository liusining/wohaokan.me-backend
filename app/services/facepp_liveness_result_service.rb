class FaceppLivenessResultService
  URL = 'https://openapi.faceid.com/lite/v1/get_result'.freeze

  def self.perform(img_obj)
    Rails.logger.tagged('FaceppLivenessResultService'.freeze) {|logger| logger.info "begin retrieving liveness result"}
    start_time = Time.now
    signature = FaceppApiSignService.perform
    params = {
      biz_token: img_obj.biz_token,
      sign: signature,
      sign_version: 'hmac_sha1'
    }
    resp = RestClient.get(URL, {params: params}) {|res, _req, _result| JSON.parse(res.body)}
    # TODO: save best images
    Rails.logger.tagged('FaceppLivenessResultService'.freeze) {|logger| logger.info "face++ response: #{resp.except('images')}"}
    Rails.logger.tagged('FaceppLivenessResultService'.freeze) {|logger| logger.info "time used: #{Time.now - start_time}s"}
    return [resp['result_code'], resp['result_message']]
  end
end