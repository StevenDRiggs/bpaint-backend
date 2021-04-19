require 'rails_helper'


RSpec.describe 'GET /packages/:id' do
  before(:context) do
    @user1 = User.create!(username: 'user1', email: 'user1@email.com', password: 'pass')
    @user2 = User.create!(username: 'user2', email: 'user2@email.com', password: 'pass')

    @user1_private_package = Package.create!(name: 'user1 private package', creator_id: @user1.id, privacy_mode: 'PRIVATE')
    @user1_public_package = Package.create!(name: 'user1 public package', creator_id: @user1.id, privacy_mode: 'PUBLIC')
    @user1_monetized_package = Package.create!(name: 'user1 monetized package', creator_id: @user1.id, privacy_mode: 'MONETIZED')

    @user2_private_package = Package.create!(name: 'user2 private package', creator_id: @user2.id, privacy_mode: 'PRIVATE')
    @user2_public_package = Package.create!(name: 'user2 public package', creator_id: @user2.id, privacy_mode: 'PUBLIC')
    @user2_monetized_package = Package.create!(name: 'user2 monetized package', creator_id: @user2.id, privacy_mode: 'MONETIZED')
  end

  after(:context) do

  end

  context 'when logged in' do
    context 'when viewing own package' do
      it 'succeeds' do
      end

      it 'renders json for package' do
      end
    end

    context "when viewing other's package" do
      context 'when viewing non-private package' do
        it 'succeeds' do
        end

        it 'renders json for package' do
        end
      end

      context 'when viewing private package' do
        it 'is forbidden' do
        end

        it 'does not render json for package' do
        end

        it 'renders json for errors' do
        end
      end
    end
  end

  context 'when not logged in' do
    context 'when viewing non-private package' do
      it 'succeeds' do
      end

      it 'renders json for package' do
      end
    end

    context 'when viewing private package' do
      it 'is forbidden' do
      end

      it 'does not render json for package' do
      end

      it 'renders json for errors' do
      end
    end
  end
end
