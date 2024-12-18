export default {
  EventGroupByDate: {
    mounted() {
      const dates = this.el.querySelectorAll('[data-start-date]')
      const [dateHead, ...datesTail] = dates
      let prevDate = dateHead
      prevDate?.classList?.toggle('hidden');
      for(let date of datesTail) {
        if(date.attributes['data-start-date'].value !== prevDate.attributes['data-start-date'].value) {
          date?.classList?.toggle('hidden');
        }
       prevDate = date
      }

    },
    updated() {
      this.mounted()
    }
  }
}
