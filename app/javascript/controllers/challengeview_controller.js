import { Controller } from "@hotwired/stimulus";
import * as monaco from 'monaco-editor';

export default class extends Controller {
  connect() {
    const orderTabs = document.querySelectorAll('.order-tab');
    orderTabs.forEach(tab => {
		tab.addEventListener('click', () => {
			orderTabs.forEach(tab => tab.classList.remove('active'));
			tab.classList.add('active');
			toggleOrders(tab.innerHTML.toLowerCase());
		});
    });
    /*
	* This code is used to toggle between the tabs in the order
	* @param {string} status - The status of the order (urgent, completed)
	*/
    const orders = document.querySelectorAll('.order');
    const toggleOrders = (status) => {
		orders.forEach(order => {
			if (order.classList.contains(status)) {
				order.style.display = 'flex';
			} else {
				order.style.display = 'none';
			}
		});
    }
    toggleOrders('urgent');

	// when pressing the challenge-end-button, show the modal
	const endButton = document.querySelector('.challenge-end-button');
	endButton.addEventListener('click', () => {
		showModal('Are you sure you want to end the challenge?', () => {
			// make request to /dashboard route
			window.location.href = '/dashboard';
		});
	});


	// setup code editors
	const generalEditorSettings = {
		theme: 'vs-dark', 
		automaticLayout: true,
		lineNumbers: "on",
		roundedSelection: false,
		scrollBeyondLastLine: true,
		readOnly: false,
		minimap: {
			enabled: false
		},
		fontSize: 14,
		lineNumbersMinChars: 3,

		acceptSuggestionOnEnter: 'on',
		acceptSuggestionOnCommitCharacter: true,
		wordBasedSuggestions: true,
		quickSuggestions: true,
  	}

	let htmlEditor = monaco.editor.create(document.querySelector('.challenge-editor.html'), {
		...generalEditorSettings,
		value: '<!-- Type your code here -->',
		language: 'html',
	});

	let cssEditor = monaco.editor.create(document.querySelector('.challenge-editor.css'), {
		...generalEditorSettings,
		value: '/* Type your code here */',
		language: 'css',
	});

	/*
	* This code is used to toggle between the tabs in the editor
	*/
	const editorTabs = document.querySelectorAll('.editor-tab');
	editorTabs.forEach(tab => {
		tab.addEventListener('click', () => {
			// visual active tab
			editorTabs.forEach(tab => tab.classList.remove('active'));
			tab.classList.add('active');

			const htmlEditorElement = document.querySelector('.challenge-editor.html');
			const cssEditorElement = document.querySelector('.challenge-editor.css');
			// update editor language
			if(tab.innerHTML.toLowerCase() === 'html') {
				htmlEditorElement.classList.add('active');
				cssEditorElement.classList.remove('active');
			}
			else if(tab.innerHTML.toLowerCase() === 'css') {
				htmlEditorElement.classList.remove('active');
				cssEditorElement.classList.add('active');
			}
		});
	});

	/*
	 * This code is used to update the food plate with the code from the editor
	 */
	function updateFoodPlate() {
		const foodPlate = document.querySelector('.food-plate');
        // create shadow root if it doesn't exist
        if (!foodPlate.shadowRoot) {
            foodPlate.attachShadow({ mode: 'open' });
        }
        const shadowRoot = foodPlate.shadowRoot;
        const htmlContent = htmlEditor.getValue();
        const cssContent = `<style>${cssEditor.getValue()}</style>`;
        shadowRoot.innerHTML = cssContent + htmlContent;
	}
	// add event listeners to the editors to detect changes
	htmlEditor.onDidChangeModelContent(updateFoodPlate);
	cssEditor.onDidChangeModelContent(updateFoodPlate);

	// initial update
	updateFoodPlate();

	// setup read-only editor for colors:
	const colorEditor = monaco.editor.create(document.querySelector('.challenge-color-editor'), {
		...generalEditorSettings,
		value: '/* Brown */ \n rgba(128, 64, 48) \n /* Green */ \n rgba(0, 128, 0) \n /* Red */ \n rgba(255, 0, 0)',
		language: 'css',
		lineNumbers: "off",
		glyphMargin: false,
		folding: false,
		readOnly: true,
		lineDecorationsWidth: 0,
		lineNumbersMinChars: 0,
	});

	/*
	 * This code is used to show the modal with the color information
	 * @param {string} title - The title of the modal
	 * @param {function} callback - The function to be attached to the positive button
	 */
	function showModal(title, callback) {
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
	function hideModal() {
		const overlay = document.querySelector('.challenge-overlay');
		overlay.classList.remove('visible');
	}
	// hide modal when pressing the negative button
	const negativeButton = document.querySelector('.popup-button.negative');
	negativeButton.addEventListener('click', hideModal);
  }
}