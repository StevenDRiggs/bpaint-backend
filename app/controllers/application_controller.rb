class ApplicationController < ActionController::API
  def encoded_token
    JWT.encode({user_id: @user.id}.to_s, ENV['SECRET_KEY_BASE'], 'HS256')
  end
end
