const HideFlash = {
  mounted() {
    setTimeout(() => {
      this.pushEvent("lv:clear-flash", {key: this.el.dataset.key})
      this.el.style.dispaly= "none"
    }, 5000);
  }
}

export { HideFlash };
