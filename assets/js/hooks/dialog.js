export default {
  Dialog: {
    mounted() {
      this.el.addEventListener('click', this.closeWhenClickOutside);
      this.el.addEventListener('showModal', (e) => {
        e.currentTarget.showModal();
      });
    },
    destroyed(){
      // Is it needed?
      this.el.removeEventListener('click', this.closeWhenClickOutside);
    },
    closeWhenClickOutside(event) {
      if(event.target == event.currentTarget) {
        event.currentTarget.close();
      }
    }
  }
}
