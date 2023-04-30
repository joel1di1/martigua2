class AddGeneralChannelToSection < ActiveRecord::Migration[7.0]
  def change
    Section.all.each do |section|
      section.channels.create!(name: 'General', private: false)
    end
  end
end
