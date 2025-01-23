import { Controller } from "@hotwired/stimulus";
import * as monaco from 'monaco-editor';
import { showModal, hideModal } from './main_controller.js';

export default class extends Controller {
    connect() {

        /*
        * This code is used to setup the editors for the challenge
        */
        const generalEditorSettings = {
            theme: 'vs-dark', 
            automaticLayout: true,
            lineNumbers: "on",
            roundedSelection: false,
            scrollBeyondLastLine: true,
            readOnly: false,
            wordWrap: 'on',
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
        const htmlEditor = monaco.editor.create(document.querySelector('.challenge-editor.html'), {
            ...generalEditorSettings,
            value: '<!-- Type your code here. --> \n <!-- Make sure to include comments like this to get the best score possible! -->',
            language: 'html',
        });
        const cssEditor = monaco.editor.create(document.querySelector('.challenge-editor.css'), {
            ...generalEditorSettings,
            value: '/* Type your code here */ \n /* Make sure to include comments like this to get the best score possible! */',
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

        /*
        * This code is used to set up the color editor
        */
        const colorEditorElement = document.querySelector('.challenge-color-editor');
        const colorEditorDataCode = colorEditorElement.getAttribute('data-code');
        const colorEditor = monaco.editor.create(colorEditorElement, {
            ...generalEditorSettings,
            value: colorEditorDataCode,
            language: 'css',
            lineNumbers: "off",
            wordWrap: 'off',
            glyphMargin: false,
            folding: false,
            readOnly: true,
            lineDecorationsWidth: 0,
            lineNumbersMinChars: 0,
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
        /*
        * This code is used to visibly toggle between the tabs in the order
        */
        const orderTabs = document.querySelectorAll('.order-tab');
        orderTabs.forEach(tab => {
            tab.addEventListener('click', () => {
                orderTabs.forEach(tab => tab.classList.remove('active'));
                tab.classList.add('active');
                toggleOrders(tab.innerHTML.toLowerCase());
            });
        });

        
        let currentOrder = null;
        let completedOrders = [];
        let listenersAdded = false;

        const updateOrder = async (action) => {
            if (!currentOrder) return;

            const url = `/update_order`;
            const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
            const htmlContent = htmlEditor.getValue();
            const cssContent = cssEditor.getValue();
            const challengeId = document.querySelector('body').getAttribute('data-challenge-id');
            const orderId = currentOrder.getAttribute('data-order-id');

            // show waiting screen
            showModal('Please wait while we get your score', () => { hideModal() });

            fetch(url, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-Token': csrfToken
                },
                body: JSON.stringify({
                    action: action,
                    challenge_id: challengeId,
                    order_id: orderId,
                    html: htmlContent,
                    css: cssContent
                })
            })
            .then(response => response.json())
            .then(data => { 
                if (data.error) {
                    alert(data.error);
                } else if (data.success) {
                    // Update the score in the DOM
                    document.querySelector('.challenge-score').textContent = `${data.updated_score}`;
                }
            })
            .catch((error) => {
                console.error('Error:', error);
            });
        }
        
        /*
        * This code is used to accept the order and handle delivery/cancelling of the order
        */
        document.querySelectorAll('.order-action-button.accept').forEach(button => {
            button.addEventListener('click', (event) => {
                if (currentOrder) {
                    alert('You already have an active order!');
                    return;
                }

                // define affected elements
                const orderButtons = event.target.parentNode;
                const orderActionButtons = document.querySelectorAll('.order-action-button');
                const currentOrderText = document.querySelector('.challenge-current p');
                const editorActionButtons = document.querySelectorAll('.editor-action');
                currentOrder = event.target.parentNode.parentNode;

                /*
                * This code is used to reset the visuals of the order
                */
                const resetOrderVisuals = () => {
                    currentOrder.classList.remove('current');
                    currentOrder.classList.add('completed');
                    currentOrder.classList.remove('urgent');
                    for (let i = 0; i < orderButtons.children.length; i++) {
                        orderButtons.children[i].disabled = true; // disable this order button
                    }
                    orderActionButtons.forEach(btn => btn.disabled = false); // enable all order buttons
                    editorActionButtons.forEach(btn => btn.disabled = true); // disable all editor buttons
                    currentOrderText.innerHTML = 'Order request will appear here!'; // reset text
                    currentOrder = null;
                    toggleOrders('urgent');
                }

                const completeOrder = () => {
                    // check if we are done:
                    const undoneOrders = document.querySelectorAll('.order.urgent');
                    if (undoneOrders.length === 0) {
                        showModal('You have completed all orders! Congratulations! Go back to Dashboard?', () => {
                            window.location.href = '/dashboard';
                        });
                        return;
                    }

                    // set order to completed
                    completedOrders.push({currentOrder: false});
                    currentOrder.classList.add('completed');
                    currentOrder.classList.remove('urgent');

                    resetOrderVisuals();

                    hideModal();
                }
                /*
                * This code is used to deliver the order
                */
                const deliverOrder = () => {
                    if (!currentOrder) return;
                    showModal('Are you sure you want to deliver the order?', async () => {
                        await updateOrder('deliver');

                        completeOrder();
                    });
                }
                /*
                * This code is used to cancel the order
                */
                const cancelOrder = () => {
                    if (!currentOrder) return;
                    showModal('Are you sure you want to cancel the order?', async () => {
                        await updateOrder('cancel');

                        completeOrder();
                    });
                }

                // update current order message and style
                currentOrder.classList.add('current');
                const orderMessage = currentOrder.querySelector('.order-text p').innerText;
                orderButtons.style.display = 'none';
                currentOrderText.innerHTML = orderMessage;
                
                orderActionButtons.forEach(btn => btn.disabled = true); //disable all order buttons
                editorActionButtons.forEach(btn => btn.disabled = false); // enable all editor buttons

                if (!listenersAdded) { // do not repeat listeners
                    document.querySelector('.editor-action.deliver').addEventListener('click', deliverOrder);
                    document.querySelector('.editor-action.cancel').addEventListener('click', cancelOrder);
                    listenersAdded = true;
                }
            });
        });
    }
}