import { Application } from "@hotwired/stimulus"

import AutoSubmit from '@stimulus-components/auto-submit'
import Dropdown from '@stimulus-components/dropdown'

const application = Application.start()

application.register('auto-submit', AutoSubmit)
application.register('dropdown', Dropdown)

// Configure Stimulus development experience
application.debug = false
window.Stimulus = application

export { application }
