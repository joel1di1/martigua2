# frozen_string_literal: true

Webpush.configure do |config|
  config.vapid_public_key = 'BBtpkvtjmaZxC4RRU12CFlM6I47ZLQ2K0BsF0kT5m91yuvXESnBc3O6JogVUg79k96P9s6Yi4qILZhjgEiB43uc=' # Votre clé publique VAPID
  config.vapid_private_key = 'QGIjem4AcAYewLFV4q7i9_Z0sApYqXhbb4BqxQD_xdg=' # Votre clé privée VAPID
  config.vapid_subject = 'mailto:your-email@example.com' # L'adresse e-mail de l'expéditeur
end
