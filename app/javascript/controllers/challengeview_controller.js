import { Controller } from "@hotwired/stimulus"

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
  }
}