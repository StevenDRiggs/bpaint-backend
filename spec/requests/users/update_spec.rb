require 'rails_helper'


RSpec.describe "POST /users", type: :request do
  context 'with valid params' do
    before(:context) do
      @valid_params = {
        user: {
          username: 'valid username',
          email: 'valid@email.com',
          password: 'pass',
        },
      }
    end

    after(:context) do
      remove_instance_variable(:@valid_params)
    end

    context 'with admin logged in' do
      before(:context) do
        @admin_user = User.create!(username: 'admin', email: 'admin@admin.com', password: 'pass', is_admin: true)
        @other_user = User.create!(username: 'other', email: 'other@admin.com', password: 'pass')

        post '/login', params: {
          user: {
            usernameOrEmail: 'admin',
            password: 'pass',
          },
        }

        @valid_headers = {
          'Authentication': eval(response.body)[:token],
        }
      end

      after(:context) do
        @admin_user.destroy
        @other_user.destroy
        remove_instance_variable(:@valid_headers)
      end

      context 'when updating own profile' do
        before(:example) do
          @admin_user.reload
          @other_user.reload
        end

        it 'is successful' do
          patch user_path(@admin_user), headers: @valid_headers, params: @valid_params

          expect(response).to have_http_status(:ok)
        end

        it 'updates user' do
          patch user_path(@admin_user), headers: @valid_headers, params: @valid_params

          updated_user = User.find(@admin_user.id)

          expect(updated_user.username).to eq(@valid_params[:user][:username])
          expect(updated_user.email).to eq(@valid_params[:user][:email])
        end

        it 'renders json for updated user' do
          patch user_path(@admin_user), headers: @valid_headers, params: @valid_params

          expect(eval(response.body)).to include(:user)
          expect(eval(response.body)[:user]).to include(username: @valid_params[:user][:username], email: @valid_params[:user][:email])
          expect(eval(response.body)[:user]).to include(:is_admin, :flags)
          expect(eval(response.body)[:user]).to_not include(:id, :password_digest, :created_at, :updated_at)
        end
      end

      context 'when updating other profile' do
        before(:example) do
          @admin_user.reload
          @other_user.reload
        end

        it 'is successful' do
          patch user_path(@other_user), headers: @valid_headers, params: @valid_params

          expect(response).to have_http_status(:ok)
        end

        it 'updates user' do
          patch user_path(@other_user), headers: @valid_headers, params: @valid_params

          updated_user = User.find(@other_user.id)

          expect(updated_user.username).to eq(@valid_params[:user][:username])
          expect(updated_user.email).to eq(@valid_params[:user][:email])
        end

        it 'renders json for updated user' do
          patch user_path(@other_user), headers: @valid_headers, params: @valid_params

          expect(eval(response.body)).to include(:user)
          expect(eval(response.body)[:user]).to include(username: @valid_params[:user][:username], email: @valid_params[:user][:email])
          expect(eval(response.body)[:user]).to include(:is_admin, :flags)
          expect(eval(response.body)[:user]).to_not include(:id, :password_digest, :created_at, :updated_at)
        end
      end
    end

    context 'with non-admin logged in' do
      before(:context) do
        @non_admin_user = User.create!(username: 'non-admin', email: 'non@admin.com', password: 'pass')
        @other_user = User.create!(username: 'other', email: 'other@admin.com', password: 'pass')

        post '/login', params: {
          user: {
            usernameOrEmail: 'non-admin',
            password: 'pass',
          },
        }

        @valid_headers = {
          'Authentication': eval(response.body)[:token],
        }
      end

      after(:context) do
        @non_admin_user.destroy
        @other_user.destroy
        remove_instance_variable(:@valid_headers)
      end

      context 'when updating own profile' do
        before(:example) do
          @non_admin_user.reload
          @other_user.reload
        end

        it 'is successful' do
          patch user_path(@non_admin_user), headers: @valid_headers, params: @valid_params

          expect(response).to have_http_status(:ok)
        end

        it 'updates user' do
          patch user_path(@non_admin_user), headers: @valid_headers, params: @valid_params

          updated_user = User.find(@non_admin_user.id)

          expect(updated_user.username).to eq(@valid_params[:user][:username])
          expect(updated_user.email).to eq(@valid_params[:user][:email])
        end

        it 'renders json for updated user' do
          patch user_path(@non_admin_user), headers: @valid_headers, params: @valid_params

          expect(eval(response.body)).to include(:user)
          expect(eval(response.body)[:user]).to include(username: @valid_params[:user][:username], email: @valid_params[:user][:email])
          expect(eval(response.body)[:user]).to include(:is_admin, :flags)
          expect(eval(response.body)[:user]).to_not include(:id, :password_digest, :created_at, :updated_at)
        end
      end

      context 'when updating other profile' do
        before(:example) do
          @non_admin_user.reload
          @other_user.reload
        end

        it 'is forbidden' do
          patch user_path(@other_user), headers: @valid_headers, params: @valid_params

          expect(response).to have_http_status(:forbidden)
        end

        it 'does not update user' do
          patch user_path(@other_user), headers: @valid_headers, params: @valid_params

          updated_user = User.find(@other_user.id)

          expect(updated_user.username).to_not eq(@valid_params[:user][:username])
          expect(updated_user.email).to_not eq(@valid_params[:user][:email])
        end

        it 'renders json for errors' do
          patch user_path(@other_user), headers: @valid_headers, params: @valid_params

          expect(eval(response.body)).to include(:errors)
          expect(eval(response.body)[:errors]).to include('Must be logged in as admin to update other profiles')
        end
      end
    end

    context 'when not logged in' do
      let(:test_user) {
        User.create!(username: 'test user', email: 'test@user.com', password: 'pass')
      }

      it 'is forbidden' do
        patch user_path(test_user), headers: @valid_headers, params: @valid_params

        expect(response).to have_http_status(:forbidden)
      end

      it 'does not update user' do
        patch user_path(test_user), headers: @valid_headers, params: @valid_params

        updated_user = User.find(test_user.id)

        expect(updated_user.username).to_not eq(@valid_params[:user][:username])
        expect(updated_user.email).to_not eq(@valid_params[:user][:email])
      end

      it 'renders json for errors' do
        patch user_path(test_user), headers: @valid_headers, params: @valid_params

        expect(eval(response.body)).to include(:errors)
        expect(eval(response.body)[:errors]).to include('Must be logged in as admin to update other profiles')
      end
    end
  end

  context 'with invalid params' do
    before(:example) do
      @admin_user = User.create!(username: 'admin', email: 'admin@admin.com', password: 'pass', is_admin: true)

      post '/login', params: {
        user: {
          usernameOrEmail: 'admin',
          password: 'pass',
        },
      }

      @valid_headers = {
        'Authentication': eval(response.body)[:token],
      }

      @invalid_params = {
        user: {
          username: '',
          email: '',
          password: '',
        },
      }
    end

    it 'is unprocessable' do
      patch user_path(@admin_user), headers: @valid_headers, params: @invalid_params

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'does not update user' do
      patch user_path(@admin_user), headers: @valid_headers, params: @invalid_params

      updated_user = User.find(@admin_user.id)

      expect(updated_user.username).to_not eq(@invalid_params[:user][:username])
      expect(updated_user.email).to_not eq(@invalid_params[:user][:email])
    end

    it 'renders json for errors' do
      patch user_path(@admin_user), headers: @valid_headers, params: @invalid_params

      expect(eval(response.body)).to include(:errors)
    end
  end
end
