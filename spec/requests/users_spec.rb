require 'rails_helper'


RSpec.describe "/users", type: :request do
  # This should return the minimal set of attributes required to create a valid
  # User. As you add validations to User, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    {
      username: Faker::Movies::HarryPotter.character,
      password: 'password',
    }
  }

  let(:invalid_attributes) {
    {
      username: ['', 'bitch', 'b1tch'].sample,
      password: ['', 'bitch', 'b1tch'].sample,
    }
  }

  # This should return the minimal set of values that should be in the headers
  # in order to pass any filters (e.g. authentication) defined in
  # UsersController, or in your router and rack
  # middleware. Be sure to keep this updated too.
  let(:valid_headers) {
    {}
  }

  describe "GET /index" do
    it "renders a successful response" do
      User.create! valid_attributes
      get users_url, headers: valid_headers, as: :json
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      user = User.create! valid_attributes
      get user_url(user), as: :json
      expect(response).to be_successful
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
        expect(eval(response.body)[:username]).to include('cannot include profanity').or include('must be at least 2 characters long').or include("can't be blank")
        expect(eval(response.body)[:password]).to include('must not be the same as username').or include("can't be blank").or include('must be at least 1 character long').or be(nil)
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) {
        {
          username: 'new test',
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

  describe "DELETE /destroy" do
    it "destroys the requested user" do
      user = User.create! valid_attributes
      expect {
        delete user_url(user), headers: valid_headers, as: :json
      }.to change(User, :count).by(-1)
    end
  end
end
