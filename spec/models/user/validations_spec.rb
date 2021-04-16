require 'rails_helper'

RSpec.describe User, type: :model do
  before(:context) do
    @valid_username = 'valid username'
    @valid_email = 'valid@email.com'
    @valid_password = 'pass'
    @valid_params = {
      username: @valid_username,
      email: @valid_email,
      password: @valid_password,
    }
  end

  after(:context) do
    remove_instance_variable(:@valid_params)
    remove_instance_variable(:@valid_username)
    remove_instance_variable(:@valid_email)
    remove_instance_variable(:@valid_password)
  end

  context 'with valid_params' do
    it 'creates user' do
      user = User.new(@valid_params)

      expect(user.save).to be(true)
    end

    it 'updates user' do
      user = User.new(username: 'also valid', email: 'also@valid.com', password: 'pass')

      expect(user.update(@valid_params)).to be(true)
    end
  end

  context 'with invalid params' do
    context 'when validating username' do
      before(:context) do
        @invalid_params = {
          email: @valid_email,
          password: @valid_password,
        }
      end

      after(:context) do
        remove_instance_variable(:@invalid_params)
      end

      context 'when username is blank' do
        before(:example) do
          @invalid_params[:username] = ''
        end

        it 'does not create user' do
          user = User.new(@invalid_params)

          expect(user.save).to be(false)
        end

        it 'does not update user' do
          user = User.create!(@valid_params)

          expect(user.update(@invalid_params)).to be(false)
        end
      end

      context 'when username is too short' do
        before(:example) do
          @invalid_params[:username] = '1'
        end

        it 'does not create user' do
          user = User.new(@invalid_params)

          expect(user.save).to be(false)
        end

        it 'does not update user' do
          user = User.create!(@valid_params)

          expect(user.update(@invalid_params)).to be(false)
        end
      end

      context 'when username is profane' do
        before(:example) do
          @invalid_params[:username] = ['bitch', 'b1tch'].sample
        end

        it 'does not create user' do
          user = User.new(@invalid_params)

          expect(user.save).to be(false)
        end

        it 'does not update user' do
          user = User.create!(@valid_params)

          expect(user.update(@invalid_params)).to be(false)
        end
      end
    end

    context 'when validating email' do
      before(:context) do
        @invalid_params = {
          username: @valid_username,
          password: @valid_pssword,
        }
      end

      after(:context) do
        remove_instance_variable(:@invalid_params)
      end

      context 'when email is blank' do
        before(:example) do
          @invalid_params[:email] = ''
        end

        it 'does not create user' do
          user = User.new(@invalid_params)

          expect(user.save).to be(false)
        end

        it 'does not update user' do
          user = User.new(@valid_params)

          expect(user.update(@invalid_params)).to be(false)
        end
      end

      context 'when email is not a valid address' do
        before(:example) do
          @invalid_params[:email] = 'notanemail'
        end

        it 'does not create user' do
          user = User.new(@invalid_params)

          expect(user.save).to be(false)
        end

        it 'does not update user' do
          user = User.new(@valid_params)

          expect(user.update(@invalid_params)).to be(false)
        end
      end

      context 'when email is profane' do
        before(:example) do
          @invalid_params[:email] = "#{['bitch', 'b1tch'].sample}@email.com"
        end

        it 'does not create user' do
          user = User.new(@invalid_params)

          expect(user.save).to be(false)
        end

        it 'does not update user' do
          user = User.new(@valid_params)

          expect(user.update(@invalid_params)).to be(false)
        end
      end
    end

    context 'when validating password' do
      before(:context) do
        @invalid_params = {
          username: @valid_username,
          email: @valid_email,
        }
      end

      after(:context) do
        remove_instance_variable(:@invalid_params)
      end

      context 'when password is blank' do
        before(:example) do
          @invalid_params[:password] = ''
        end

        it 'does not create user' do
          user = User.new(@invalid_params)

          expect(user.save).to be(false)
        end

        it 'does not update user password' do
          user = User.new(@valid_params)

          user.update(@invalid_params)

          expect(user.authenticate(@invalid_params[:password])).to be(false)
        end
      end

      context 'when password is too short' do
        before(:example) do
          @invalid_params[:password] = '1'
        end

        it 'does not create user' do
          user = User.new(@invalid_params)

          expect(user.save).to be(false)
        end

        it 'does not update user' do
          user = User.new(@valid_params)

          expect(user.update(@invalid_params)).to be(false)
        end
      end

      context 'when password is the same as username' do
        before(:example) do
          @invalid_params[:password] = @invalid_params[:username]
        end

        it 'does not create user' do
          user = User.new(@invalid_params)

          expect(user.save).to be(false)
        end

        it 'does not update user' do
          user = User.new(@valid_params)

          expect(user.update(@invalid_params)).to be(false)
        end
      end
    end
  end

  it 'validates uniqueness' do
    User.create!(username: 'user1', email: 'user1@email.com', password: 'pass')
    user2 = User.create!(username: 'user2', email: 'user2@email.com', password: 'pass')

    expect(user2.update(username: 'user1', email: 'user1@email.com', password: 'pass')).to be(false)
  end
end
