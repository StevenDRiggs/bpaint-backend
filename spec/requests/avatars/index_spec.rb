require 'rails_helper'


RSpec.describe 'GET /avatars' do
  before(:context) do
    @user = User.create!(username: Faker::Fantasy::Tolkien.character, email: Faker::Internet.email, password: 'pass')
    @av_true_count = 0
    @av_false_count = 0
    (Random.rand(2) + 1).times.with_index do |i|
      av = Avatar.new(url: Faker::Internet.url, name: Faker::Fantasy::Tolkien.location, user: @user, verified: true)
      while !av.save do
        av = Avatar.new(url: Faker::Internet.url, name: Faker::Fantasy::Tolkien.location, user: @user, verified: true)
      end
      @av_true_count = i
    end
    (Random.rand(2) + 1).times.with_index do |j|
      av = Avatar.new(url: Faker::Internet.url, name: Faker::Fantasy::Tolkien.location, user: @user, verified: false)
      while !av.save do
        av = Avatar.new(url: Faker::Internet.url, name: Faker::Fantasy::Tolkien.location, user: @user, verified: false)
      end
      @av_false_count = j
    end
  end

  after(:context) do
    @user.destroy
    @av_true_count.times do
      Avatar.where(verified: true).last.destroy
    end
    @av_false_count.times do
      Avatar.where(verified: false).last.destroy
    end
  end

  context 'with admin logged in' do
    before(:example) do
      @admin_user = User.create!(username: 'admin', email: 'admin@admin.com', password: 'pass', is_admin: true)

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
      get avatars_path, headers: @valid_headers

      expect(response).to have_http_status(:ok)
    end

    it 'renders json with lists of verified and unverified avatars' do
      get avatars_path, headers: @valid_headers

      expect(eval(response.body)).to include(:avatars)
      expect(eval(response.body)[:avatars]).to include(:verified, :unverified)
      expect(eval(response.body)[:avatars][:verified].length).to eq(Avatar.all.where(verified: true).length)
      expect(eval(response.body)[:avatars][:unverified].length).to eq(Avatar.all.where(verified: false).length)
      expect(eval(response.body)[:avatars][:verified][0]).to_not include(:id, :user_id, :created_at, :updated_at)
    end
  end

  context 'with non-admin logged in' do
    before(:example) do
      @non_admin_user = User.create!(username: 'non-admin', email: 'non@admin.com', password: 'pass')

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
      get avatars_path, headers: @valid_headers

      expect(response).to have_http_status(:forbidden)
    end

    it 'renders json for errors' do
      get avatars_path, headers: @valid_headers

      expect(eval(response.body)).to include(:errors)
      expect(eval(response.body)[:errors]).to include('Must be logged in as admin to view all avatars')
    end
  end

  context 'when not logged in' do
    it 'is forbidden' do
      get avatars_path

      expect(response).to have_http_status(:forbidden)
    end

    it 'renders json for errors' do
      get avatars_path

      expect(eval(response.body)).to include(:errors)
      expect(eval(response.body)[:errors]).to include('Must be logged in as admin to view all avatars')
    end
  end
end
