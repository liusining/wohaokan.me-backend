class UsersController < ApplicationController
  before_action :load_user, only: [:get_user, :update_info, :update_image, :show]
  before_action :check_params, only: [:login, :update_image, :show]

  def login
    resp = AuthInfoService.perform(params[:code], request.request_id)
    if resp.code != 200
      format_render(400, '授权失败')
      return
    end
    resp_body = JSON.parse(resp.body)
    user = User.init_from_mixin(resp_body)
    result = {
      session_key: user.session_key
    }
    format_render(200, 'OK', result)
  end

  def get_user
    # TODO: use real data
    result = {
      name: current_user.name,
      avatar_url: current_user.avatar_url,
      mixin_id: current_user.mixin_id,
      description: current_user.description,
      has_image: !!current_user.current_image,
      image: current_user.image_signed_url.to_s,
      beauty: current_user.beauty.to_i,
      gender: current_user.gender.to_s,
      age: current_user.age,
      display_image: !!current_user&.current_image&.using,
      rank: 14,
      income: 0.1,
      tip_transations: {
        count: 5,
        to_boy: 2,
        to_girl: 3,
        images: ["https://s3-ap-northeast-1.amazonaws.com/wohaokan.me/cover-test.jpeg"] * 5
      }
    }
    format_render(200, 'OK', result)
  end

  # show this user to others
  def show
    target_user = User.find_by_uid(params[:id])
    unless target_user.present?
      render json: {error: 'the user is not found'}, status: 404
      return
    end
    result = {
      name: target_user.name,
      age: target_user.age,
      gender: target_user.gender,
      likes: target_user.likes_count,
      description: target_user.description
    }
    format_render(200, 'OK', result)
  end

  def update_image
    img1 = current_user.current_image
    img2 = params[:image]
    begin
      @ok, face_token = CompareFaceService.new(img1.signed_url, Base64.strict_encode64(img2.read)).perform
      if @ok
        img2.rewind
        s3_key, url = UploadImageService.perform(img2)
      else
        format_render(400, '和之前的照片不是同一人')
      end
    ensure
      img2.close
    end
    unless @ok
      return
    end
    attrs = AnalyzeFaceService.new(face_token).perform
    new_img = Image.new(url: url, beauty: attrs['beauty'], gender: attrs['gender'], age: attrs['age'],
                        user: current_user, s3_key: s3_key, image_no: SecureRandom.base58(24),
                        verified: true, verify_msg: '1:1', using: true)
    new_img.save!
    new_img.assign_to_user!
    format_render(200, 'OK', {new_url: new_img.signed_url, beauty: new_img.beauty, gender: new_img.gender, age: new_img.age})
  end

  def update_info
    current_user.assign_attributes(nickname: params[:name], age: params[:age], description: params[:description].to_s)
    if current_user.save
      format_render
    else
      logger.info current_user.errors.full_messages
      format_render(400, '更新失败')
    end
  end

  private

  def check_params
    if params[:action] == 'login'
      params.require(:code)
    end
    if params[:action] == 'update_image'
      params.require(:image)
    end
    if params[:action] == 'show'
      params.require(:id)
    end
  end
end
