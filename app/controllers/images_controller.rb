class ImagesController < ApplicationController
  before_action :check_params, only: [:upload_image]
  before_action :load_user, only: [:upload_image, :switch_display]

  def upload_image
    # TODO: compress image using lambda
    # TODO: use a host in China to speed up images uploading
    # TODO: prevent images on iphone from being rotated
    # TODO: adjust values of beauty and age to make users happy
    # TODO: stop low-quality images
    s3_key, url = UploadImageService.perform(params[:image].tempfile)
    beauty, gender, age, has_face = DetectFaceService.perform(params[:image])
    unless has_face
      format_render(400, '未检测到人像')
      return
    end
    img = Image.new(url: url, beauty: beauty.to_f, gender: gender, age: age, user: current_user, s3_key: s3_key, image_no: SecureRandom.base58(24))
    if img.save
      biz_token = FaceppBizTokenService.perform(img, params[:image])
      img.biz_token = biz_token
      img.save!
      render json: { status: 200, msg: 'OK', result: { beauty: beauty, gender: gender, age: age, verify_url: img.verify_url } }
    else
      format_render(400, '图片上传失败')
    end
  end

  def get_images
    # the user are not logging in
    if request.headers['X-Session-Key'].blank? || !current_user.present?
      url = "https://s3-ap-northeast-1.amazonaws.com/wohaokan.me/cover-test.jpeg"
      obj = { url: url, user_id: ""}
      format_render(200, 'not logging in, cover image only', { images: [obj] * 10, pagination: { page: 1, total: 10 } })
      return
    end
    # the user have logged in
    page   = params[:page].to_i.positive? ? params[:page].to_i : 1
    valid_images = Image.where(using: true, verified: true)
    unless params[:gender].blank?
      valid_images = valid_images.where(gender: params[:gender])
    end
    images = valid_images.limit(10).offset((page - 1) * 10).map do |img|
      {
        url:     img.signed_url,
        user_id: img.user.uid
      }
    end
    format_render(200, 'OK', { images: images, pagination: { page: page, total: valid_images.count} })
  end

  def switch_display
    image = current_user.current_image
    unless image.present?
      render json: {error: "you don's have an image"}, status: 400
      return
    end
    image.using = !image.using
    image.save!
    format_render(200, 'OK', {display_image: image.using})
  end

  private

  def check_params
    params.require(:image)
  end
end
