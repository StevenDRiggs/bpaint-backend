require 'rails_helper'


RSpec.describe "GET /users/:id", type: :request do
  context 'with admin logged in' do
    before(:context) do
      @admin_user = User.create!(username: 'admin', email: 'admin@admin.com', password: 'pass', is_admin: true)
      @other_user = User.create!(username: 'other', email: 'other@other.com', password: 'pass')

      post '/login', params: {
        user: {
          usernameOrEmail: 'admin',
          password: 'pass',
        },
      }

      @valid_headers = {
        'Authentication': eval(response.body)[:token]
      }
    end

    after(:context) do
      @admin_user.destroy
      @other_user.destroy
      remove_instance_variable(:@valid_headers)
    end

    context 'when viewing own profile' do
      it 'is successful' do
        get user_path(@admin_user), headers: @valid_headers

        expect(response).to have_http_status(:ok)
      end

      it 'renders json for the user' do
        get user_path(@admin_user), headers: @valid_headers

        expect(eval(response.body)).to include(:user)
        expect(eval(response.body)[:user]).to include(username: @admin_user.username, email: @admin_user.email, is_admin: @admin_user.is_admin)
        expect(eval(response.body)[:user]).to include(:flags)
        expect(eval(response.body)[:user]).to_not include(:id, :password_digest, :created_at, :updated_at)
      end
    end

    context "when viewing other's profile" do
      it 'is successful' do
        get user_path(@other_user), headers: @valid_headers

        expect(response).to have_http_status(:ok)
      end

      it 'renders json for the user' do
        get user_path(@other_user), headers: @valid_headers

        expect(eval(response.body)).to include(:user)
        expect(eval(response.body)[:user]).to include(username: @other_user.username, email: @other_user.email, is_admin: @other_user.is_admin)
        expect(eval(response.body)[:user]).to include(:flags)
        expect(eval(response.body)[:user]).to_not include(:id, :password_digest, :created_at, :updated_at)
      end
    end
  end

  context 'with non-admin logged in' do
    before(:context) do
      @non_admin_user = User.create!(username: 'non-admin', email: 'non@admin.com', password: 'pass')
      @other_user = User.create!(username: 'other', email: 'other@other.com', password: 'pass')

      post '/login', params: {
        user: {
          usernameOrEmail: 'non-admin',
          password: 'pass',
        },
      }

      @valid_headers = {
        'Authentication': eval(response.body)[:token]
      }
    end

    after(:context) do
      @non_admin_user.destroy
      @other_user.destroy
      remove_instance_variable(:@valid_headers)
    end

    context 'when viewing own profile' do
      it 'is successful' do
        get user_path(@non_admin_user), headers: @valid_headers

        expect(response).to have_http_status(:ok)
      end

      it 'renders json for the user' do
        get user_path(@non_admin_user), headers: @valid_headers

        expect(eval(response.body)).to include(:user)
        expect(eval(response.body)[:user]).to include(username: @non_admin_user.username, email: @non_admin_user.email, is_admin: @non_admin_user.is_admin)
        expect(eval(response.body)[:user]).to include(:flags)
        expect(eval(response.body)[:user]).to_not include(:id, :password_digest, :created_at, :updated_at)
      end
    end

    context "when viewing other's profile" do
      it 'is forbidden' do
        get user_path(@other_user), headers: @valid_headers

        expect(response).to have_http_status(:forbidden)
      end

      it 'renders json for errors' do
        get user_path(@other_user), headers: @valid_headers

        expect(eval(response.body)).to include(:errors)
        expect(eval(response.body)[:errors]).to include('Must be logged in as admin to view other users')
      end

      it 'does not render json for user' do
        get user_path(@other_user), headers: @valid_headers

        expect(eval(response.body)).to_not include(:user)
      end
    end
  end

  context 'when not logged in' do
    before(:example) do
      @user = User.create!(username: Faker::Movies::BackToTheFuture.character, email: Faker::Internet.email, password: 'pass')
    end

    it 'is forbidden' do
      get user_path(@user)

      expect(response).to have_http_status(:forbidden)
    end

    it 'renders json for errors' do
      get user_path(@user)

      expect(eval(response.body)).to include(:errors)
      expect(eval(response.body)[:errors]).to include('Must be logged in as admin to view other users')
    end

    it 'does not render json for user' do
      get user_path(@user)

      expect(eval(response.body)).to_not include(:user)
    end
  end
end
