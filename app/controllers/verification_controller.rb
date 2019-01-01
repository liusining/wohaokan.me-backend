class VerificationController < ApplicationController
  before_action :validate_token

  def facepp_liveness_result
  end

  private

  def validate_token
    if params[:token] != Rails.application.secrets['facepp_connection_token']
      render json: {error: 'invalid request'}, status: 400
    end
  end
end
