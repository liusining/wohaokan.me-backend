class CompareFaceService
  URL = 'https://api-cn.faceplusplus.com/facepp/v3/compare'.freeze

  def initialize(img1_url, img2_b64)
    @img1_url = img1_url
    @img2_b64 = img2_b64
  end

  def perform
    Rails.logger.tagged(self.class.to_s.freeze) {|logger| logger.info "comparing the old and the new faces"}
    start_time = Time.now
    payload = {
      api_key: Rails.application.secrets.facepp_api_key,
      api_secret: Rails.application.secrets.facepp_api_secret,
      image_url1: @img1_url,
      image_base64_2: @img2_b64
    }
    resp = RestClient.post(URL, payload) {|res, _req, _result| res}
    Rails.logger.tagged(self.class.to_s.freeze) {|logger| logger.info "response: #{resp}"}
    Rails.logger.tagged(self.class.to_s.freeze) {|logger| logger.info "time_used: #{Time.now - start_time}s"}
    resp_hash = JSON.parse(resp.body)
    confidence = resp_hash['confidence']
    if confidence.blank?
      return [false, ""]
    end
    threshold = resp_hash['thresholds']['1e-4']
    ok = confidence >= threshold
    unless ok
      return [false, ""]
    end
    [ok, resp_hash['faces2'][0]['face_token']]
  end
end