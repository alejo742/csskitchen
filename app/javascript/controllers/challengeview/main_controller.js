import { Controller } from "@hotwired/stimulus";
import * as monaco from 'monaco-editor';

/*
* This code is used to show a dynamic modal
* @param {string} title - The title of the modal
* @param {function} callback - The function to be attached to the positive button
*/
export function showModal(title, callback) {
	// cleanup previous listeners
	const positiveButton = document.querySelector('.popup-button.positive');
	positiveButton.removeEventListener('click', callback);
	const overlay = document.querySelector('.challenge-overlay');
	const modalTitle = document.querySelector('.challenge-popup h2');
	modalTitle.innerHTML = title;
	overlay.classList.add('visible');

	// add new listener
	positiveButton.addEventListener('click', callback);
}
/*
* This code is used to hide the modal
*/
export function hideModal() {
	const overlay = document.querySelector('.challenge-overlay');
	overlay.classList.remove('visible');
}

export default class extends Controller {
  connect() {
	/*
	* This code is used to finish the challenge
	*/
	const endButton = document.querySelector('.challenge-end-button');
	endButton.addEventListener('click', () => {
		showModal('Are you sure you want to end the challenge?', () => {
			// make request to /dashboard route
			window.location.href = '/dashboard';
		});
	});

	// hide modal when pressing the negative button
	const negativeButton = document.querySelector('.popup-button.negative');
	negativeButton.addEventListener('click', hideModal);
  }
}