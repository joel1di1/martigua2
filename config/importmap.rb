# frozen_string_literal: true

# Pin npm packages by running ./bin/importmap

pin 'application', preload: true
pin '@hotwired/turbo-rails', to: 'turbo.min.js', preload: true
pin "@hotwired/stimulus", to: "@hotwired--stimulus.js" # @3.2.2
pin '@hotwired/stimulus-loading', to: 'stimulus-loading.js', preload: true
pin_all_from 'app/javascript/controllers', under: 'controllers'
pin "react" # @19.2.0
pin '@headlessui/react', to: 'https://ga.jspm.io/npm:@headlessui/react@1.7.2/dist/headlessui.esm.js'
pin 'process', to: 'https://ga.jspm.io/npm:@jspm/core@2.0.0-beta.26/nodelibs/browser/process-production.js'
pin "react-dom" # @19.2.0
pin "scheduler" # @0.27.0
pin '@heroicons/react/solid', to: 'https://ga.jspm.io/npm:@heroicons/react@2.0.11/solid/index.js'
pin 'el-transition', to: 'https://ga.jspm.io/npm:el-transition@0.0.7/index.js'
pin "tom-select" # @2.4.3
pin 'trix'
pin '@rails/actiontext', to: 'actiontext.js'
pin 'webpush', to: 'webpush.js'
pin '@stimulus-components/auto-submit', to: '@stimulus-components--auto-submit.js' # @6.0.0
pin '@stimulus-components/dropdown', to: '@stimulus-components--dropdown.js' # @3.0.0
pin "stimulus-use" # @0.52.3
pin '@stimulus-components/notification', to: '@stimulus-components--notification.js' # @3.0.0
pin "@orchidjs/sifter", to: "@orchidjs--sifter.js" # @1.1.0
pin "@orchidjs/unicode-variants", to: "@orchidjs--unicode-variants.js" # @1.1.2
