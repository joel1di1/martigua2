import { Application } from "@hotwired/stimulus"

import AutoSubmit from '@stimulus-components/auto-submit'
import Dropdown from '@stimulus-components/dropdown'
import Notification from '@stimulus-components/notification'

const application = Application.start()

application.register('auto-submit', AutoSubmit)
application.register('dropdown', Dropdown)
application.register('notification', Notification)

// Configure Stimulus development experience
application.debug = false
window.Stimulus = application

export { application }
