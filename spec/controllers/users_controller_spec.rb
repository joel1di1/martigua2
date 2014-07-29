require "rails_helper"

describe UsersController, :type => :controller do

  let(:section) { create :section }
  let(:user) { create :user, with_section: section }

  describe "GET index" do
    let(:request_params) { {} }
    let(:request) { get :index, request_params }

    context 'within section' do
      let(:request_params) { { section_id: section.to_param } }

      context 'with on user' do
        before { sign_in user and request }

        it { expect(assigns[:users]).to match_array([user]) }
      end

      context 'with one user with several roles' do
        let(:user) do 
          user = create :user, with_section_as_coach: section
          section.add_player! user
          user
        end
        
        before { sign_in user and request }

        it { expect(assigns[:users]).to match_array([user]) }
      end
    end
  end

  describe "GET edit" do
    it 'assign @user' do
      sign_in user
      get :edit, id: user.to_param, section_id: section.to_param

      expect(response).to have_http_status(:success)
      expect(response).to render_template(:edit) 
      expect(assigns(:user)).to eq(user)
    end
  end

  describe "PATCH edit" do

    let(:new_attributes) { attributes_for(:user).except(:password) }

    context 'within section' do
      let!(:old_password) { user.password }
      before do
        sign_in user
        patch :update, id: user.to_param, section_id: section.to_param, user: new_attributes
        user.reload
      end
      it 'should update user' do
        expect(user.first_name).to eq new_attributes[:first_name]
        expect(user.last_name).to eq new_attributes[:last_name]
        expect(user.nickname).to eq new_attributes[:nickname]
        expect(user.phone_number).to eq new_attributes[:phone_number]
        expect(user.email).to eq new_attributes[:email]
        expect(user.valid_password?(old_password)).to eq true
      end

      it 'should redirect_to section user path' do
        expect(response).to redirect_to(section_user_path(user, section_id: section.to_param))
      end
    end

    context 'within no section' do
      let!(:old_password) { user.password }
      before do
        sign_in user
        patch :update, id: user.to_param, user: new_attributes
      end

      it 'should redirect_to user path' do
        expect(response).to redirect_to(user_path(user))
      end
    end

  end

end