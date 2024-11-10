import { Dropdown } from 'flowbite';

export default {
  FlowbitDropdown: {
    mounted() {
      this.setup();
      this.setupListeners();
    },
    updated() {
      if(this.dropdown.isVisible()) {
        this.dropdown.show();
      }
      //sometimes the elements change like in a location lookup
      this.setupListeners();
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
      
      this.dropdown = dropdown;
      this.dropdownEl = dropdownEl;
    },
    setupListeners() {
      this.dropdownEl.querySelectorAll('[phx-click], a[href]').forEach((clickableItem) => {
        clickableItem.addEventListener('click', () => {
          this.dropdown.hide();
        })
        clickableItem.addEventListener('keydown', (event) => {
          if(event.key == 'Enter') {
            this.dropdown.hide();
          }
        });
      })
    }
  }
}

