require 'rails_helper'


RSpec.describe 'GET /avatars' do
  before(:context) do
    @admin_user = User.create!(username: 'admin', email: 'admin@admin.com', password: 'pass')
    @non_admin_user = User.create!(username: 'non-admin', email: 'non@admin.com', password: 'pass')

    @admin_av = Avatar.create!(name: 'admin av', url: Faker::Internet.url, user: @admin_user)
    @non_admin_av = Avatar.create!(name: 'non-admin av', url: Faker::Internet.url, user: @non_admin_user)
  end

  after(:context) do
    @admin_user.destroy
    @non_admin_user.destroy
    @admin_av.destroy
    @non_admin_av.destroy
  end

  context 'when logged in' do
    context 'as admin' do
      it 'succeeds' do
      end

      it 'renders json for all avatars' do
      end
    end

    context 'as non-admin' do
      it 'is forbidden' do
      end

      it 'does not render json for avatars' do
      end

      it 'renders json for errors' do
      end
    end
  end

  context 'when not logged in' do
    it 'is forbidden' do
    end

    it 'does not render json for avatars' do
    end

    it 'renders json for errors' do
    end
  end
end
