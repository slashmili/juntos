import {TextEditor} from './text_editor';

let Hooks = {};

Hooks.TextEditor = TextEditor;

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

    // Check if the end time is 00:00 and adjust the date to the next day
    if (endDate.getHours() === 0) {
      endDate.setDate(endDate.getDate() + 1);
    }


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
    let timeZone = Intl.DateTimeFormat().resolvedOptions().timeZone;
    timeZoneInput.value = timeZone;
  }
}

//import { EventLocation } from './event-location.js'
import { Loader } from "@googlemaps/js-api-loader"
import Autocomplete from '@trevoreyre/autocomplete-js'

class EventLocationAutocomplete {
  constructor(element, gmapLookup) {
    this.element = element;
    this.gmapLookup = gmapLookup;
  }

  configure() {
    this.autocomplete = new Autocomplete(this.element, {
      autoSelect: true,
      onUpdate: () => {
        console.log('onUpdate')
      },
      search: input => {
        if (input.length < 2) {
          return [];
        }
        if (this.isUrl(input)) {
          //selectedItem.setUrl(input)
          return [];
        }
        return this.gmapLookup.lookup(input);
      },
      getResultValue: result => `${result.item.name} ${result.item.address ? result.item.address : ''}`,
      renderResult: (result, props) => {
        return `
<li ${props} >
<span className="block truncate">

<p class="font-semibold"><span class="hero-map-pin w-4 h-4" ></span> ${result.type == 'place' ? result.item.name : "Use " + result.item.name}</p>
<p class="text-sm">${result.item.address ? result.item.address : ''}</p>
</span>
</li>
`},
      submitOnEnter: true,
      onSubmit: async (result) => {
        console.log('onSubmit', result)
        if (result.item.address == null) {
          //selectedItem.setAddress(result.item.name)
        } else {
          const detailedPlace = await this.gmapLookup.lookupPlaceId(result.item);
          //selectedItem.setPlace(detailedPlace)
        }
      },
      debounceTime: 500
    });
  }

  isUrl(text) {
    const urlPattern = /^(https?:\/\/[^\s/$.?#].[^\s]*)$/i
    return urlPattern.test(text)
  }
}

class GoogleMapLookup {
  constructor(apiKey) {
    this.loader = new Loader({
      apiKey: apiKey,
      version: "weekly"
    });
  }
  async lookup(input) {
    const { Place, AutocompleteSessionToken, AutocompleteSuggestion } = await this.loader.importLibrary("places");
    await google.maps.importLibrary("places");
    let request = {
      input: input,
    };
    const token = new AutocompleteSessionToken();
    request.sessionToken = token;
    const { suggestions } =
      await AutocompleteSuggestion.fetchAutocompleteSuggestions(request);

    const places = suggestions.map((suggestion) => {
      const placePrediction = suggestion.placePrediction;
      const name = placePrediction.mainText.toString();
      const address = this.cleanupAddress(name, placePrediction.text.toString());
      return {
        type: 'place',
        item: { id: placePrediction.placeId, address: address, name: name }
      }
    });
    places.push(
      {
        type: 'address',
        item: {
          name: input,
          address: null,
        }
      })
    return places;
  }

  cleanupAddress(name, address) {
    let regex = new RegExp(name, "i");
    return address.replace(regex, "").replace(/^,?\s*/, "");
  }

  async lookupPlaceId(place) {
    const { Place } = await this.loader.importLibrary("places");
    const placeObj = new Place({ id: place.id })
    await placeObj.fetchFields({ fields: ['location', 'formattedAddress'] })
    return { ...place, address: placeObj.formattedAddress }
  }
}

Hooks.LocationFinder = {
  mounted() {
    this.gmapApiKey = this.el.dataset['apiKey'];
    this.input = this.el.querySelector('input');
    this.changeLeadingIcon();
    this.changeTrailingIcon();
    this.gmapLookup = new GoogleMapLookup(this.el.dataset['apiKey'])
    this.autocomplete = new EventLocationAutocomplete(this.el, this.gmapLookup)
    this.autocomplete.configure();
  },
  changeLeadingIcon() {
    const leadingIcon = this.el.querySelector('.input-leading-icon')
    this.input.addEventListener('input', (event) => {
      const isUrl = this.isUrl(event.target.value);
      leadingIcon.classList.toggle('hero-map-pin', !isUrl);
      leadingIcon.classList.toggle('hero-video-camera', isUrl);
    });
  },
  changeTrailingIcon() {
    const trailingIcon = this.el.querySelector('.input-trailing-icon')
    this.input.addEventListener('input', (event) => {
      trailingIcon.classList.toggle('hidden', event.target.value == '');
    });
    trailingIcon.addEventListener('click', () => {
      this.input.value = '';
      trailingIcon.classList.toggle('hidden');
    });
  },
  isUrl(text) {
    const urlPattern = /^(https?:\/\/[^\s/$.?#].[^\s]*)$/i
    return urlPattern.test(text)
  }
}
export default Hooks;
