import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    const navbarProfile = document.querySelector('.navbar-profile');
    const navbarProfileDropdown = document.querySelector('.profile-dropdown');

    navbarProfile.addEventListener('click', () => {
        navbarProfileDropdown.classList.toggle('visible');
    });
  }
}