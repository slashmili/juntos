import {TextEditor} from './text_editor';
import {DragAndDropBgChange} from './drag_and_drop_bg_change';
import {LocationFinder} from './location_finder';
import { GoogleMaps } from './google_maps';
import {HideFlash} from './hide_flash';

let Hooks = {};

Hooks.TextEditor = TextEditor;
Hooks.DragAndDropBgChange = DragAndDropBgChange;
Hooks.LocationFinder = LocationFinder;
Hooks.HideFlash = HideFlash;
Hooks.GoogleMaps = GoogleMaps;

Hooks.EventDatepickerLocalDateTime =  {
  mounted() {
    this.setCurrentDatetime();
  },
  updated() {
    this.setCurrentDatetime();
  },
  setCurrentDatetime() {
    const startDateTimeInput = document.getElementById(this.el.dataset['startDatetimeId']);
    const endDateTimeInput = document.getElementById(this.el.dataset['endDatetimeId']);
    const timeZoneInput = document.getElementById(this.el.dataset['timeZoneId']);

    const now = new Date();
    const startDate = new Date(now);
    startDate.setMinutes(0, 0, 0);

    const endDate = new Date(startDate);
    endDate.setHours(startDate.getHours() + 1);

    function formatDateTime(date) {
      const year = date.getFullYear();
      const month = String(date.getMonth() + 1).padStart(2, '0');
      const day = String(date.getDate()).padStart(2, '0');
      const hours = String(date.getHours()).padStart(2, '0');
      const minutes = String(date.getMinutes()).padStart(2, '0');

      return `${year}-${month}-${day}T${hours}:${minutes}`;
    }

    if(! startDateTimeInput.value) {
      startDateTimeInput.value = formatDateTime(startDate);
    }
    if(! endDateTimeInput.value) {
      endDateTimeInput.value = formatDateTime(endDate);
    }
  }
}

export default Hooks;
