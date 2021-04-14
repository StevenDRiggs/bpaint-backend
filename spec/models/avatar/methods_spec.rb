require 'rails_helper'


RSpec.describe Avatar do
  describe 'instance methods' do
    describe '#as_json (overwrite)' do
      let(:user) {
        User.create!(username: 'user', email: 'user@email.com', password: 'pass')
      }

      let(:av) {
        Avatar.create!(url: Faker::Internet.url, name: 'avatar name', user: user)
      }

      it 'renders json for all attributes except :id, :user_id, :created_at, :updated_at' do
        expect(av.as_json).to include('url' => av.url, 'name' => av.name, 'verified' => av.verified)
        expect(user.as_json).to_not include(:id, :user_id, :created_at, :updated_at)
      end
    end
  end
end
