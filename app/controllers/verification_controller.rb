class VerificationController < ApplicationController
  VERIFY_SUCCESS = 1000
  before_action :validate_token, only: [:facepp_liveness_result]
  # before_action :load_user, only: [:get_verify_result]
  before_action :check_params, only: [:get_verify_result]

  def facepp_liveness_result
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
    end
    status_code = img.verified ? 200 : 400
    msg = img.verified ? 'OK' : "认证失败：#{img.verify_msg}"
    format_render(status_code, msg)
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
