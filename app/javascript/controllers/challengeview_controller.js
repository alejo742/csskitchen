import { Controller } from "@hotwired/stimulus";
import * as monaco from 'monaco-editor';

export default class extends Controller {
  connect() {
    // toggling between tabs
    const orderTabs = document.querySelectorAll('.order-tab');
    orderTabs.forEach(tab => {
		tab.addEventListener('click', () => {
			orderTabs.forEach(tab => tab.classList.remove('active'));
			tab.classList.add('active');
			toggleOrders(tab.innerHTML.toLowerCase());
		});
    });
    // make the toggles work
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
  	}

	const htmlEditorElement = document.querySelector('.challenge-editor.html');
	if (htmlEditorElement) {
	  monaco.editor.create(htmlEditorElement, {
		...generalEditorSettings,
		value: '<!-- Type your code here -->',
		language: 'html',
	  });
	}

	const cssEditorElement = document.querySelector('.challenge-editor.css');
	if (cssEditorElement) {
	  monaco.editor.create(cssEditorElement, {
		...generalEditorSettings,
		value: '/* Type your code here */',
		language: 'css',
	  });
	}

	// toggling between editors
	const editorTabs = document.querySelectorAll('.editor-tab');
	editorTabs.forEach(tab => {
		tab.addEventListener('click', () => {
			// visual active tab
			editorTabs.forEach(tab => tab.classList.remove('active'));
			tab.classList.add('active');

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
  }
}