require 'rails_helper'


RSpec.describe 'POST /login' do
  context 'with valid params' do
    before(:context) do
      @test_user = User.new(username: Faker::Movies::HarryPotter::character, email: Faker::Internet.email, password: 'pass')

      while !@test_user.save do
        @test_user = User.new(username: Faker::Movies::HarryPotter::character, email: Faker::Internet.email, password: 'pass')
      end
    end

    after(:context) do
      @test_user.destroy
    end

    context 'with login via username' do
      let(:valid_params) {
        {
          user: {
            usernameOrEmail: @test_user.username,
            password: 'pass',
          },
        }
      }

      it 'is successful' do
        post '/login', params: valid_params

        expect(response).to have_http_status(:ok)
      end

      it 'renders json for user' do
        post '/login', params: valid_params

        expect(eval(response.body)).to include(:user, :token)
        expect(eval(response.body)[:user]).to include(username: @test_user.username, email: @test_user.email, is_admin: @test_user.is_admin, flags: @test_user.flags)
        expect(eval(response.body)[:user]).to_not include(:id, :password_digest, :created_at, :updated_at)
        expect(eval(response.body)[:token]).to_not be_nil
      end
    end

    context 'with login via email' do
      let(:valid_params) {
        {
          user: {
            usernameOrEmail: @test_user.email,
            password: 'pass',
          },
        }
      }

      it 'is successful' do
        post '/login', params: valid_params

        expect(response).to have_http_status(:ok)
      end

      it 'renders json for user' do
        post '/login', params: valid_params

        expect(eval(response.body)).to include(:user, :token)
        expect(eval(response.body)[:user]).to include(username: @test_user.username, email: @test_user.email, is_admin: @test_user.is_admin, flags: @test_user.flags)
        expect(eval(response.body)[:user]).to_not include(:id, :password_digest, :created_at, :updated_at)
        expect(eval(response.body)[:token]).to_not be_nil
      end
    end
  end

  context 'with invalid params' do
    let(:invalid_params) {
      {
        user: {
          usernameOrEmail: 'wrong',
          password: 'wrong',
        },
      }
    }

    it 'is unprocessable' do
      post '/login', params: invalid_params

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'renders json for errors' do
      post '/login', params: invalid_params

      expect(eval(response.body)).to include(:errors)
      expect(eval(response.body)[:errors]).to include('User not found')
    end
  end
end
