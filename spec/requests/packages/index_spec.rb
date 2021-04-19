require 'rails_helper'


RSpec.describe 'GET /packages' do
  before(:context) do
    @user = User.create!(username: "user", email: "user@email.com", password: 'pass')

    @user2 = User.create!(username: 'user2', email: 'user2@email.com', password: 'pass')

    (Random.rand(2) + 1).times.with_index do |i|
      Package.create!(name: "package #{i} name", creator_id: @user.id, privacy_mode: ['PRIVATE', 'PUBLIC', 'MONETIZED'].sample)
    end

    (Random.rand(2) + 1).times.with_index do |j|
      Package.create!(name: "package #{j + 3} name", creator_id: @user2.id)
    end

    post '/login', params: {
      user: {
        usernameOrEmail: @user.username,
        password: 'pass',
      },
    }

    @valid_headers = {
      'Authentication': eval(response.body)[:token]
    }
  end

  after(:context) do
    @user.destroy
    @user2.destroy
    Package.destroy_all
    remove_instance_variable(:@valid_headers)
  end

  context 'when logged in' do
    it 'succeeds' do
      get packages_path, headers: @valid_headers

      expect(response).to have_http_status(:ok)
    end

    it 'renders json for all owned and non-private packages' do
      get packages_path, headers: @valid_headers

      expect(eval(response.body)).to include(:packages)
      expect(eval(response.body)[:packages].length).to eq(Package.where.not(privacy_mode: 'PRIVATE').length + Package.where(privacy_mode: 'PRIVATE').where(creator_id: @user.id).length)
    end

    it 'does not render json for non-owned private packages' do
      get packages_path, headers: @valid_headers

      expect(eval(response.body)).to include(:packages)
      expect(eval(response.body)[:packages].map {|package| {package[:creator_id] => package[:privacy_mode]}}).to_not include({@user2.id.to_s.to_sym => 'PRIVATE'})
    end
  end

  context 'when not logged in' do
    it 'succeeds' do
      get packages_path

      expect(response).to have_http_status(:ok)
    end

    it 'renders json for all non-private packages' do
      get packages_path

      expect(eval(response.body)).to include(:packages)
      expect(eval(response.body)[:packages].length).to eq(Package.where.not(privacy_mode: 'PRIVATE').length)
    end

    it 'does not render any private packages' do
      get packages_path

      expect(eval(response.body)[:packages].map {|package| package[:privacy_mode]}).to_not include('PRIVATE')
    end
  end
end
