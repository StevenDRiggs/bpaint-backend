require 'rails_helper'


RSpec.describe "POST /users", type: :request do
  context 'with valid params' do
    let(:valid_params) {
      {
        user: {
          username: 'valid username',
          email: 'valid@email.com',
          password: 'pass',
        },
      }
    }

    it 'is created' do
      post users_path, params: valid_params

      expect(response).to have_http_status(:created)
    end

    it 'creates new user' do
      expect {
        post users_path, params: valid_params
      }.to change {
        User.all.length
      }.by(1)
    end

    it 'renders json for new user' do
      post users_path, params: valid_params

      expect(eval(response.body)).to include(:user, :token)
      expect(eval(response.body)[:user]).to include(username: 'valid username', email: 'valid@email.com')
      expect(eval(response.body)[:user]).to include(:flags)
      expect(eval(response.body)[:user]).to_not include(:id, :password_digest, :created_at, :updated_at)
    end
  end

  context 'with invalid params' do
    let(:invalid_params) {
      {
        user: {
          username: '',
          email: '',
          password: '',
        }
      }
    }

    it 'is unprocessable' do
      post users_path, params: invalid_params

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'does not create new user' do
      expect {
        post users_path, params: invalid_params
      }.to_not change {
        User.all.length
      }
    end

    it 'renders json for errors' do
      post users_path, params: invalid_params

      # exact error messages are tested in models/user/validations_spec.rb
      expect(eval(response.body)).to include(:errors)
    end
  end
end
