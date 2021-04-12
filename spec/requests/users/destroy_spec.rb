require 'rails_helper'


RSpec.describe 'DELETE /users/:id' do
  context 'with admin logged in' do
    before(:context) do
      @admin_user = User.create!(username: 'admin', email: 'admin@admin.com', password: 'pass', is_admin: true)
      @other_user = User.create!(username: 'other', email: 'other@email.com', password: 'pass')

      post '/login', params: {
        user: {
          usernameOrEmail: 'admin',
          password: 'pass',
        },
      }

      @valid_headers = {
        'Authentication': eval(response.body)[:token],
      }
    end

    after(:context) do
      @admin_user.destroy
      @other_user.destroy
      remove_instance_variable(:@valid_headers)
    end

    context 'on admin profile' do
      context 'when not flagged for deletion' do
        before(:example) do
          @admin_user.reload
        end

        it 'is successful' do
          delete user_path(@admin_user), headers: @valid_headers

          expect(response).to have_http_status(:ok)
        end

        it 'flags account for deletion' do
          delete user_path(@admin_user), headers: @valid_headers

          flagged_user = User.find(@admin_user.id)

          expect(flagged_user.flags).to include('DELETE_USER' => true)
        end

        it 'does not delete account' do
          delete user_path(@admin_user), headers: @valid_headers

          expect {
            User.find(@admin_user.id)
          }.to_not raise_exception
        end

        it 'renders json for user' do
          delete user_path(@admin_user), headers: @valid_headers

          expect(eval(response.body)).to include(:user)
          expect(eval(response.body)[:user]).to include(:flags)
          expect(eval(response.body)[:user][:flags]).to include(DELETE_USER: true)
        end
      end

      context 'when flagged for deletion' do
        before(:example) do
          @admin_user.reload
          @admin_user.update!(flags: {DELETE_USER: true})
        end

        it 'is successful' do
          delete user_path(@admin_user), headers: @valid_headers

          expect(response).to have_http_status(:ok)
        end

        it 'deletes account' do
          delete user_path(@admin_user), headers: @valid_headers

          expect {
            User.find(@admin_user.id)
          }.to raise_exception(ActiveRecord::RecordNotFound)
        end

        it 'renders json success message' do
          delete user_path(@admin_user), headers: @valid_headers

          expect(eval(response.body)).to include(:user)
          expect(eval(response.body)[:user]).to eq("DELETED #{@admin_user.username}")
        end
      end
    end

    context "on non-admin profile" do
      before(:example) do
        @other_user.reload
      end

      it 'is successful' do
        delete user_path(@other_user), headers: @valid_headers

        expect(response).to have_http_status(:ok)
      end

      it 'deletes account' do
        delete user_path(@other_user), headers: @valid_headers

        expect {
          User.find(@other_user.id)
        }.to raise_exception(ActiveRecord::RecordNotFound)
      end

      it 'renders json success message' do
        delete user_path(@other_user), headers: @valid_headers

        expect(eval(response.body)).to include(:user)
        expect(eval(response.body)[:user]).to eq("DELETED #{@other_user.username}")
      end
    end
  end

  context 'with non-admin logged in' do
    before(:context) do
      @non_admin_user = User.create!(username: 'non-admin', email: 'non@admin.com', password: 'pass')
      @other_user = User.create!(username: 'other', email: 'other@user.com', password: 'pass')

      post '/login', params: {
        user: {
          usernameOrEmail: 'non-admin',
          password: 'pass',
        },
      }

      @valid_headers = {
        'Authentication': eval(response.body)[:token]
      }
    end

    after(:context) do
      @non_admin_user.destroy
      @other_user.destroy
      remove_instance_variable(:@valid_headers)
    end

    context 'on own profile' do
      before(:example) do
        @non_admin_user.reload
      end

      it 'is successful' do
        delete user_path(@non_admin_user), headers: @valid_headers

        expect(response).to have_http_status(:ok)
      end

      it 'flags account for deletion' do
        delete user_path(@non_admin_user), headers: @valid_headers

        flagged_user = User.find(@non_admin_user.id)

        expect(flagged_user.flags).to include('DELETE_USER' => true)
      end

      it 'does not delete account' do
        delete user_path(@non_admin_user), headers: @valid_headers

        expect {
          User.find(@non_admin_user.id)
        }.to_not raise_exception
      end

      it 'renders json request message' do
        delete user_path(@non_admin_user), headers: @valid_headers

        expect(eval(response.body)).to include(:user)
        expect(eval(response.body)[:user]).to include(:flags)
        expect(eval(response.body)[:user][:flags]).to include(DELETE_USER: true)
      end
    end

    context "on other's profile" do
      before(:example) do
        @other_user.reload
      end

      it 'is forbidden' do
        delete user_path(@other_user), headers: @valid_headers

        expect(response).to have_http_status(:forbidden)
      end

      it 'does not flag account for deletion' do
        delete user_path(@other_user), headers: @valid_headers

        flagged_user = User.find(@other_user.id)

        expect(flagged_user.flags).to eq(@other_user.flags)
      end

      it 'does not delete account' do
        delete user_path(@other_user), headers: @valid_headers

        expect {
          User.find(@other_user.id)
        }.to_not raise_exception
      end

      it 'renders json errors' do
        delete user_path(@other_user), headers: @valid_headers

        expect(eval(response.body)).to include(:errors)
        expect(eval(response.body)[:errors]).to include('Must be logged in as admin to delete other profiles')
      end
    end
  end

  context 'when not logged in' do
    let(:test_user) {
      User.create!(username: 'test', email: 'test@user.com', password: 'pass')
    }

    it 'is forbidden' do
      delete user_path(test_user)

      expect(response).to have_http_status(:forbidden)
    end

    it 'does not flag account for deletion' do
      delete user_path(test_user)

      flagged_user = User.find(test_user.id)

      expect(flagged_user.flags).to eq(test_user.flags)
    end

    it 'does not delete account' do
      delete user_path(test_user)

      expect {
        User.find(test_user.id)
      }.to_not raise_exception
    end

    it 'renders json errors' do
      delete user_path(test_user)

      expect(eval(response.body)).to include(:errors)
      expect(eval(response.body)[:errors]).to include('Must be logged in as admin to delete other profiles')
    end
  end
end
