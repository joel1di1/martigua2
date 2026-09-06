# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Scaleway::TransactionalEmailDelivery do
  subject(:delivery) { Scaleway::TransactionalEmailDelivery.new(project_id: 'project-id', secret_key: 'secret-key') }

  let(:mail) do
    Mail.new(from: 'Martigua <admin@martigua.org>',
             to: 'joueur@example.com',
             cc: ['maman@example.com', 'papa@example.com'],
             subject: 'Entrainement mardi').tap do |mail|
      mail.text_part = Mail::Part.new(body: 'Entrainement mardi')
      mail.html_part = Mail::Part.new(content_type: 'text/html; charset=UTF-8', body: '<p>Entrainement mardi</p>')
    end
  end

  # Net::HTTP is stubbed the way the other services are in this suite, and both the
  # connection arguments and the request itself are recorded so they can be asserted on.
  let(:response) { instance_double(Net::HTTPOK, code: '200', body: '{}') }
  let(:http) { instance_double(Net::HTTP) }
  let(:connections) { [] }
  let(:sent_requests) { [] }
  let(:sent_request) { sent_requests.first }
  let(:payload) { JSON.parse(sent_request.body) }

  before do
    allow(response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(true)
    allow(http).to receive(:request) do |request|
      sent_requests << request
      response
    end
    allow(Net::HTTP).to receive(:start) do |host, port, options, &block|
      connections << [host, port, options]
      block.call(http)
    end
  end

  describe '#deliver!' do
    it 'posts to the transactional email endpoint of the configured region' do
      delivery.deliver!(mail)

      expect(connections).to eq [['api.scaleway.com', 443, { use_ssl: true }]]
      expect(sent_request.path).to eq '/transactional-email/v1alpha1/regions/fr-par/emails'
    end

    it 'authenticates with the secret key' do
      delivery.deliver!(mail)

      expect(sent_request['X-Auth-Token']).to eq 'secret-key'
      expect(sent_request['Content-Type']).to eq 'application/json'
    end

    it 'sends the project id, the sender and every recipient' do
      delivery.deliver!(mail)

      expect(payload['project_id']).to eq 'project-id'
      expect(payload['from']).to eq('email' => 'admin@martigua.org', 'name' => 'Martigua')
      expect(payload['to']).to eq [{ 'email' => 'joueur@example.com' }]
      expect(payload['cc']).to eq [{ 'email' => 'maman@example.com' }, { 'email' => 'papa@example.com' }]
    end

    it 'sends both the text and the html body' do
      delivery.deliver!(mail)

      expect(payload['subject']).to eq 'Entrainement mardi'
      expect(payload['text']).to eq 'Entrainement mardi'
      expect(payload['html']).to eq '<p>Entrainement mardi</p>'
    end

    context 'with a mail that is not multipart' do
      let(:mail) do
        Mail.new(from: 'admin@martigua.org',
                 to: 'joueur@example.com',
                 subject: 'Coucou',
                 content_type: 'text/html; charset=UTF-8',
                 body: '<p>Coucou</p>')
      end

      it 'sends the body as html and omits the empty fields' do
        delivery.deliver!(mail)

        expect(payload['html']).to eq '<p>Coucou</p>'
        expect(payload).not_to have_key 'text'
        expect(payload).not_to have_key 'cc'
        expect(payload).not_to have_key 'attachments'
      end
    end

    context 'with an attachment' do
      before { mail.attachments['planning.txt'] = 'samedi 14h' }

      it 'sends it base64 encoded' do
        delivery.deliver!(mail)

        expect(payload['attachments']).to eq [
          { 'name' => 'planning.txt', 'type' => 'text/plain', 'content' => Base64.strict_encode64('samedi 14h') }
        ]
      end
    end

    context 'when Scaleway refuses the mail' do
      let(:response) { instance_double(Net::HTTPUnprocessableEntity, code: '422', body: '{"message":"invalid sender"}') }

      before { allow(response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(false) }

      it 'raises with the status and the body' do
        expect { delivery.deliver!(mail) }
          .to raise_error(described_class::DeliveryError, /422.*invalid sender/)
      end
    end

    context 'when the credentials are missing' do
      subject(:delivery) { Scaleway::TransactionalEmailDelivery.new(project_id: nil, secret_key: nil) }

      it 'raises before hitting the API' do
        expect { delivery.deliver!(mail) }
          .to raise_error(described_class::DeliveryError, /SCW_PROJECT_ID/)
        expect(sent_requests).to be_empty
      end
    end
  end
end
