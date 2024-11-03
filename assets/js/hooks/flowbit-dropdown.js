import { Dropdown } from 'flowbite';

export default {
  FlowbitDropdown: {
    mounted() {
      this.setup();
    },
    updated() {
      this.setup();
    },
    setup() {
      const dropdownId = this.el.getAttribute("data-flowbit-dropdown-custom-toggle")
      const dropdownEl = document.getElementById(dropdownId);
      if (!dropdownEl) return ;
      const delay = this.el.getAttribute("data-flowbit-dropdown-custom-delay");
      const options = {
        delay: delay
      };
      const dropdown = new Dropdown(dropdownEl, this.el, options, {override: true});
      
      dropdownEl.querySelectorAll('[phx-click], a[href]').forEach((clickableItem) => {
        clickableItem.addEventListener('click', () => {
          dropdown.toggle();
        })
        clickableItem.addEventListener('keydown', (event) => {
          if(event.key == 'Enter') {
            dropdown.toggle();
          }
        });

      })
    },
  }
}

