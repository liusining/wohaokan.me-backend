class ImagesController < ApplicationController
  before_action :check_params, only: [:upload_image]
  before_action :load_user

  def upload_image
    # TODO: use cloudfront to speed up image services
    url = UploadImageService.perform(params[:image].tempfile)
    beauty, gender, age = DetectFaceService.perform(params[:image])
    img = Image.new(url: url, beauty: beauty.to_f, gender: gender, age: age, user: current_user)
    if img.save
      render json: {status: 200, msg: 'OK', result: {beauty: beauty, gender: gender, age: age}}
    else
      format_render(400, '图片上传失败')
    end
  end

  private

  def check_params
    params.require(:image)
  end
end
