// app/javascript/controllers/collapsible_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "toggleIcon"] // 'content' is the collapsible div, 'toggleIcon' is an optional arrow/chevron
  static classes = ["hidden"] // Use Tailwind's 'hidden' class for the collapsed state

  connect() {
    // Initialize the icon's state based on the content's initial visibility.
    // Assuming the 'content' div starts with the 'hidden' class in the HTML.
    if (this.contentTarget.classList.contains(this.hiddenClass)) {
      // If content is hidden, ensure icon reflects the 'collapsed' state (e.g., pointing right)
      this.toggleIconTarget.classList.add('rotate-90');
    } else {
      // If content is visible, ensure icon reflects the 'expanded' state (e.g., pointing down)
      this.toggleIconTarget.classList.remove('rotate-90');
    }
  }

  toggle(event) {
    event.preventDefault(); // Prevent default link/button behavior if applicable
    this.contentTarget.classList.toggle(this.hiddenClass); // Toggle the 'hidden' class to show/hide content

    // Toggle a rotation class on the icon to visually indicate state change
    this.toggleIconTarget.classList.toggle('rotate-90');
  }
}