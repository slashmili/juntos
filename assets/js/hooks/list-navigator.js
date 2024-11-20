export default {
  ListNavigator: {
    mounted() {

      const btn = document.getElementById(this.el.dataset.listNavigatorButtonId)
      const items = this.el.querySelectorAll('button');
      const itemLength = items.length
      const hook = this;
      const keyDowns = ['ArrowDown', 'j', 'J'];
      const keyUps = ['ArrowUp', 'k', 'K'];
      for(let item of items) {
        item.addEventListener('mouseover', (event) => {
          event.currentTarget.focus()
        });
      }
      btn?.addEventListener('keydown', (event) => {
        if(keyDowns.includes(event.key)) {
          items[0]?.focus();
          event.preventDefault();
        }
      });
      this.el.addEventListener('keydown', (event) => {
        const isKeyDown = keyDowns.includes(event.key)
        const isKeyUp = keyUps.includes(event.key)
        if(isKeyDown || isKeyUp) {
          const focusedIndex = this.currentFocusedIndex(items);
          const nextIndexCalc = (focusedIndex, itemLength) => {
            if (isKeyDown) {
              return this.nextIndex(focusedIndex, itemLength);
            } else {
              return this.prevIndex(focusedIndex, itemLength);
            }
          }
          items[nextIndexCalc(focusedIndex, itemLength)]?.focus();
          event.preventDefault();
        }
      })
    },
    currentFocusedIndex(items) {
      const index =  Array
      .from(items)
      .findIndex((item) => item === document.activeElement);
      return index == -1 ? 0: index;
    },
    nextIndex(focusedIndex, itemLength) {
        return (focusedIndex + 1) % itemLength;
    },
    prevIndex(focusedIndex, itemLength) {
        return (focusedIndex - 1 + itemLength) % itemLength;
    }
  }
}

