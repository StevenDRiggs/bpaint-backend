class AvatarsController < ApplicationController
  before_action :set_avatar, only: [:show, :update, :destroy]

  # GET /avatars
  def index
    if admin?
      @verified = Avatar.all.where(verified: true)
      @unverified = Avatar.all.where(verified: false)

      render json: {
        avatars: {
          verified: @verified,
          unverified: @unverified,
        },
      }
    else
      render json: {
        errors: ['Must be logged in as admin to view all avatars'],
      }, status: :forbidden
    end
  end

  # GET /avatars/1
  def show
    if @avatar.verified
      render json: {
        avatar: @avatar,
      }
    else
      render json: {
        avatar: 'unverified',
      }
    end
  end

  # POST /avatars
  def create
    if logged_in? && avatar_params[:user_id].to_i == decoded_token[:user_id]
      @avatar = Avatar.new(avatar_params)

      if @avatar.save
        render json: {
          avatar: @avatar,
        }, status: :created, location: @avatar
      else
        render json: @avatar.errors, status: :unprocessable_entity
      end
    else
      render json: {
        errors: ['May only create own avatar'],
      }, status: :forbidden
    end
  end

  # PATCH/PUT /avatars/1
  def update
    if logged_in? && @avatar.user_id == decoded_token[:user_id]
      if @avatar.update(avatar_params)
        render json: {
          avatar: @avatar,
        }
      else
        render json: @avatar.errors, status: :unprocessable_entity
      end
    else
      render json: {
        errors: ['May only update own avatar'],
      }, status: :forbidden
    end
  end

  # DELETE /avatars/1
  def destroy
    if admin? || (logged_in? && @avatar.user.id == decoded_token[:user_id])
      @avatar.destroy

      render json: {
        avatar: 'DELETED',
      }
    else
      render json: {
        errors: ['Must be logged in as admin to delete other avatars'],
      }, status: :forbidden
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_avatar
      @avatar = Avatar.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def avatar_params
      params.require(:avatar).permit(:url, :name, :user_id, :verified)
    end
end
