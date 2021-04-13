require 'rails_helper'


RSpec.describe Avatar do
  before(:context) do
    @user = User.create!(username: 'user', email: 'user@email.com', password: 'pass', is_admin: true)
    @valid_url = 'https://picsum.photos/100/100'
    @valid_name = 'valid name'
    @valid_params = {
      url: @valid_url,
      name: @valid_name,
      user: @user,
    }
  end

  after(:context) do
    @user.destroy
    remove_instance_variable(:@valid_params)
    remove_instance_variable(:@valid_url)
    remove_instance_variable(:@valid_name)
  end

  context 'with valid params' do
    it 'creates avatar' do
      av = Avatar.new(@valid_params)

      expect(av.save).to be(true)
    end

    it 'updates avatar' do
      av = Avatar.create!(url: 'https://stevendriggs.herokuapp.com', name: 'test av', user: @user)

      expect(av.update(@valid_params)).to be(true)
    end
  end

  context 'with invalid params' do
    before(:context) do
      @invalid_params = {
        url: @valid_url,
        name: @valid_name,
        user: @user,
      }
    end

    after(:context) do
      remove_instance_variable(:@invalid_params)
    end

    context 'when validating url' do
      context 'with blank url' do
        before(:example) do
          @invalid_params[:url] = ''
        end

        it 'does not create avatar' do
          av = Avatar.new(@invalid_params)

          expect(av.save).to be(false)
        end

        it 'does not update avatar' do
          av = Avatar.create!(@valid_params)

          expect(av.update(@invalid_params)).to be(false)
        end
      end

      context 'with invalid url' do
        before(:example) do
          @invalid_params[:url] = 'notaurl'
        end

        it 'does not create avatar' do
          av = Avatar.new(@invalid_params)

          expect(av.save).to be(false)
        end

        it 'does not update avatar' do
          av = Avatar.create!(@valid_params)

          expect(av.update(@invalid_params)).to be(false)
        end
      end
    end

    context 'when validating name' do
      context 'with blank name' do
        before(:example) do
          @invalid_params[:name] = ''
        end

        it 'does not create avatar' do
          av = Avatar.new(@invalid_params)

          expect(av.save).to be(false)
        end

        it 'does not update avatar' do
          av = Avatar.create!(@valid_params)

          expect(av.update(@invalid_params)).to be(false)
        end
      end

      context 'with name too short' do
        before(:example) do
          @invalid_params[:name] = '1'
        end

        it 'does not create avatar' do
          av = Avatar.new(@invalid_params)

          expect(av.save).to be(false)
        end

        it 'does not update avatar' do
          av = Avatar.create!(@valid_params)

          expect(av.update(@invalid_params)).to be(false)
        end
      end

      context 'with profane name' do
        before(:example) do
          @invalid_params[:name] = ['bitch', 'b1tch'].sample
        end

        it 'does not create avatar' do
          av = Avatar.new(@invalid_params)

          expect(av.save).to be(false)
        end

        it 'does not update avatar' do
          av = Avatar.create!(@valid_params)

          expect(av.update(@invalid_params)).to be(false)
        end
      end
    end
  end
end
