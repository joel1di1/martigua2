# frozen_string_literal: true

require 'faraday'

class Doctolib
  def check_availability
    doc_to_check = [
      { visit_motive_ids: 7_609_339, agenda_ids: 37_298, practice_ids: 385_902, name: 'Dr. Olivier Mesland' },
      { visit_motive_ids: 507_096, agenda_ids: 84_194, practice_ids: 131_653, name: 'Dr. Loic Chimot' },
      { visit_motive_ids: 2_901_110, agenda_ids: 111_316, practice_ids: 192_130, name: 'Dr. Brice Bellemans' },
      { visit_motive_ids: 1_727_740, agenda_ids: '223553-223556-223559-226725', practice_ids: 89_279, name: 'AIM Atlantique Imagerie Médicale' }
    ]

    first_availabilities = doc_to_check.map do |doc|
      [doc[:name], check_availability_for_doc(doc)]
    end

    # Sort by date
    first_availabilities.sort_by! { |doc| doc[1] }

    # puts the first available slot
    Rails.logger.debug first_availabilities.first

    return unless first_availabilities.first[1] < Time.zone.today + 70

    send_notification(first_availabilities.first[1], first_availabilities.first[0])
  end

  def check_availability_for_doc(doc)
    current_date = Time.zone.now.strftime('%Y-%m-%d')
    response = Faraday.get("https://www.doctolib.fr/availabilities.json?visit_motive_ids=#{doc[:visit_motive_ids]}&agenda_ids=#{doc[:agenda_ids]}&practice_ids=#{doc[:practice_ids]}&telehealth=false&start_date=#{current_date}&limit=2") do |req|
      req.headers['accept'] = 'application/json'
      req.headers['accept-language'] = 'en;q=0.5'
      req.headers['content-type'] = 'application/json; charset=utf-8'
      req.headers['cookie'] =
        'ssid=c127000mac-36V-Vg6FuDfD; locale=fr; esid=NLpH7uOyxhjePjdXSZS6yyf1; _doctolib_session=PXlwgix7W3lvzs9IWO8vImXLlV5VMYaYk8boHhowgaO%2B2A2I8TG5QBR1ZHnxAx8WvIbbWjQIrroG%2BcPvJdzAtwPChM540VpSf4%2FAfH61Hj5cGF5Sx0u1vRl9N5I2OMfAkZUGkUsLMg9b8fK5vO8NfnZeaQkFVERGo%2FX9UeCt8c%2Fliq5kQV73u05qRZIn7adBWraiVqx%2Bo0mUlwxp4CiU8I6J%2FuC3SGIZGL9P1amH0HIU84YaeMSWMcJcQRev71Qfid99kGczgxHXZGAHjA6eEkTZRclJ9Kn7EkGVyImA%2F3MKJxtK7JGF6RybY30KUoWsmit20V2oYadsmj3cOrKAyDKXmEy%2Fb7ecTV2YhTht8VBTqZ1XiZ3wkwjoqRiqcRU%3D--Vxi77Mjm%2BcUlUWn0--yPeSGMhGxaDyqbY0klzdkQ%3D%3D; __cf_bm=bJAmc0ZVipZKJ7xQLN7hn6bh14FXaMhMblZ_ukZJV3Y-1725729726-1.0.1.1-tsdYKgda9Ze2Z3wa5IyCuNHa3dVbTHQIAAkyw3EDFk6gOCVc6ayEmm4.tPpIHL9cN45frwUtBq1j6nGRrr9z2rHAJ6xOlQhPr5PAhQZ7CUM; _cfuvid=V_4WF_tu9FCPhTEUT2pXmhmNc.1tucsIJDEr4oF2gkI-1725729726643-0.0.1.1-604800000' # rubocop:disable Layout/LineLength
      req.headers['dnt'] = '1'
      req.headers['priority'] = 'u=1, i'
      req.headers['referer'] = 'https://www.doctolib.fr/medecin-du-sport/nantes/loic-chimot/booking/availabilities?specialityId=232&telehealth=false&placeId=practice-131653&motiveCategoryIds%5B%5D=29166&motiveIds%5B%5D=507096&bookingFunnelSource=profile'
      req.headers['sec-fetch-dest'] = 'empty'
      req.headers['sec-fetch-mode'] = 'cors'
      req.headers['sec-fetch-site'] = 'same-origin'
      req.headers['sec-gpc'] = '1'
      req.headers['user-agent'] = 'Mozilla/5.0 (iPhone; CPU iPhone OS 16_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.6 Mobile/15E148 Safari/604.1'
      req.headers['x-csrf-token'] = '7OnD59Ep9DQyA1I0BHM1fZNYn03LNqDIWTDz0Lh_72I-xUctcDi-YpgEvIr556yjc0xJz0L8eIQOC99mbVAsUg'
    end

    json_response = Oj.load(response.body)

    Rails.logger.debug { "#{doc[:name]}: next_slot: #{json_response['next_slot']}" }

    new_slot_date = json_response['next_slot'].split('T').first
    Date.parse(new_slot_date)
  end

  def send_notification(next_slot, name)
    Rails.logger.debug { "Slot found at #{next_slot} for #{name}" }
    WebpushService.send_notification_to_all_user_subscriptions(User.find(1),
                                                               title: "Echo dispo #{next_slot}, #{name}",
                                                               body: "Echo dispo #{next_slot}, #{name}")
  end
end
