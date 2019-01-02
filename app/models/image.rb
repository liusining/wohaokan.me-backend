class Image < ApplicationRecord
  H5_LIVENESS_URL = 'https://openapi.faceid.com/lite/v1/do/'.freeze
  CLOUDFRONT_PRIVATE_KEY = "#{Rails.root}/config/cloudfront_key.pem"
  belongs_to :user
  enum gender: [:Female, :Male]

  def assign_to_user!
    self.user.current_image = self
    self.using = true
    self.user.save!
    self.save!
  end

  def verify_url
    "#{H5_LIVENESS_URL}#{biz_token}"
  end

  def signed_url
    signer = Aws::CloudFront::UrlSigner.new(key_pair_id: Rails.application.secrets['cloudfront_key_id'],
                                            private_key_path: CLOUDFRONT_PRIVATE_KEY)
    raw_url = "#{Rails.application.secrets['cloudfront_host']}/#{s3_key}"
    policy = {
      Statement: [
        Resource: raw_url,
        Condition: {
          DateLessThan: {
            'AWS:EpochTime': Time.now.advance(hours: 1).to_i
          }
        }
      ]
    }.to_json
    url = signer.signed_url(raw_url, policy: policy)
  end
end
