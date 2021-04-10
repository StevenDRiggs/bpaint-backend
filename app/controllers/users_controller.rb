class UsersController < ApplicationController
  before_action :set_user, only: [:show, :update, :destroy]

  # RESTful routes

  # GET /users
  def index
    if admin?
      @users = User.all

      render json: {
        users: @users,
      }
    else
      render json: {
        errors: ['Must be logged in as admin'],
      }, status: :forbidden
    end
  end

  # GET /users/1
  def show
    if admin? || (logged_in? && params[:id].to_i == decoded_token[:user_id])
      render json: {
        user: @user,
      }
    else
      render json: {
        errors: ['Must be logged in as admin'],
      }, status: :forbidden
    end
  end

  # POST /users
  def create
    @user = User.new(user_params)

    if @user.save
      render json: {
        user: @user,
        token: encoded_token,
      }, status: :created, location: @user
    else
      render json: {
        errors: @user.errors.full_messages,
      }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/1
  def update
    if @user.update(user_params)
      render json: {
        user: @user,
      }
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

    # verify @user.is_admin and logged in for certain functions
    def admin?
      logged_in? && User.find(decoded_token[:user_id]).is_admin
    end
end
