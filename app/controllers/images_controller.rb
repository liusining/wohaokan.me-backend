class ImagesController < ApplicationController
  before_action :check_params, only: [:upload_image]
  before_action :load_user, only: [:upload_image]

  def upload_image
    # TODO: use cloudfront to speed up image services
    s3_key, url = UploadImageService.perform(params[:image].tempfile)
    beauty, gender, age = DetectFaceService.perform(params[:image])
    img = Image.new(url: url, beauty: beauty.to_f, gender: gender, age: age, user: current_user, s3_key: s3_key)
    if img.save
      render json: {status: 200, msg: 'OK', result: {beauty: beauty, gender: gender, age: age}}
    else
      format_render(400, '图片上传失败')
    end
  end

  def get_images
    if request.headers['X-Session-Key'].blank? || !current_user.present?
      url = "https://ss0.bdstatic.com/94oJfD_bAAcT8t7mm9GUKT-xh_/timg?image&quality=100&size=b4000_4000&sec=1546247895&di=eec71747b8bdd220e287de5aab5191f9&src=http://b-ssl.duitang.com/uploads/item/201502/16/20150216205649_wQ2fK.jpeg"
      obj = {url: url, likes: 17, user_id: -1, age: 0}
      format_render(200, 'not logging in, cover image only', [obj])
      return
    end
    images = Image.where.not(user_id: nil).first(10).map do |img|
      {
        url: Aws::S3::Object.new(Rails.application.secrets[:face_image_bucket], img.s3_key).presigned_url(:get, expires_in: 3600),
        user_id: img.user_id,
        likes: 17,
        age: 23
      }
    end
    format_render(200, 'OK', images)
  end

  private

  def check_params
    params.require(:image)
  end
end
