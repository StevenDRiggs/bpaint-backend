class UsersController < ApplicationController
  before_action :set_user, only: [:show, :update, :destroy]

  # RESTful routes

  # GET /users
  def index
    @users = User.all

    render json: @users
  end

  # GET /users/1
  def show
    render json: @user
  end

  # POST /users
  def create
    @user = User.new(user_params)

    if @user.save
      session[:user_id] = @user.id

      render json: {
        user: @user,
        token: encoded_token,
      }, status: :created, location: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/1
  def update
    if @user.update(user_params)
      render json: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/1
  def destroy
    @user.destroy
  end

  # non-RESTful routes

  # POST /login
  def login
    @user = User.find_by_username_or_email(user_params[:usernameOrEmail])

    if @user && @user.authenticate(user_params[:password])
      session[:user_id] = @user.id

      render json: {
        user: @user,
        token: encoded_token,
      }, status: :ok
    else
      render json: ['User not found'], status: :unprocessable_entity
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def user_params
      params.require(:user).permit(:username, :email, :usernameOrEmail, :password, :flags, :is_admin)
    end
end
