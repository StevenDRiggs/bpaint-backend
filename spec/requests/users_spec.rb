require 'rails_helper'


RSpec.describe "/users", type: :request do
  # This should return the minimal set of attributes required to create a valid
  # User. As you add validations to User, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    {
      username: Faker::Movies::HarryPotter.character,
      email: Faker::Internet.email,
      password: 'password',
    }
  }

  let(:invalid_attributes) {
    {
      username: ['', 'bitch', 'b1tch'].sample,
      email: 'notanemail',
      password: ['', 'bitch', 'b1tch'].sample,
    }
  }

  # This should return the minimal set of values that should be in the headers
  # in order to pass any filters (e.g. authentication) defined in
  # UsersController, or in your router and rack
  # middleware. Be sure to keep this updated too.
  let(:valid_headers) {
    {
      'Content-Type': 'application/json',
    }
  }

  describe "GET /index" do
    context 'with admin logged in' do
      before(:example) do
        user = User.create!(username: 'admin', email: 'admin@admin.com', password: 'pass', is_admin: true)

        post '/login', params: {
          user: {
            usernameOrEmail: user.username,
            password: 'pass',
          }
        }

        valid_headers['Authentication'] = eval(response.body)[:token]
      end

      it "renders a successful response" do
        User.create! valid_attributes

        get users_url, headers: valid_headers, as: :json

        expect(response).to have_http_status(:ok)
      end

      it 'returns json listing all users' do
        3.times do |i|
          User.create!(username: "#{valid_attributes[:username]}_#{i}", email: Faker::Internet.email(name: i), password: valid_attributes[:password])
        end

        get users_url, headers: valid_headers, as: :json

        expect(eval(response.body).length).to eq(4)
      end
    end

    context 'with non-admin logged in' do
      before(:example) do
        user = User.create!(username: 'non-admin', email: 'nonadmin@nonadmin.com', password: 'pass')

        post '/login', params: {
          user: {
            usernameOrEmail: user.username,
            password: 'pass',
          }
        }

        valid_headers['Authentication'] = eval(response.body)[:token]
      end

      it 'renders a JSON response with errors' do
        get users_url, headers: valid_headers, as: :json

        expect(response).to have_http_status(:forbidden)
        expect(eval(response.body)).to include(:errors)
        expect(eval(response.body)[:errors]).to include('Must be logged in as admin')
      end
    end
  end

  describe "GET /show" do
    context 'with admin logged in' do
      before(:example) do
        @admin_user = User.create!(username: 'admin', email: 'admin@admin.com', password: 'pass', is_admin: true)
        @other_user = User.create!(username: 'other', email: 'other@admin.com', password: 'pass')

        post '/login', params: {
          user: {
            usernameOrEmail: @admin_user.username,
            password: 'pass',
          }
        }

        valid_headers['Authentication'] = eval(response.body)[:token]
      end

      it "renders a successful response" do
        get user_url(@admin_user), headers: valid_headers, as: :json

        expect(response).to have_http_status(:ok)

        get user_url(@other_user), headers: valid_headers, as: :json

        expect(response).to have_http_status(:ok)
      end

      it 'returns json describing the user' do
        get user_url(@admin_user), headers: valid_headers, as: :json

        expect(eval(response.body)).to include(username: @admin_user.username, email: @admin_user.email, is_admin: @admin_user.is_admin).and include(:flags)

        get user_url(@other_user), headers: valid_headers, as: :json

        expect(eval(response.body)).to include(username: @other_user.username, email: @other_user.email, is_admin: @other_user.is_admin).and include(:flags)
      end
    end

    context 'with non-admin logged in' do
      context "on user's own site" do
        before(:example) do
          @non_admin_user = User.create!(username: 'non-admin', email: 'non@admin.com', password: 'pass')

          post '/login', params: {
            user: {
              usernameOrEmail: @non_admin_user.username,
              password: 'pass',
            }
          }

          valid_headers['Authentication'] = eval(response.body)[:token]
        end

        it "renders a successful response" do
          get user_url(@non_admin_user), headers: valid_headers, as: :json

          expect(response).to have_http_status(:ok)
        end

        it 'returns json describing the user' do
          get user_url(@non_admin_user), headers: valid_headers, as: :json

          expect(eval(response.body)).to include(username: @non_admin_user.username, email: @non_admin_user.email, is_admin: @non_admin_user.is_admin).and include(:flags)
        end
      end

      context "on other user's site" do
        before(:example) do
          @non_admin_user = User.create!(username: 'non-admin', email: 'non@admin.com', password: 'pass')
          @other_user = User.create!(username: 'other', email: 'other@admin.com', password: 'pass')

          post '/login', params: {
            user: {
              usernameOrEmail: @non_admin_user.username,
              password: 'pass',
            }
          }

          valid_headers['Authentication'] = eval(response.body)[:token]
        end

        it "has :forbidden status" do
          get user_url(@other_user), headers: valid_headers, as: :json

          expect(response).to have_http_status(:forbidden)
        end

        it 'returns json describing errors' do
          get user_url(@other_user), headers: valid_headers, as: :json

          expect(eval(response.body)).to include(:errors)
          expect(eval(response.body)[:errors]).to include('Must be logged in as admin')
        end
      end
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new User" do
        expect {
          post users_url, params: { user: valid_attributes }, headers: valid_headers, as: :json
        }.to change(User, :count).by(1)
      end

      it "renders a JSON response with the new user" do
        post users_url, params: { user: valid_attributes }, headers: valid_headers, as: :json

        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including("application/json"))
        expect(eval(response.body)).to include(:user, :token)
      end
    end

    context "with invalid parameters" do
      it "does not create a new User" do
        expect {
          post users_url, params: { user: invalid_attributes }, as: :json
        }.to change(User, :count).by(0)
      end

      it "renders a JSON response with errors for the new user" do
        post users_url, params: { user: invalid_attributes }, headers: valid_headers, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including("application/json"))
        expect(eval(response.body)).to include(:errors)
        expect(eval(response.body)[:errors]).to include('Username cannot include profanity').or include('Username must be at least 2 characters long').or include("Username can't be blank")
        expect(eval(response.body)[:errors]).to include('Email is not a valid email')
        expect(eval(response.body)[:errors]).to include('Password must not be the same as username').or include("Password can't be blank").or include('Password must be at least 1 character long')
      end
    end
  end

  xdescribe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) {
        {
          username: 'new test',
          email: Faker::Internet.email(name: 'new test'),
          password: 'new password',
        }
      }

      it "updates the requested user" do
        user = User.create! valid_attributes

        patch user_url(user), params: { user: new_attributes }, headers: valid_headers, as: :json

        user.reload

        expect(user.username).to eq(new_attributes[:username])
        expect(user.authenticate(new_attributes[:password])).to be(user)
      end

      it "renders a JSON response with the user" do
        user = User.create! valid_attributes

        patch user_url(user), params: { user: new_attributes }, headers: valid_headers, as: :json

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end

    context "with invalid parameters" do
      it "renders a JSON response with errors for the user" do
        user = User.create! valid_attributes

        patch user_url(user), params: { user: invalid_attributes }, headers: valid_headers, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end
  end

  xdescribe "DELETE /destroy" do
    it "destroys the requested user" do
      user = User.create! valid_attributes

      expect {
        delete user_url(user), headers: valid_headers, as: :json
      }.to change(User, :count).by(-1)
    end
  end

  describe 'POST /login' do
    context 'with valid parameters' do
      let(:user) {
        User.create!(username: 'login test', email: 'email@email.com', password: 'pass')
      }

      it "renders a JSON response with the logged in user" do
        post '/login', params: {
          user: {
            usernameOrEmail: user.email,
            password: 'pass'
          },
        }, headers: valid_headers, as: :json

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match(a_string_including("application/json"))
        expect(eval(response.body)).to include(:user, :token)
      end
    end
  end
end
