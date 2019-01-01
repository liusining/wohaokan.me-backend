class FaceppBizTokenService
  WEB_HOST = ENV['WEB_HOST'] || Rails.application.secrets['web_host']
  API_HOST = ENV['API_HOST'] || Rails.application.secrets['api_host']

  def self.perform(img_obj, file)
    Rails.logger.tagged('FaceppBizTokenService'.freeze) {|logger| logger.info "begin applying for a face++ biz-token"}
    # reopen image file since it has been closed in the former step
    if file.tempfile.closed?
      file = File.new(file.tempfile)
    end
    # generate signature used in face++ api
    now = Time.now
    raw_data = "a=#{Rails.application.secrets['facepp_sdk_key']}&b=#{now.advance(minutes: 10).to_i}&c=#{now.to_i}&d=#{rand(1000000000..9999999999)}"
    Rails.logger.tagged('FaceppBizTokenService'.freeze) {|logger| logger.info "signature raw data: #{raw_data}"}
    hmac = OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha1'), Rails.application.secrets['facepp_sdk_secret'], raw_data)
    signature = Base64.strict_encode64(hmac + raw_data)
    # call face++ to get biz token
    req_params = {
      sign: signature,
      sign_version: 'hmac_sha1',
      return_url: WEB_HOST,
      notify_url: "#{API_HOST}/facepp_liveness_result?token=#{Rails.application.secrets['facepp_connection_token']}".freeze,
      biz_no: img_obj.id.to_s,
      comparison_type: 0,
      liveness_type: 'video_number',
      uuid: img_obj.user.id.to_s,
      image_ref1: file
    }
    resp = RestClient.post('https://openapi.faceid.com/lite/v1/get_biz_token', req_params) {|res, _req, _result| res}
    Rails.logger.tagged('FaceppBizTokenService'.freeze) {|logger| logger.info "face++ response: #{resp}"}
    file.close
    biz_token = JSON.parse(resp.body)['biz_token']
    return biz_token
  end
end