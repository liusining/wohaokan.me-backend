class DetectFaceService
  URL = 'https://api-cn.faceplusplus.com/facepp/v3/detect'.freeze

  def self.perform(image)
    Rails.logger.tagged('DetectFaceService'.freeze) {|logger| logger.info "begin detecting face"}
    start_time = Time.now
    image.rewind if image.eof?
    payload = {
      api_key: Rails.application.secrets.facepp_api_key,
      api_secret: Rails.application.secrets.facepp_api_secret,
      return_attributes: Image::FACE_ATTRIBUTES,
      image_file: image
    }
    resp = RestClient.post(URL, payload) {|res, _req, _result| res}
    Rails.logger.tagged('DetectFaceService'.freeze) {|logger| logger.info "face detection response: #{resp}"}
    faces = JSON.parse(resp.body)['faces']
    if faces.blank?
      return [nil, nil, nil, false]
    end
    face_attrs = faces[0]['attributes'] # TODO: throw errors for multi faces and low-quality face
    gender = face_attrs['gender']['value']
    age = face_attrs['age']['value']
    beauty = face_attrs['beauty']["#{gender.downcase}_score"]
    Rails.logger.tagged('DetectFaceService'.freeze) {|logger| logger.info "time used: #{Time.now - start_time}s"}
    return [beauty, gender, age, true]
  end
end