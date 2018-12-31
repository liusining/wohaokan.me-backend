class UploadImageService
  def self.perform(image)
    Rails.logger.tagged('UploadImageService'.freeze) {|logger| logger.info "begin uploading an image"}
    s3 = Aws::S3::Resource.new
    s3_key = "#{SecureRandom.base58(24)}.jpg"
    obj = s3.bucket(Rails.application.secrets['face_image_bucket']).object(s3_key)
    start_time = Time.now
    obj.upload_file(image)
    Rails.logger.tagged('UploadImageService'.freeze) {|logger| logger.info "time used: #{Time.now - start_time}s"}
    return [s3_key, obj.public_url]
  end
end