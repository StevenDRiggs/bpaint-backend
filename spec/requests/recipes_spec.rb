require 'rails_helper'


RSpec.describe "/recipes", type: :request do
  # This should return the minimal set of attributes required to create a valid
  # Recipe. As you add validations to Recipe, be sure to
  # adjust the attributes here as well.
  let(:user) {
    User.create!(username: 'test', password: 'password')
  }

  let(:package) {
    Package.create!
  }

  let(:valid_attributes) {
    {
      user_id: user.id,
      package_id: package.id,
    }
  }

  let(:invalid_attributes) {
    {
      user_id: user.id + 1,
      package_id: package.id + 1,
    }
  }

  # This should return the minimal set of values that should be in the headers
  # in order to pass any filters (e.g. authentication) defined in
  # RecipesController, or in your router and rack
  # middleware. Be sure to keep this updated too.
  let(:valid_headers) {
    {}
  }

  describe "GET /index" do
    it "renders a successful response" do
      Recipe.create! valid_attributes
      get recipes_url, headers: valid_headers, as: :json
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      recipe = Recipe.create! valid_attributes
      get recipe_url(recipe), as: :json
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Recipe" do
        expect {
          post recipes_url,
               params: { recipe: valid_attributes }, headers: valid_headers, as: :json
        }.to change(Recipe, :count).by(1)
      end

      it "renders a JSON response with the new recipe" do
        post recipes_url,
             params: { recipe: valid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end

    context "with invalid parameters" do
      it "does not create a new Recipe" do
        expect {
          post recipes_url,
               params: { recipe: invalid_attributes }, as: :json
        }.to change(Recipe, :count).by(0)
      end

      it "renders a JSON response with errors for the new recipe" do
        post recipes_url,
             params: { recipe: invalid_attributes }, headers: valid_headers, as: :json
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

      let(:new_package) {
        Package.create!
      }

      let(:new_attributes) {
        {
          user_id: new_user.id,
          package_id: new_package.id,
        }
      }

      it "updates the requested recipe" do
        recipe = Recipe.create! valid_attributes
        patch recipe_url(recipe),
              params: { recipe: new_attributes }, headers: valid_headers, as: :json
        recipe.reload
        expect(recipe.user_id).to eq(new_attributes[:user_id])
        expect(recipe.package_id).to eq(new_attributes[:package_id])
      end

      it "renders a JSON response with the recipe" do
        recipe = Recipe.create! valid_attributes
        patch recipe_url(recipe),
              params: { recipe: new_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end

    context "with invalid parameters" do
      it "renders a JSON response with errors for the recipe" do
        recipe = Recipe.create! valid_attributes
        patch recipe_url(recipe),
              params: { recipe: invalid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested recipe" do
      recipe = Recipe.create! valid_attributes
      expect {
        delete recipe_url(recipe), headers: valid_headers, as: :json
      }.to change(Recipe, :count).by(-1)
    end
  end
end
