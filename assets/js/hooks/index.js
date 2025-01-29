let Hooks = {}

Hooks.EventDatepickerLocalDateTime =  {
    mounted() {
    const startDateTimeInput = document.getElementById(this.el.dataset['startDatetimeId']);
    const endDateTimeInput = document.getElementById(this.el.dataset['endDatetimeId']);
    const timeZoneInput = document.getElementById(this.el.dataset['timeZoneId']);
    

    let now = new Date();
    let startDate = new Date(now);
    startDate.setMinutes(0, 0, 0);

    let endDate = new Date(startDate);
    endDate.setHours(startDate.getHours() + 1);

    // Check if the end time is 00:00 and adjust the date to the next day
    if (endDate.getHours() === 0) {
      endDate.setDate(endDate.getDate() + 1);
    }

    function formatDateTime(date) {
      return date.toISOString().slice(0, 16);
    }

    if(! startDateTimeInput.value) {
      startDateTimeInput.value = formatDateTime(startDate);
    }
    if(! endDateTimeInput.value) {
      endDateTimeInput.value = formatDateTime(endDate);
    }
    let timeZone = Intl.DateTimeFormat().resolvedOptions().timeZone;
    timeZoneInput.value = timeZone
  }
}
export default Hooks;
