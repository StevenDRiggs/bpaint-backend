require 'rails_helper'


RSpec.describe Avatar do
  before(:context) do
    @user = User.create!(username: 'user', email: 'user@email.com', password: 'pass')
  end

  after(:context) do
    @user.destroy
  end

  context 'with valid params' do
    let(:valid_params) {
      {
        name: 'avatar name',
        url: Faker::Internet.url,
        user: @user,
      }
    }

    it 'creates avatar' do
      expect {
        Avatar.create(valid_params)
      }.to change {Avatar.all.length}.by(1)
    end
  end

  context 'with invalid params' do
    before(:context) do
      @invalid_params = {
        name: 'avatar name',
        url: Faker::Internet.url,
        user: @user,
      }
    end

    after(:context) do
      remove_instance_variable(:@invalid_params)
    end

    context 'when validating url' do
      context 'with blank url' do
        before(:context) do
          @invalid_params[:url] = ''
        end

        after(:context) do
          @invalid_params[:url] = Faker::Internet.url
        end

        it 'does not create avatar' do
          expect {
            Avatar.create(@invalid_params)
          }.to_not change {Avatar.all.length}
        end
      end

      context 'with invalid url' do
        before(:context) do
          @invalid_params[:url] = 'notaurl'
        end

        after(:context) do
          @invalid_params[:url] = Faker::Internet.url
        end

        it 'does not create avatar' do
          expect {
            Avatar.create(@invalid_params)
          }.to_not change {Avatar.all.length}
        end
      end
    end

    context 'when validating name' do
      context 'with blank name' do
        before(:context) do
          @invalid_params[:name] = ''
        end

        after(:context) do
          @invalid_params[:name] = 'avatar name'
        end

        it 'does not create avatar' do
          expect {
            Avatar.create(@invalid_params)
          }.to_not change {Avatar.all.length}
        end
      end

      context 'with name too short' do
        before(:context) do
          @invalid_params[:name] = '1'
        end

        after(:context) do
          @invalid_params[:name] = 'avatar name'
        end

        it 'does not create avatar' do
          expect {
            Avatar.create(@invalid_params)
          }.to_not change {Avatar.all.length}
        end
      end

      context 'with profane name' do
        before(:context) do
          @invalid_params[:name] = ['bitch', 'b1tch'].sample
        end

        after(:context) do
          @invalid_params[:name] = 'avatar name'
        end

        it 'does not create avatar' do
          expect {
            Avatar.create(@invalid_params)
          }.to_not change {Avatar.all.length}
        end
      end
    end
  end
end
