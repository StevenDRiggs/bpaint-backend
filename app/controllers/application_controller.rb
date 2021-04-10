class ApplicationController < ActionController::API
  def encoded_token
    JWT.encode({user_id: @user.id}.to_s, ENV['SECRET_KEY_BASE'], 'HS256')
  end

  def decoded_token
    if auth_header
      eval(JWT.decode(request.headers['Authentication'], ENV['SECRET_KEY_BASE'], true, { algorithm: 'HS256' })[0])
    end
  end

  def auth_header
    !request.headers['Authentication'].nil?
  end
end
