require 'rails_helper'
describe API::UsersController do

  let(:user) { create :user }
  let(:another_user) { create :user }
  let(:user_params) { { name: "new name", email: "new@email.com" } }

  before do
    sign_in user
  end

  describe 'update_profile' do
    context 'success' do
      it "updates a users profile" do
        post :update_profile, user: user_params, format: :json
        expect(response).to be_success
        expect(user.reload.email).to eq user_params[:email]
        json = JSON.parse(response.body)
        user_emails = json['users'].map { |v| v['email'] }
        expect(user_emails).to include user_params[:email]
      end

      it 'updates a users profile picture type' do
        user.update avatar_kind: 'gravatar'
        post :update_profile, user: { avatar_kind: 'initials' }
        expect(response).to be_success
        expect(user.reload.avatar_kind).to eq 'initials'
      end

      it 'updates a users profile picture when uploaded' do
        user.update avatar_kind: 'gravatar'
        post :update_profile, html: {multipart: true}, user: {
          avatar_kind: 'uploaded',
          uploaded_avatar_file_name: fixture_for('images', 'strongbad.png'),
          uploaded_avatar_content_type: 'image/png'
        }
        expect(response.status).to eq 200
        expect(user.reload.avatar_kind).to eq 'uploaded'
        expect(user.reload.uploaded_avatar).to be_present
      end

      it 'does not upload an invalid file' do
        user.update avatar_kind: 'gravatar'
        post :update_profile, user: {
          avatar_kind: 'uploaded',
          uploaded_avatar: fixture_for('images', 'strongmad.pdf'),
          uploaded_avatar_content_type: 'text/pdf'
        }
        expect(response.status).to_not eq 200
        expect(user.reload.avatar_kind).to eq 'gravatar'
        expect(user.reload.uploaded_avatar).to be_blank
      end
    end

    context 'failures' do
      it "responds with an error when there are unpermitted params" do
        user_params[:dontmindme] = 'wild wooly byte virus'
        put :update_profile, user: user_params, format: :json
        expect(JSON.parse(response.body)['exception']).to eq 'ActionController::UnpermittedParameters'
      end
    end
  end

  describe 'change_password' do
    context 'success' do
      it "changes a users password" do
        old_password = user.encrypted_password
        post :change_password, user: { current_password: 'complex_password', password: 'new_password', password_confirmation: 'new_password'}, format: :json
        expect(response).to be_success
        expect(user.reload.encrypted_password).not_to eq old_password
        json = JSON.parse(response.body)
        user_emails = json['users'].map { |v| v['email'] }
        expect(user_emails).to include user.email
      end
    end

    context 'failures' do
      it 'does not allow a change if current password does not match' do
        old_password = user.encrypted_password
        post :change_password, user: { current_password: 'not right', password: 'new_password', password_confirmation: 'new_password'}, format: :json
        expect(response).to_not be_success
        expect(user.reload.encrypted_password).to eq old_password
      end

      it 'does not allow a change if passord confirmation doesnt match' do
        old_password = user.encrypted_password
        post :change_password, user: { password: 'new_password', password_confirmation: 'errwhoops'}, format: :json
        expect(response).to_not be_success
        expect(user.reload.encrypted_password).to eq old_password
      end
    end
  end

  describe 'deactivate' do
    context 'success' do
      it "deactivates the users account" do
        post :deactivate, user: {deactivation_response: '' }, format: :json
        expect(response).to be_success
        json = JSON.parse(response.body)
        user_emails = json['users'].map { |v| v['email'] }
        expect(user_emails).to include user.email
        expect(user.reload.deactivated_at).to be_present
        expect(UserDeactivationResponse.last).to be_blank
      end

      it 'can record a deactivation response' do
        post :deactivate, user: { deactivation_response: '(╯°□°)╯︵ ┻━┻'}, format: :json
        deactivation_response = UserDeactivationResponse.last
        expect(deactivation_response.body).to eq '(╯°□°)╯︵ ┻━┻'
        expect(deactivation_response.user).to eq user
      end
    end
  end

end
