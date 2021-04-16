require 'rails_helper'


RSpec.describe 'DELETE /avatars/:id' do
  before(:context) do
    @admin_user = User.create!(username: 'admin', email: 'admin@admin.com', password: 'pass', is_admin: true)
    @admin_user_av = Avatar.create!(url: Faker::Internet.url, name: 'admin av name', user: @admin_user)
    @non_admin_user = User.create!(username: 'non-admin', email: 'non@admin.com', password: 'pass')
    @non_admin_user_av = Avatar.create!(url: Faker::Internet.url, name: 'non-admin av name', user: @non_admin_user)
  end

  after(:context) do
    @admin_user.destroy
    @admin_user_av.destroy
    @non_admin_user.destroy
    @non_admin_user_av.destroy
  end

  context 'with admin logged in' do
    before(:example) do
      @admin_user.reload
      @admin_user_av.reload
      @non_admin_user.reload
      @non_admin_user_av.reload

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
      delete avatar_path(@admin_user_av), headers: @valid_headers

      expect(response).to have_http_status(:ok)

      delete avatar_path(@non_admin_user_av), headers: @valid_headers

      expect(response).to have_http_status(:ok)
    end

    it 'deletes avatar' do
      delete avatar_path(@admin_user_av), headers: @valid_headers

      expect {
        Avatar.find(@admin_user_av.id)
      }.to raise_exception(ActiveRecord::RecordNotFound)

      delete avatar_path(@non_admin_user_av), headers: @valid_headers

      expect {
        Avatar.find(@non_admin_user_av.id)
      }.to raise_exception(ActiveRecord::RecordNotFound)
    end

    it 'renders json success message' do
      delete avatar_path(@admin_user_av), headers: @valid_headers

      expect(eval(response.body)).to include(:avatar)
      expect(eval(response.body)[:avatar]).to eq('DELETED')

      delete avatar_path(@non_admin_user_av), headers: @valid_headers

      expect(eval(response.body)).to include(:avatar)
      expect(eval(response.body)).to_not include(:errors)
      expect(eval(response.body)[:avatar]).to eq('DELETED')
    end
  end

  context 'with non-admin logged in' do
    before(:context) do
      @admin_user.reload
      @admin_user_av.reload
      @non_admin_user.reload
      @non_admin_user_av.reload

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

    after(:context) do
      remove_instance_variable(:@valid_headers)
    end

    context 'when deleting own avatar' do
      it 'succeeds' do
        delete avatar_path(@non_admin_user_av), headers: @valid_headers

        expect(response).to have_http_status(:ok)
      end

      it 'deletes avatar' do
        delete avatar_path(@non_admin_user_av), headers: @valid_headers

        expect {
          Avatar.find(@non_admin_user_av.id)
        }.to raise_exception(ActiveRecord::RecordNotFound)
      end

      it 'renders json success message' do
        delete avatar_path(@non_admin_user_av), headers: @valid_headers

        expect(eval(response.body)).to include(:avatar)
        expect(eval(response.body)).to_not include(:errors)
        expect(eval(response.body)[:avatar]).to eq('DELETED')
      end
    end

    context "when deleting other's avatar" do
      it 'is forbidden' do
        delete avatar_path(@admin_user_av), headers: @valid_headers

        expect(response).to have_http_status(:forbidden)
      end

      it 'does not delete avatar' do
        delete avatar_path(@admin_user_av), headers: @valid_headers

        expect {
          Avatar.find(@admin_user_av.id)
        }.to_not raise_exception
      end

      it 'renders json for errors' do
        delete avatar_path(@admin_user_av), headers: @valid_headers

        expect(eval(response.body)).to include(:errors)
        expect(eval(response.body)).to_not include(:avatar)
        expect(eval(response.body)[:errors]).to include('Must be logged in as admin to delete other avatars')
      end
    end
  end

  context 'when not logged in' do
    it 'is forbidden' do
      delete avatar_path(@admin_user_av)

      expect(response).to have_http_status(:forbidden)
    end

    it 'does not delete avatar' do
      delete avatar_path(@admin_user_av)

      expect {
        Avatar.find(@admin_user_av.id)
      }.to_not raise_exception
    end

    it 'renders json for errors' do
      delete avatar_path(@admin_user_av)

      expect(eval(response.body)).to include(:errors)
      expect(eval(response.body)).to_not include(:avatar)
      expect(eval(response.body)[:errors]).to include('Must be logged in as admin to delete other avatars')
    end
  end
end
