require 'rails_helper'


RSpec.describe "GET /users", type: :request do
  context 'with admin logged in' do
    before(:example) do
      @admin_user = User.create!(username: 'admin', email: 'admin@email.com', password: 'pass', is_admin: true)

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

    it 'succeeds' do
      get users_path, headers: @valid_headers

      expect(response).to have_http_status(:ok)
    end

    it 'renders json for users list' do
      get users_path, headers: @valid_headers

      expect(eval(response.body)).to include(:users)
      expect(eval(response.body)[:users]).to be_an(Array)
    end

    it 'reveals all users' do
      3.times do
        User.create!(username: Faker::Movies::BackToTheFuture.character, email: Faker::Internet.email, password: 'pass')
      end

      get users_path, headers: @valid_headers

      expect(eval(response.body)[:users].length).to eq(4)

      test_user = User.first
      expect(eval(response.body)[:users][0]).to include(username: test_user.username, email: test_user.email, is_admin: test_user.is_admin)
      expect(eval(response.body)[:users][0]).to include(:flags)
      expect(eval(response.body)[:users][0]).to_not include(:id, :created_at, :updated_at, :password_digest)
    end
  end

  context 'with non-admin logged in' do
    before(:example) do
      @non_admin_user = User.create!(username: 'non-admin', email: 'nonadmin@email.com', password: 'pass')

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

    it 'is forbidden' do
      get users_path, headers: @valid_headers

      expect(response).to have_http_status(:forbidden)
    end

    it 'renders json for errors' do
      get users_path, headers: @valid_headers

      expect(eval(response.body)).to include(:errors)
      expect(eval(response.body)[:errors]).to include('Must be logged in as admin to view all users')
    end

    it 'does not reveal any users' do
      get users_path, headers: @valid_headers

      expect(eval(response.body)).to_not include(:users)
    end
  end

  context 'when not logged in' do
    it 'is forbidden' do
      get users_path

      expect(response).to have_http_status(:forbidden)
    end

    it 'renders json for errors' do
      get users_path

      expect(eval(response.body)).to include(:errors)
      expect(eval(response.body)[:errors]).to include('Must be logged in as admin to view all users')
    end

    it 'does not reveal any users' do
      get users_path

      expect(eval(response.body)).to_not include(:users)
    end
  end
end
