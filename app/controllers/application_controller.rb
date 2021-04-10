class ApplicationController < ActionController::API
  def encoded_token
    JWT.encode({user_id: @user.id}.to_s, ENV['SECRET_KEY_BASE'], 'HS256')
  end

  def decoded_token
    eval(JWT.decode(request.headers['Authentication'], ENV['SECRET_KEY_BASE'], true, { algorithm: 'HS256' })[0])
  end

  def auth_header
    !request.headers['Authentication'].nil?
  end

  def logged_in?
    auth_header
  end
end
