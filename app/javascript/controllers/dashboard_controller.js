import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // navbar functionality
    const navbarProfile = document.querySelector('.navbar-profile');
    const navbarProfileDropdown = document.querySelector('.profile-dropdown');

    navbarProfile.addEventListener('click', () => {
        navbarProfileDropdown.classList.toggle('visible');
    });

    // input client side validation
    const cookInput = document.querySelector('.cook-search-input');
    const validationMessage = document.querySelector('.cook-input-error');

    cookInput.addEventListener('input', () => {
        const value = cookInput.value;
        const isValid = /^[^\d\s]*$/.test(value);

        if (!isValid) {
            validationMessage.classList.add('visible');
            cookInput.classList.add('invalid');
        } else {
            validationMessage.classList.remove('visible');
            cookInput.classList.remove('invalid');
        }
    });

    // check before form submission too
    const cookForm = document.querySelector('.cook-ui');
    cookForm.addEventListener('submit', (event) => {
      const value = cookInput.value;
      const isValid = /^[^\d\s]*$/.test(value);

      if (!isValid) {
          event.preventDefault();
      }
    });

  }
}