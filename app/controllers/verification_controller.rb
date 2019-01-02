class VerificationController < ApplicationController
  VERIFY_SUCCESS = 1000
  before_action :validate_token, only: [:facepp_liveness_result]
  # before_action :load_user, only: [:get_verify_result]
  before_action :check_params, only: [:get_verify_result]

  def facepp_liveness_result
    # TODO: handle video error, since this error may cause image verification status to be changed before the final result arrives
    result = JSON.parse(params[:data])
    if result['biz_token'].blank?
      return # invalid request
    end
    img = Image.find_by(biz_token: result['biz_token'])
    unless img.present?
      return
    end
    img.verified = result['result_code'] == VERIFY_SUCCESS
    img.verify_msg = result['result_message']
    img.save!
    if img.verified
      img.assign_to_user!
    end
  end

  def get_verify_result
    img = Image.find_by(biz_token: params[:biz_token])
    unless img.present?
      format_render(400, '请求不合法')
      return
    end
    if img.verified.nil?
      result_code, result_message = FaceppLivenessResultService.perform(img)
      img.verified = result_code == VERIFY_SUCCESS
      img.verify_msg = result_message
      img.save!
      if img.verified
        img.assign_to_user!
      end
    end
    status_code = img.verified ? 200 : 400
    msg = img.verified ? 'OK' : "认证失败：#{img.verify_msg}"
    result = {
      url: img.signed_url,
      beauty: img.beauty,
      gender: img.gender,
      age: img.age
    }
    unless img.verified
      new_img_flag = Image.create!(url: img.url,
                                   beauty: img.beauty,
                                   gender: img.gender,
                                   age: img.age,
                                   user: img.user,
                                   s3_key: img.s3_key,
                                   image_no: SecureRandom.base58(24))
      biz_token = FaceppBizTokenService.perform(new_img_flag,
                                                Aws::S3::Object.new(Rails.application.secrets['face_image_bucket'], new_img_flag.s3_key))
      new_img_flag.biz_token = biz_token
      new_img_flag.save!
      result[:verify_url] = new_img_flag.verify_url
    end
    format_render(status_code, msg, result)
  end

  private

  def validate_token
    if params[:token] != Rails.application.secrets['facepp_connection_token']
      render json: {error: 'invalid request'}, status: 400
    end
  end

  def check_params
    params.require(:biz_token)
  end
end
