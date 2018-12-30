class UsersController < ApplicationController
  before_action :check_params
  def login
    payload = {
      auth_code: params[:code],
      request_id: request.request_id
    }
    resp_obj = RestClient.post(Rails.application.secrets.mixin_service + '/auth_info', payload) {|resp, _req, _result| resp}
    if resp_obj.code != 200
      render json: {status: 400, msg: '授权失败', result: {}}
    else
      resp_body = JSON.parse(resp_obj.body)
      result = {
        name: resp_body['full_name'],
        avatar_url: resp_body['avatar_url']
      }
      render json: {status: 200, msg: 'OK', result: result}
    end
  end

  private

  def check_params
    params.require(:code)
  end
end
