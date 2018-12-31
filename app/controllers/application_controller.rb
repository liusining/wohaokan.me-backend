class ApplicationController < ActionController::API
  private

  def format_render(status = 200, msg = 'OK', result = {})
    render json: { status: status, msg: msg, result: result }
  end

  def current_user
    @current_user ||= User.find_by_session_key(request.headers['X-Session-Key'])
  end

  def load_user
    if request.headers['X-Session-Key'].blank?
      render json: { error: 'missing session key' }, status: 401
      return
    end
    unless current_user.present?
      render json: { error: "invalid session key" }, status: 401
    end
  end
end
