# frozen_string_literal: true

describe 'Active Admin', :devise do
  let(:models) do
    [
      AdminUser,
      BlockedAddress,
      Calendar,
      Championship,
      Club,
      ClubAdminRole,
      Day,
      DutyTask,
      EnrolledTeamChampionship,
      Group,
      Location,
      Match,
      MatchAvailability,
      MatchSelection,
      Participation,
      Season,
      Section,
      SectionUserInvitation,
      Selection,
      Team,
      Training,
      TrainingInvitation,
      TrainingPresence,
      User
    ]
  end

  before do
    models.each do |model|
      puts "Creating #{model}"
      create(model.to_s.underscore.to_sym)
    end
  end

  it 'admin can list any page in admin section' do
    admin = create(:user)
    create(:admin_user, email: admin.email)

    signin admin.email, admin.password
    visit '/admin'

    expect(page).to have_content 'Users'

    models.each do |model_class|

      model_class = model_class.to_s.underscore
      model_plural = I18n.translate("activerecord.models.#{model_class}.other", default: model_class.humanize.pluralize)
      model_name = I18n.translate("activerecord.models.#{model_class}.one", default: model_class.humanize)

      click_on model_plural.titleize
      expect(page.all('#page-title', text: model_plural.titleize).size).to eq 1

      click_on "Création #{model_name.downcase}"
      expect(page.all('h1.main-content__page-title', text: "Création #{model_plural.titleize}").size).to eq(1), model_class
    end
  end
end
