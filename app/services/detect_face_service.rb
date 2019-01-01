class DetectFaceService
  URL = 'https://api-cn.faceplusplus.com/facepp/v3/detect'.freeze

  def self.perform(image)
    Rails.logger.tagged('DetectFaceService'.freeze) {|logger| logger.info "begin detecting face"}
    start_time = Time.now
    image.rewind if image.eof?
    payload = {
      api_key: Rails.application.secrets.facepp_api_key,
      api_secret: Rails.application.secrets.facepp_api_secret,
      return_attributes: 'gender,age,facequality,beauty'.freeze,
      image_file: image
    }
    resp = RestClient.post(URL, payload) {|res, _req, _result| res}
    Rails.logger.tagged('DetectFaceService'.freeze) {|logger| logger.info "face detection response: #{resp}"}
    face_attrs = JSON.parse(resp.body)['faces'][0]['attributes'] # TODO: throw errors for no faces and multi faces and low-quality face
    gender = face_attrs['gender']['value']
    age = face_attrs['age']['value']
    beauty = face_attrs['beauty']["#{gender.downcase}_score"]
    Rails.logger.tagged('DetectFaceService'.freeze) {|logger| logger.info "time used: #{Time.now - start_time}s"}
    return [beauty, gender, age]
  end
end