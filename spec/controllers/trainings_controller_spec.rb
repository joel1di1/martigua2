require "rails_helper"

describe TrainingsController, :type => :controller do
  let(:request_params) { {} }
  let(:section) { create :section }
  let(:user) { create :user, with_section: section }

  describe "GET index" do
    let(:request) { get :index, params: request_params }

    context 'within section' do
      let(:request_params) { { section_id: section.to_param } }

      context 'signed as user' do
        render_views
        let(:user) { create :user, with_section: section }

        let!(:training_1) { create :training, with_section: section }
        let!(:training_2) { create :training, with_section: section, location: nil }
        let!(:training_not_in_section) { create :training }

        before { sign_in user }
        before { request }

        it { expect(assigns[:trainings]).to match_array([training_1, training_2 ]) }
      end
    end
  end

  describe "GET edit" do
    let(:request) { get :edit, params: request_params }

    context 'with existing training' do
      let(:training) { create :training, with_section: section }
      let(:request_params) { { section_id: section.to_param, id: training.id } }

      before { sign_in user }
      before { request }

      it { expect(response).to have_http_status(:success) }
    end
  end

  describe "PATCH edit" do
    context 'with existing training' do
      subject { patch :update, params: request_params }

      let(:training) { create :training, with_section: section }
      let(:request_params) { { section_id: section.to_param, id: training.to_param, training: training.attributes } }

      before { sign_in user }

      it { expect(subject).to redirect_to(section_training_path(section_id: section.to_param, id: training.to_param))}
    end
  end

  describe "POST create" do
    let(:new_training) { build :training }

    context 'signed as user' do
      let(:training_params) { { training: new_training.attributes.slice('start_datetime', 'end_datetime') } }
      let(:request_params) { training_params.merge(section_id: section.id) }

      before { sign_in user }

      describe 'effects' do
        let(:request) { post :create, params: request_params }
        it { expect{request}.to change{section.trainings.count}.by(1) }
      end

      describe 'response' do
        subject { post :create, params: request_params }

        it { expect(subject).to redirect_to(section_trainings_path(section_id: section.to_param))}
      end
    end
  end

  describe "POST invitations" do
    subject { post :invitations, params: { section_id: section.to_param, id: training.to_param } }

    let(:section) {create :section }
    let(:coach) { create :user, with_section_as_coach: section }
    let(:training) { create :training, with_section: section}

    before { sign_in coach }

    it { expect(subject).to redirect_to(section_trainings_path(section_id: section.to_param))}
  end

  describe "POST cancellation" do
    subject { post :cancellation, params: { section_id: section.to_param, id: training.to_param, cancellation: { reason: "TEST" } } }

    let(:section) {create :section }
    let(:coach) { create :user, with_section_as_coach: section }
    let(:training) { create :training, with_section: section}

    before { sign_in coach }

    it { expect(subject).to redirect_to(section_training_path(section_id: section.to_param, id: training.to_param))}
    it { expect(subject && training.reload.cancelled?).to be_truthy }
  end

  describe "DELETE cancellation" do
    subject { delete :uncancel, params: { section_id: section.to_param, id: training.to_param } }

    let(:section) {create :section }
    let(:coach) { create :user, with_section_as_coach: section }
    let(:training) { create :training, with_section: section}

    before { training.cancel!('for some reason') }
    before { sign_in coach }

    it { expect(subject && training.reload.cancelled?).to be_falsy }
    it { expect(subject).to redirect_to(section_training_path(section_id: section.to_param, id: training.to_param))}
  end
end