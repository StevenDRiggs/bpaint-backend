require 'rails_helper'


RSpec.describe "/avatars", type: :request do
  # This should return the minimal set of attributes required to create a valid
  # Avatar. As you add validations to Avatar, be sure to
  # adjust the attributes here as well.
  let(:user) {
    User.create!(username: 'test', password: 'password')
  }

  let(:valid_attributes) {
    {
      url: 'https://picsum.photos/100/100',
      name: Faker::Quote.famous_last_words.split[0..5].join('_').downcase.gsub(/[^a-z_]/, ''),
      user_id: user.id,
    }
  }

  let(:invalid_url) {
    'notaurl'
  }

  let(:invalid_name_blank) {
    ''
  }

  let(:invalid_name_profane) {
    'bitch'
  }

  let(:invalid_name_profane_leet) {
    'b1tch'
  }

  let(:invalid_user_id) {
    user.id + 1
  }

  let(:invalid_attributes_blank_name) {
    {
      url: invalid_url,
      name: invalid_name_blank,
      user_id: invalid_user_id,
    }
  }

  let(:invalid_attributes_profane_name) {
    {
      url: invalid_url,
      name: invalid_name_blank,
      user_id: invalid_user_id,
    }
  }

  let(:invalid_attributes_profane_name_leet) {
    {
      url: invalid_url,
      name: invalid_name_blank,
      user_id: invalid_user_id,
    }
  }

  # This should return the minimal set of values that should be in the headers
  # in order to pass any filters (e.g. authentication) defined in
  # AvatarsController, or in your router and rack
  # middleware. Be sure to keep this updated too.
  let(:valid_headers) {
    {}
  }

  describe "GET /index" do
    it "renders a successful response" do
      Avatar.create! valid_attributes
      get avatars_url, headers: valid_headers, as: :json
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      avatar = Avatar.create! valid_attributes
      get avatar_url(avatar), as: :json
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Avatar" do
        expect {
          post avatars_url,
          params: { avatar: valid_attributes }, headers: valid_headers, as: :json
        }.to change(Avatar, :count).by(1)
      end

      it "renders a JSON response with the new avatar" do
        post avatars_url,
          params: { avatar: valid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end

    context "with invalid parameters" do
      it "does not create a new Avatar" do
        expect {
          post avatars_url, params: { avatar: invalid_attributes_blank_name }, as: :json
        }.to change(Avatar, :count).by(0)

        expect {
          post avatars_url, params: { avatar: invalid_attributes_profane_name }, as: :json
        }.to change(Avatar, :count).by(0)

        expect {
          post avatars_url, params: { avatar: invalid_attributes_profane_name_leet }, as: :json
        }.to change(Avatar, :count).by(0)
      end

      it "renders a JSON response with errors for the new avatar" do
        post avatars_url, params: { avatar: invalid_attributes_blank_name }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including("application/json"))

        post avatars_url, params: { avatar: invalid_attributes_profane_name }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including("application/json"))

        post avatars_url, params: { avatar: invalid_attributes_profane_name_leet }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_user) {
        User.create!(username: 'new test', password: 'password')
      }

      let(:new_attributes) {
        {
          url: 'https://picsum.photos/200/200',
          name: Faker::Movies::HowToTrainYourDragon.character,
          user_id: new_user.id,
        }
      }

      it "updates the requested avatar" do
        avatar = Avatar.create! valid_attributes
        patch avatar_url(avatar),
          params: { avatar: new_attributes }, headers: valid_headers, as: :json
        avatar.reload
        expect(avatar.url).to eq(new_attributes[:url])
        expect(avatar.name).to eq(new_attributes[:name])
        expect(avatar.user_id).to eq(new_attributes[:user_id])
      end

      it "renders a JSON response with the avatar" do
        avatar = Avatar.create! valid_attributes
        patch avatar_url(avatar),
          params: { avatar: new_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end

    context "with invalid parameters" do
      it "renders a JSON response with errors for the avatar" do
        avatar = Avatar.create! valid_attributes

        patch avatar_url(avatar), params: { avatar: invalid_attributes_blank_name }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including("application/json"))

        patch avatar_url(avatar), params: { avatar: invalid_attributes_profane_name }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including("application/json"))

        patch avatar_url(avatar), params: { avatar: invalid_attributes_profane_name_leet }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested avatar" do
      avatar = Avatar.create! valid_attributes
      expect {
        delete avatar_url(avatar), headers: valid_headers, as: :json
      }.to change(Avatar, :count).by(-1)
    end
  end
end
