require 'rails_helper'


RSpec.describe Package do
  before(:context) do
    @user = User.create!(username: 'user', email: 'user@user.com', password: 'pass')
  end

  after(:context) do
    @user.destroy
  end

  context 'with valid params' do
    let(:valid_params) {
      {
        name: 'package name',
        creator_id: @user.id,
        privacy_mode: ['PRIVATE', 'PUBLIC', 'MONETIZED'].sample,
      }
    }

    it 'creates package' do
      expect {
        Package.create(valid_params)
      }.to change {Package.all.length}.by(1)
    end
  end

  context 'with invalid params' do
    before(:context) do
      @invalid_params = {
        name: 'package name',
        creator_id: @user.id,
        privacy_mode: ['PRIVATE', 'PUBLIC', 'MONETIZED'].sample,
      }
    end

    after(:context) do
      binding.pry
      remove_instance_variable(:@invalid_params)
    end

    context 'with blank name' do
      it 'does not create package' do
        @invalid_params[:name] = ''

        expect {
          Package.create(@invalid_params)
        }.to_not change {Package.all.length}
      end
    end

    context 'with profane name' do
      it 'does not create package' do
        @invalid_params[:name] = ['bitch', 'b1tch'].sample

        expect {
          Package.create(@invalid_params)
        }.to_not change {Package.all.length}
      end
    end

    context 'with blank creator_id'do
      it 'does not create package' do
        @invalid_params[:creator_id] = nil

        expect {
          Package.create(@invalid_params)
        }.to_not change {Package.all.length}
      end
    end

    context 'with invalid privacy_mode' do
      it 'does not create package' do
        @invalid_params[:privacy_mode] = 'invalid'

        expect {
          binding.pry
          Package.create(@invalid_params)
        }.to_not change {Package.all.length}
      end
    end
  end
end
