require 'rails_helper'


RSpec.describe 'POST /avatars' do
  before(:context) do
    @self_user = User.create!(username: 'self', email: 'self@user.com', password: 'pass')

    post '/login', params: {
      user: {
        usernameOrEmail: @self_user.username,
        password: 'pass',
      },
    }

    @valid_headers = {
      'Authentication': eval(response.body)[:token]
    }

    @av_params = {
      avatar: {
        url: Faker::Internet.url,
        name: 'av name',
        user_id: @self_user.id,
      },
    }

  end

  after(:context) do
    @self_user.destroy
    remove_instance_variable(:@valid_headers)
    remove_instance_variable(:@av_params)
  end

  context 'when creating own avatar' do
    it 'succeeds' do
      post avatars_path, headers: @valid_headers, params: @av_params

      expect(response).to have_http_status(:created)
    end

    it 'creates avatar' do
      post avatars_path, headers: @valid_headers, params: @av_params

      expect(@self_user.avatar).to eq(Avatar.last)
    end

    it 'renders json for avatar' do
      post avatars_path, headers: @valid_headers, params: @av_params

      expect(eval(response.body)).to include(:avatar)
      expect(eval(response.body)[:avatar]).to include(url: @av_params[:avatar][:url], name: @av_params[:avatar][:name], verified: false)
      expect(eval(response.body)[:avatar]).to_not include(:id, :created_at, :updated_at, :user_id)
    end
  end

  context "when creating other's avatar" do
    let(:other_user) {
      User.create!(username: 'other', email: 'other@user.com', password: 'pass')
    }

    before(:example) {
      @av_params[:avatar][:user_id] = other_user.id
    }

    it 'is forbidden' do
      post avatars_path, headers: @valid_headers, params: @av_params

      expect(response).to have_http_status(:forbidden)
    end

    it 'does not create avatar' do
      post avatars_path, headers: @valid_headers, params: @av_params
      
      expect(other_user.avatar).to be(nil)
    end

    it 'renders json for errors' do
      post avatars_path, headers: @valid_headers, params: @av_params
      
      expect(eval(response.body)).to include(:errors)
      expect(eval(response.body)[:errors]).to include('May only create own avatar')
    end
  end

  context 'when not logged in' do
    before(:example) do
      @self_user.reload
    end

    it 'is forbidden' do
      post avatars_path, params: @av_params

      expect(response).to have_http_status(:forbidden)
    end

    it 'does not create avatar' do
      post avatars_path, params: @av_params

      expect(@self_user.avatar).to be(nil)
    end

    it 'renders json for errors' do
      post avatars_path, params: @av_params

      expect(eval(response.body)).to include(:errors)
      expect(eval(response.body)[:errors]).to include('May only create own avatar')
    end
  end
end
