class ImagesController < ApplicationController
  before_action :check_params
  def upload_image
    beauty, gender, age = DetectFaceService.perform(params[:image])
    render json: {status: 200, msg: 'OK', result: {beauty: beauty, gender: gender, age: age}}
  end

  private

  def check_params
    params.require(:image)
  end
end
