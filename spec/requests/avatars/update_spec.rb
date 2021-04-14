require 'rails_helper'


RSpec.describe 'PATCH /avatars/:id' do
  before(:context) do
    @self_user = User.create!(username: 'self user', email: 'self@user.com', password: 'pass')

    post '/login', params: {
      user: {
        usernameOrEmail: 'self user',
        password: 'pass',
      },
    }

    @valid_headers = {
      'Authentication': eval(response.body)[:token],
    }

    @orig_av = Avatar.create!(url: Faker::Internet.url, name: 'orig av', user: @self_user)

    @new_av_params = {
      avatar: {
        url: Faker::Internet.url,
        name: 'new av name',
      }
    }
  end

  after(:context) do
    @self_user.destroy
    @orig_av.destroy
    remove_instance_variable(:@valid_headers)
    remove_instance_variable(:@new_av_params)
  end

  context 'when updating own avatar' do
    it 'succeeds' do
      patch avatar_path(@orig_av), headers: @valid_headers, params: @new_av_params

      expect(response).to have_http_status(:ok)
    end

    it 'updates avatar' do
      patch avatar_path(@orig_av), headers: @valid_headers, params: @new_av_params

      @self_user.reload

      expect(@self_user.avatar.url).to eq(@new_av_params[:avatar][:url])
    end

    it 'renders json for updated avatar' do
      patch avatar_path(@orig_av), headers: @valid_headers, params: @new_av_params

      expect(eval(response.body)).to include(:avatar)
      expect(eval(response.body)[:avatar]).to include(url: @new_av_params[:avatar][:url], name: @new_av_params[:avatar][:name])
    end
  end

  context "when updating other's avatar" do
    let(:other_user) {
      User.create!(username: 'other user', email: 'other@user.com', password:'pass')
    }

    let(:other_user_av) {
      Avatar.create!(url: Faker::Internet.url, name: 'other user av name', user: other_user)
    }

    it 'is forbidden' do
      patch avatar_path(other_user_av), headers: @valid_headers, params: @new_av_params

      expect(response).to have_http_status(:forbidden)
    end

    it 'does not update avatar' do
      patch avatar_path(other_user_av), headers: @valid_headers, params: @new_av_params

      other_user.reload

      expect(other_user.avatar.url).to_not eq(@new_av_params[:avatar][:url])
      expect(other_user.avatar.name).to_not eq(@new_av_params[:avatar][:name])
    end

    it 'renders json for errors' do
      patch avatar_path(other_user_av), headers: @valid_headers, params: @new_av_params

      expect(eval(response.body)).to include(:errors)
      expect(eval(response.body)).to_not include(:avatar)
      expect(eval(response.body)[:errors]).to include('May only update own avatar')
    end
  end

  context 'when not logged in' do
    it 'is forbidden' do
      patch avatar_path(@orig_av), params: @new_av_params

      expect(response).to have_http_status(:forbidden)
    end

    it 'does not update avatar' do
      patch avatar_path(@orig_av), params: @new_av_params

      @self_user.reload

      expect(@self_user.avatar.url).to_not eq(@new_av_params[:avatar][:url])
      expect(@self_user.avatar.name).to_not eq(@new_av_params[:avatar][:name])
    end

    it 'renders json for errors' do
      patch avatar_path(@orig_av), params: @new_av_params

      expect(eval(response.body)).to include(:errors)
      expect(eval(response.body)).to_not include(:avatar)
      expect(eval(response.body)[:errors]).to include('May only update own avatar')
    end
  end
end
