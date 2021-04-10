require 'rails_helper'


RSpec.describe "/colors", type: :request do
  # This should return the minimal set of attributes required to create a valid
  # Color. As you add validations to Color, be sure to
  # adjust the attributes here as well.
  let(:user) {
    User.create!(username: 'test', password: 'password')
  }

  let(:valid_attributes) {
    {
      url: 'https://picsum.photos/300/200',
      medium: 'oil paint',
      name: Faker::Color.color_name,
      user_id: user.id,
    }
  }

  let(:invalid_attributes) {
    {
      url: 'notaurl',
      medium: ['', 'bitch', 'b1tch'].sample,
      name: ['', 'bitch', 'b1tch'].sample,
      user_id: user.id + 1,
    }
  }

  # This should return the minimal set of values that should be in the headers
  # in order to pass any filters (e.g. authentication) defined in
  # ColorsController, or in your router and rack
  # middleware. Be sure to keep this updated too.
  let(:valid_headers) {
    {}
  }

  describe "GET /index" do
    it "renders a successful response" do
      Color.create! valid_attributes
      get colors_url, headers: valid_headers, as: :json
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      color = Color.create! valid_attributes
      get color_url(color), as: :json
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Color" do
        expect {
          post colors_url, params: { color: valid_attributes }, headers: valid_headers, as: :json
        }.to change(Color, :count).by(1)
      end

      it "renders a JSON response with the new color" do
        post colors_url, params: { color: valid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end

    context "with invalid parameters" do
      it "does not create a new Color" do
        expect {
          post colors_url, params: { color: invalid_attributes }, as: :json
        }.to change(Color, :count).by(0)
      end

      it "renders a JSON response with errors for the new color" do
        post colors_url, params: { color: invalid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including("application/json"))
        expect(eval(response.body)[:user]).to include('must exist')
        expect(eval(response.body)[:url]).to include('is not a valid url')
        expect(eval(response.body)[:medium]).to include('cannot include profanity').or include("can't be blank").or include('must be at least 2 characters long')
        expect(eval(response.body)[:name]).to include('cannot include profanity').or include("can't be blank").or include('must be at least 2 characters long')
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
          url: 'https://picsum.photos/200/300',
          medium: 'acrylic paint',
          name: Faker::Color.color_name,
          user_id: new_user.id,
        }
      }

      it "updates the requested color" do
        color = Color.create! valid_attributes
        patch color_url(color), params: { color: new_attributes }, headers: valid_headers, as: :json
        color.reload
        expect(color.url).to eq(new_attributes[:url])
        expect(color.medium).to eq(new_attributes[:medium])
        expect(color.name).to eq(new_attributes[:name])
        expect(color.user_id).to eq(new_attributes[:user_id])
      end

      it "renders a JSON response with the color" do
        color = Color.create! valid_attributes
        patch color_url(color),
              params: { color: new_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end

    context "with invalid parameters" do
      it "renders a JSON response with errors for the color" do
        color = Color.create! valid_attributes
        patch color_url(color),
              params: { color: invalid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including("application/json"))
        expect(eval(response.body)[:user]).to include('must exist')
        expect(eval(response.body)[:url]).to include('is not a valid url')
        expect(eval(response.body)[:medium]).to include('cannot include profanity').or include("can't be blank").or include('must be at least 2 characters long')
        expect(eval(response.body)[:name]).to include('cannot include profanity').or include("can't be blank").or include('must be at least 2 characters long')
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested color" do
      color = Color.create! valid_attributes
      expect {
        delete color_url(color), headers: valid_headers, as: :json
      }.to change(Color, :count).by(-1)
    end
  end
end
