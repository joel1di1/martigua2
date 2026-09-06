# frozen_string_literal: true

module Scaleway
  # ActionMailer delivery method backed by the Scaleway Transactional Email HTTP API.
  # https://www.scaleway.com/en/developers/api/transactional-email/
  #
  # Registered as :scaleway in config/initializers/scaleway_transactional_email.rb, so a
  # mailer only needs `config.action_mailer.delivery_method = :scaleway`.
  class TransactionalEmailDelivery
    class DeliveryError < StandardError; end

    HOST = 'api.scaleway.com'
    API_PATH = '/transactional-email/v1alpha1/regions/%<region>s/emails'
    DEFAULT_REGION = 'fr-par'

    attr_reader :settings

    def initialize(settings = {})
      @settings = {
        project_id: ENV.fetch('SCW_PROJECT_ID', nil),
        secret_key: ENV.fetch('SCW_SECRET_KEY', nil),
        region: ENV.fetch('SCW_REGION', DEFAULT_REGION)
      }.merge(settings.symbolize_keys)
    end

    def deliver!(mail)
      check_credentials!
      response = post(payload_for(mail))
      return response if response.is_a?(Net::HTTPSuccess)

      raise DeliveryError, "Scaleway refused the mail (HTTP #{response.code}): #{response.body}"
    end

    private

    def check_credentials!
      return if settings[:project_id].present? && settings[:secret_key].present?

      raise DeliveryError, 'missing Scaleway credentials, set SCW_PROJECT_ID and SCW_SECRET_KEY'
    end

    def uri
      URI::HTTPS.build(host: HOST, path: format(API_PATH, region: settings[:region].presence || DEFAULT_REGION))
    end

    def post(payload)
      endpoint = uri
      request = Net::HTTP::Post.new(endpoint)
      request['X-Auth-Token'] = settings[:secret_key]
      request['Content-Type'] = 'application/json'
      request.body = payload.to_json

      Net::HTTP.start(endpoint.host, endpoint.port, use_ssl: true) { |http| http.request(request) }
    end

    def payload_for(mail)
      {
        project_id: settings[:project_id],
        from: sender(mail),
        to: recipients(mail.to),
        cc: recipients(mail.cc),
        bcc: recipients(mail.bcc),
        subject: mail.subject,
        text: body_of(mail, 'text/plain'),
        html: body_of(mail, 'text/html'),
        attachments: attachments(mail)
      }.compact_blank
    end

    def sender(mail)
      display_name = Array(mail[:from]&.display_names).compact.first

      { email: Array(mail.from).first, name: display_name }.compact
    end

    def recipients(addresses)
      Array(addresses).map { |address| { email: address } }
    end

    def body_of(mail, mime_type)
      return mail.body.decoded if !mail.multipart? && mail.mime_type == mime_type

      part = mime_type == 'text/html' ? mail.html_part : mail.text_part
      part&.body&.decoded
    end

    def attachments(mail)
      mail.attachments.map do |attachment|
        { name: attachment.filename,
          type: attachment.mime_type,
          content: Base64.strict_encode64(attachment.body.decoded) }
      end
    end
  end
end
