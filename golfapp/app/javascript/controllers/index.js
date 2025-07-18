// app/javascript/controllers/index.js
import { Application } from "@hotwired/stimulus"
// CHANGE THIS LINE: Use 'eagerLoadControllersFrom' as exported by your stimulus-loading.js
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"

const application = Application.start()
// CHANGE THIS LINE: Call 'eagerLoadControllersFrom' instead
eagerLoadControllersFrom("controllers", application)