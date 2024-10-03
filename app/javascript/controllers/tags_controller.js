import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

export default class extends Controller {
  static targets = ["input", "tagsContainer"]

  connect() {
    this.tags = this.hiddenField.value ? this.hiddenField.value.split(", ") : [];
    this.renderTags();
    this.focusInput();
  }

  focusInput() {
    setTimeout(() => this.inputTarget.focus(), 100);
  }

  addIngredient(event) {
    if (event.key === 'Enter') {
      event.preventDefault();
      const newIngredient = this.inputTarget.value.trim();

      if (newIngredient && !this.tags.includes(newIngredient)) {
        this.tags.push(newIngredient);
        this.inputTarget.value = "";
        this.renderTags();
        this.updateHiddenField();
        // this.triggerSearch();
      }
    }

    if (event.key === 'Backspace' && this.inputTarget.value === "") {
      this.removeLastIngredient();
    }
  }

  removeIngredient(event) {
    const ingredient = event.target.closest('.badge').dataset.ingredient;
    this.tags = this.tags.filter(tag => tag !== ingredient);
    this.renderTags();
    this.updateHiddenField();
    // this.triggerSearch();
  }

  removeLastIngredient() {
    if (this.tags.length > 0) {
      this.tags.pop(); 
      this.renderTags();
      this.updateHiddenField();
      // this.triggerSearch();
    }
  }

  renderTags() {
    this.tagsContainerTarget.innerHTML = this.tags.map(tag => `
      <span class="badge bg-primary me-1 mb-1" data-ingredient="${tag}">
        ${tag} 
        <span data-action="click->tags#removeIngredient" class="ms-1">&times;</span>
      </span>
    `).join("");
  }

  updateHiddenField() {
    this.hiddenField.value = this.tags.join(", ");
  }

  triggerSearch() {
    clearTimeout(this.searchTimeout);
    this.searchTimeout = setTimeout(() => {
      const url = new URL(this.element.action, window.location.origin);
      const searchParams = new URLSearchParams(new FormData(this.element));
      url.search = searchParams.toString();

      fetch(url, {
        headers: {
          "Accept": "text/vnd.turbo-stream.html",
          "Turbo-Frame": "search_results"
        }
      })
      .then(response => response.text())
      .then(html => {
        Turbo.renderStreamMessage(html);
        this.focusInput();
      });
    }, 300);
  }

  get hiddenField() {
    return document.getElementById('ingredients-hidden-field');
  }
}
