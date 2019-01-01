class ImagesController < ApplicationController
  before_action :check_params, only: [:upload_image]
  before_action :load_user, only: [:upload_image]

  def upload_image
    # TODO: use cloudfront to speed up image services
    # TODO: limit image size in nginx, for speeding up, for facepp limitation
    # TODO: compress image using lambda
    # TODO: use a host in China to speed up images uploading
    # TODO: prevent images on iphone from being rotated
    # TODO: adjust values of beauty and age to make users happy
    # TODO: stop low-quality images
    s3_key, url = UploadImageService.perform(params[:image].tempfile)
    beauty, gender, age = DetectFaceService.perform(params[:image])
    img = Image.new(url: url, beauty: beauty.to_f, gender: gender, age: age, user: current_user, s3_key: s3_key, image_no: SecureRandom.base58(24))
    if img.save
      biz_token = FaceppBizTokenService.perform(img, params[:image])
      img.biz_token = biz_token
      img.save!
      render json: { status: 200, msg: 'OK', result: { beauty: beauty, gender: gender, age: age, verify_url: "https://openapi.faceid.com/lite/v1/do/#{biz_token}" } }
    else
      format_render(400, '图片上传失败')
    end
  end

  def get_images
    if request.headers['X-Session-Key'].blank? || !current_user.present?
      url = "https://s3-ap-northeast-1.amazonaws.com/wohaokan.me/cover-test.jpeg"
      obj = { url: url, likes: 17, user_id: -1, age: 0 }
      format_render(200, 'not logging in, cover image only', { images: [obj] * 10, pagination: { page: 1, total: 10 } })
      return
    end
    # TODO: only return images that are currently used
    page   = params[:page].to_i.positive? ? params[:page].to_i : 1
    images = Image.limit(10).offset((page - 1) * 10).map do |img| # TODO: select only valid images
      {
        url:     Aws::S3::Object.new(Rails.application.secrets[:face_image_bucket], img.s3_key).presigned_url(:get, expires_in: 3600),
        user_id: img.user_id,
        likes:   17,
        age:     img.user.age
      }
    end
    format_render(200, 'OK', { images: images, pagination: { page: page, total: Image.count} }) # TODO: count only valid images
  end

  private

  def check_params
    params.require(:image)
  end
end
