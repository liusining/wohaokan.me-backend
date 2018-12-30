class UsersController < ApplicationController
  before_action :check_params
  def login
    resp = AuthInfoService.perform(params[:code], request.request_id)
    if resp.code != 200
      render json: {status: 400, msg: '授权失败', result: {}}
    else
      resp_body = JSON.parse(resp.body)
      result = {
        name: resp_body['full_name'],
        avatar_url: resp_body['avatar_url'],
        session_key: SecureRandom.base58(24)
      }
      render json: {status: 200, msg: 'OK', result: result}
    end
  end

  private

  def check_params
    params.require(:code)
  end
end
