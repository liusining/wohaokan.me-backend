class ImagesController < ApplicationController
  before_action :check_params, only: [:upload_image]
  before_action :load_user, only: [:upload_image]

  def upload_image
    # TODO: use cloudfront to speed up image services
    # TODO: limit image size in nginx, for speeding up, for facepp limitation
    s3_key, url = UploadImageService.perform(params[:image].tempfile)
    beauty, gender, age = DetectFaceService.perform(params[:image])
    img = Image.new(url: url, beauty: beauty.to_f, gender: gender, age: age, user: current_user, s3_key: s3_key)
    if img.save
      render json: { status: 200, msg: 'OK', result: { beauty: beauty, gender: gender, age: age } }
    else
      format_render(400, '图片上传失败')
    end
  end

  def get_images
    if request.headers['X-Session-Key'].blank? || !current_user.present?
      url = "http://b-ssl.duitang.com/uploads/item/201502/16/20150216205649_wQ2fK.jpeg"
      obj = { url: url, likes: 17, user_id: -1, age: 0 }
      format_render(200, 'not logging in, cover image only', { images: [obj], pagination: { page: 1, total: 0 } })
      return
    end
    # TODO: only return images that are currently used
    page   = params[:page].to_i.positive? ? params[:page].to_i : 1
    images = Image.offset((page - 1) * 10).map do |img| # TODO: select only valid images
      {
        url:     Aws::S3::Object.new(Rails.application.secrets[:face_image_bucket], img.s3_key).presigned_url(:get, expires_in: 3600),
        user_id: img.user_id,
        likes:   17,
        age:     23
      }
    end
    format_render(200, 'OK', { images: images, pagination: { page: page, total: Image.count} }) # TODO: count only valid images
  end

  private

  def check_params
    params.require(:image)
  end
end
