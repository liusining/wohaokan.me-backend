class AnalyzeFaceService
  URL = 'https://api-cn.faceplusplus.com/facepp/v3/face/analyze'.freeze

  def initialize(face_token)
    @face_token = face_token
  end

  def perform
    Rails.logger.tagged(self.class.to_s.freeze) {|logger| logger.info "analyzing a face"}
    start_time = Time.now
    payload = {
      api_key: Rails.application.secrets['facepp_api_key'],
      api_secret: Rails.application.secrets['facepp_api_secret'],
      face_tokens: @face_token,
      return_attributes: Image::FACE_ATTRIBUTES
    }
    resp = RestClient.post(URL, payload) {|res, _req, _result| res}
    Rails.logger.tagged(self.class.to_s.freeze) {|logger| logger.info "response: #{resp}"}
    Rails.logger.tagged(self.class.to_s.freeze) {|logger| logger.info "time_used: #{Time.now - start_time}s"}
    resp_hash = JSON.parse(resp.body)
    face_attrs = resp_hash['faces'][0]['attributes']
    gender = face_attrs['gender']['value']
    age = face_attrs['age']['value']
    beauty = face_attrs['beauty']["#{gender.downcase}_score"]
    [beauty, gender, age]
  end
end