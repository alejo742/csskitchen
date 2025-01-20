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
        const value = cookInput.value.trim();
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
      const value = cookInput.value.trim();
      const isValid = /^[^\d\s]*$/.test(value);

      if (!isValid) {
          event.preventDefault();
      }
    });

    // conditionally render challenges
    const categories = document.querySelectorAll('.challenge-categories .category');
    const challengeCards = document.querySelectorAll('.challenge-card');

    const triggerCategory = (category) => {
        categories.forEach(cat => cat.classList.remove('active')); // remove active class
        category.classList.add('active');

        const selectedCategory = category.getAttribute('data-category');
        // show cards that match the selected category
        challengeCards.forEach(card => {
            if (card.getAttribute('data-category') === selectedCategory) {
                card.style.display = 'flex';
            } else {
                card.style.display = 'none';
            }
        });
    }
    triggerCategory(categories[0]); // show all challenges
    categories.forEach(category => {
        category.addEventListener('click', function() {
            triggerCategory(category);
        });
    });

    // navigate to challenge_view path on card click
    challengeCards.forEach(card => {
        card.addEventListener('click', function() {
            const challengePath = card.getAttribute('data-challenge-path');
            window.location.href = challengePath;
        });
    });
  }
}