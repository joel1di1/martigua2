# frozen_string_literal: true

# Pin npm packages by running ./bin/importmap

pin 'application', preload: true
pin '@hotwired/turbo-rails', to: 'turbo.min.js', preload: true
pin '@hotwired/stimulus', to: 'stimulus.min.js', preload: true
pin '@hotwired/stimulus-loading', to: 'stimulus-loading.js', preload: true
pin_all_from 'app/javascript/controllers', under: 'controllers'
pin 'react', to: 'https://ga.jspm.io/npm:react@18.2.0/index.js'
pin '@headlessui/react', to: 'https://ga.jspm.io/npm:@headlessui/react@1.7.2/dist/headlessui.esm.js'
pin 'process', to: 'https://ga.jspm.io/npm:@jspm/core@2.0.0-beta.26/nodelibs/browser/process-production.js'
pin 'react-dom', to: 'https://ga.jspm.io/npm:react-dom@18.2.0/index.js'
pin 'scheduler', to: 'https://ga.jspm.io/npm:scheduler@0.23.0/index.js'
pin '@heroicons/react/solid', to: 'https://ga.jspm.io/npm:@heroicons/react@2.0.11/solid/index.js'
pin 'el-transition', to: 'https://ga.jspm.io/npm:el-transition@0.0.7/index.js'
pin 'trix'
pin '@rails/actiontext', to: 'actiontext.js'
pin 'webpush', to: 'webpush.js'
pin '@stimulus-components/auto-submit', to: '@stimulus-components--auto-submit.js' # @6.0.0
pin '@stimulus-components/dropdown', to: '@stimulus-components--dropdown.js' # @3.0.0
pin 'stimulus-use' # @0.52.2
pin '@stimulus-components/notification', to: '@stimulus-components--notification.js' # @3.0.0
pin 'tom-select' # @2.4.3
pin '@orchidjs/sifter', to: '@orchidjs--sifter.js' # @1.1.0
pin '@orchidjs/unicode-variants', to: '@orchidjs--unicode-variants.js' # @1.1.2
