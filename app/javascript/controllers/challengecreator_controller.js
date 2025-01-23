import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    connect() {
        const body = document.querySelector('body');
        const redirectPath = body.getAttribute('data-redirect-path');
        setTimeout(function() {
            window.location.href = redirectPath;
        }, 100); // Adjust the delay as needed
    }
}