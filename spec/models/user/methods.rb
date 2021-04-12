require 'rails_helper'


RSpec.describe User do
  describe 'class methods' do
    describe '.find_by_username_or_email' do
      let(:user) {
        User.create!(username: 'user', email: 'user@email.com', password: 'pass')
      }

      it 'finds a user by username' do
        expect(User.find_by_username_or_email(user.username)).to eq(user)
      end

      it 'finds a user by email' do
        expect(User.find_by_username_or_email(user.email)).to eq(user)
      end

      it 'returns nil when user not found' do
        expect(User.find_by_username_or_email('wrong')).to be(nil)
      end
    end
  end

  describe 'instance methods' do
    describe 'as_json (overwrite)' do
      let(:user) {
        User.create!(username: 'user', email: 'user@email.com', password: 'pass')
      }

      it 'renders json for all attributes except :id, :password_digest, :created_at, :updated_at' do
        expect(user.as_json).to include('username' => user.username, 'email' => user.email, 'is_admin' => user.is_admin, 'flags' => user.flags)
        expect(user.as_json).to_not include(:id, :password_digest, :created_at, :updated_at)
      end
    end
  end
end
