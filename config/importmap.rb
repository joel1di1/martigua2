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
pin 'tom-select', to: 'https://ga.jspm.io/npm:tom-select@2.2.2/dist/js/tom-select.complete.js'
pin 'trix'
pin '@rails/actiontext', to: 'actiontext.js'
