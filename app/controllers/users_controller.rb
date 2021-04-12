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
        errors: ['Must be logged in as admin to view all users'],
      }, status: :forbidden
    end
  end

  # GET /users/:id
  def show
    if admin? || (logged_in? && @user.id == decoded_token[:user_id])
      render json: {
        user: @user,
      }
    else
      render json: {
        errors: ['Must be logged in as admin to view other users'],
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
    if admin? || (logged_in? && @user.id == decoded_token[:user_id])
      if @user.update(user_params)
        render json: {
          user: @user,
        }
      else
        render json: {
          errors: @user.errors.full_messages,
        }, status: :unprocessable_entity
      end
    else
      render json: {
        errors: ['Must be logged in as admin to update other profiles'],
      }, status: :forbidden
    end
  end

  # DELETE /users/1
  def destroy
    if admin?
      if @user.is_admin
        if @user.flags['DELETE_USER']
          username = @user.username

          @user.destroy

          render json: {
            user: "DELETED #{username}",
          }
        else
          @user.update_attribute(:flags, {'DELETE_USER' => true})

          render json: {
            user: @user
          }
        end
      else
        username = @user.username

        @user.destroy

        render json: {
          user: "DELETED #{username}",
        }
      end
    else
      if logged_in? && @user.id == decoded_token[:user_id]
        @user.update_attribute(:flags, {'DELETE_USER' => true})

        render json: {
          user: @user
        }
      else
        render json: {
          errors: ['Must be logged in as admin to delete other profiles'],
        }, status: :forbidden
      end
    end
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
      render json: {
        errors: ['User not found']
      }, status: :unprocessable_entity
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
