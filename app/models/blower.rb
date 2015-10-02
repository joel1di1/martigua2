class Blower

  def self.send_sms(phone_number, text)
    blower = RestClient::Resource.new(ENV['BLOWERIO_URL'])
    blower['/messages'].post(to: phone_number, message: text)
  end

end