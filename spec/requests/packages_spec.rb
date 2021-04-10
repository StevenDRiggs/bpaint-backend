require 'rails_helper'


RSpec.describe "/packages", type: :request do
  # This should return the minimal set of attributes required to create a valid
  # Package. As you add validations to Package, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
  }

  let(:invalid_attributes) {
    skip("Add a hash of attributes invalid for your model")
  }

  # This should return the minimal set of values that should be in the headers
  # in order to pass any filters (e.g. authentication) defined in
  # PackagesController, or in your router and rack
  # middleware. Be sure to keep this updated too.
  let(:valid_headers) {
    {}
  }

  describe "GET /index" do
    it "renders a successful response" do
      Package.create! valid_attributes
      get packages_url, headers: valid_headers, as: :json
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      package = Package.create! valid_attributes
      get package_url(package), as: :json
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Package" do
        expect {
          post packages_url,
               params: { package: valid_attributes }, headers: valid_headers, as: :json
        }.to change(Package, :count).by(1)
      end

      it "renders a JSON response with the new package" do
        post packages_url,
             params: { package: valid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end

    xcontext "with invalid parameters" do
      it "does not create a new Package" do
        expect {
          post packages_url,
               params: { package: invalid_attributes }, as: :json
        }.to change(Package, :count).by(0)
      end

      it "renders a JSON response with errors for the new package" do
        post packages_url,
             params: { package: invalid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq("application/json")
      end
    end
  end

  xdescribe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) {
        skip("Add a hash of attributes valid for your model")
      }

      it "updates the requested package" do
        package = Package.create! valid_attributes
        patch package_url(package),
              params: { package: new_attributes }, headers: valid_headers, as: :json
        package.reload
        skip("Add assertions for updated state")
      end

      it "renders a JSON response with the package" do
        package = Package.create! valid_attributes
        patch package_url(package),
              params: { package: new_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end

    context "with invalid parameters" do
      it "renders a JSON response with errors for the package" do
        package = Package.create! valid_attributes
        patch package_url(package),
              params: { package: invalid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq("application/json")
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested package" do
      package = Package.create! valid_attributes
      expect {
        delete package_url(package), headers: valid_headers, as: :json
      }.to change(Package, :count).by(-1)
    end
  end
end
