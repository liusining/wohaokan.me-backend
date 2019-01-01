class FaceppBizTokenService
  WEB_HOST = ENV['WEB_HOST'] || Rails.application.secrets['web_host']
  API_HOST = ENV['API_HOST'] || Rails.application.secrets['api_host']
  URL = 'https://openapi.faceid.com/lite/v1/get_biz_token'.freeze

  def self.perform(img_obj, file)
    Rails.logger.tagged('FaceppBizTokenService'.freeze) {|logger| logger.info "begin applying for a face++ biz-token"}
    start_time = Time.now
    # reopen image file since it has been closed in the former step
    if file.tempfile.closed?
      file = File.new(file.tempfile)
    end
    # generate signature used in face++ api
    signature = FaceppApiSignService.perform
    # call face++ to get biz token
    req_params = {
      sign: signature,
      sign_version: 'hmac_sha1',
      return_url: "#{WEB_HOST}/uploadSuccess/auth",
      notify_url: "#{API_HOST}/facepp_liveness_result?token=#{Rails.application.secrets['facepp_connection_token']}".freeze,
      biz_no: img_obj.image_no,
      comparison_type: 0,
      liveness_type: 'video_number',
      uuid: img_obj.user.id.to_s,
      image_ref1: file
    }
    resp = RestClient.post(URL, req_params) {|res, _req, _result| res}
    Rails.logger.tagged('FaceppBizTokenService'.freeze) {|logger| logger.info "face++ response: #{resp}"}
    Rails.logger.tagged('FaceppBizTokenService'.freeze) {|logger| logger.info "time used: #{Time.now - start_time}s"}
    file.close
    biz_token = JSON.parse(resp.body)['biz_token']
    return biz_token
  end
end