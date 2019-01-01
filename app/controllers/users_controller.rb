class UsersController < ApplicationController
  before_action :load_user, only: [:get_user]
  before_action :check_params, only: [:login]

  def login
    resp = AuthInfoService.perform(params[:code], request.request_id)
    if resp.code != 200
      format_render(400, '授权失败')
      return
    end
    resp_body = JSON.parse(resp.body)
    user = User.init_from_mixin(resp_body)
    result = {
      name: user.name,
      avatar_url: user.avatar_url,
      session_key: user.session_key
    }
    format_render(200, 'OK', result)
  end

  def get_user
    result = {
      name: current_user.name,
      description: current_user.description,
      has_image: !!current_user.current_image,
      image: current_user.image_url.to_s,
      beauty: current_user.beauty.to_i,
      gender: current_user.gender.to_s,
      age: current_user.age,
      rank: 14,
      income: 0.1,
      tip_transations: {
        count: 5,
        to_boy: 2,
        to_girl: 3
      }
    }
    format_render(200, 'OK', result)
  end

  private

  def check_params
    params.require(:code)
  end
end
