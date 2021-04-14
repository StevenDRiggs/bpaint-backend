require 'rails_helper'


RSpec.describe 'GET /avatars/:id' do
  let(:user) {
    User.create!(username: Faker::JapaneseMedia::DragonBall.character, email: Faker::Internet.email, password: 'pass')
  }

  let(:av) {
    Avatar.create!(url: Faker::Internet.url, name: Faker::JapaneseMedia::DragonBall.planet, user: user)
  }

  it 'succeeds' do
    get avatar_path(av)

    expect(response).to have_http_status(:ok)
  end

  context 'when verified' do
    before(:example) do
      av.update_attribute(:verified, true)
    end

    it 'renders json for the avatar' do
      get avatar_path(av)

      expect(eval(response.body)).to include(:avatar)
      expect(eval(response.body)[:avatar]).to include(:url, :name)
    end
  end

  context 'when unverified' do
    it 'renders json for unverified' do
      get avatar_path(av)

      expect(eval(response.body)).to include(:avatar)
      expect(eval(response.body)[:avatar]).to_not be_a(Hash)
      expect(eval(response.body)[:avatar]).to eq('unverified')
    end
  end
end
