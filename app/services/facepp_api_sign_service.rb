class FaceppApiSignService
  def self.perform
    now = Time.now
    raw_data = "a=#{Rails.application.secrets['facepp_sdk_key']}&b=#{now.advance(minutes: 10).to_i}&c=#{now.to_i}&d=#{rand(1000000000..9999999999)}"
    Rails.logger.tagged('FaceppBizTokenService'.freeze) {|logger| logger.info "signature raw data: #{raw_data}"}
    hmac = OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha1'), Rails.application.secrets['facepp_sdk_secret'], raw_data)
    return Base64.strict_encode64(hmac + raw_data)
  end
end