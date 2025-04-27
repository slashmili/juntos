import { EventLocation } from './event-location.js'
import { Loader } from "@googlemaps/js-api-loader"
import Autocomplete from '@trevoreyre/autocomplete-js'

class EventLocationAutocomplete {
  constructor(element, gmapLookup, selectedItem) {
    this.element = element;
    this.gmapLookup = gmapLookup;
    this.selectedItem = selectedItem;
  }

  configure() {
    const selectedItem = new EventLocation('empty', null);
    this.autocomplete = new Autocomplete(this.element, {
      autoSelect: true,
      onUpdate: () => {
      },
      search: input => {
        if (input.length < 2) {
          return [];
        }
        if (this.isUrl(input)) {
          this.selectedItem.setUrl(input)
          return [];
        }
        return this.gmapLookup.lookup(input);
      },
      getResultValue: result => `${result.item.name} ${result.item.address ? result.item.address : ''}`,
      renderResult: (result, props) => {
        return `
<li ${props} >
<div class="flex items-center truncate gap-2">
  <div><span class="hero-map-pin w-4 h-[1lh]" ></span></div>
  <div>
     ${result.type == 'place' ? result.item.name : "Use " + result.item.name}
    <p class="text-neutral-secondary text-sm truncate">${result.item.address ? result.item.address : ''}</p>
  </div>
</div>
</li>
`},
      submitOnEnter: true,
      onSubmit: async (result) => {
        if (result.item.address == null) {
          this.selectedItem.setAddress(result.item.name)
        } else {
          const detailedPlace = await this.gmapLookup.lookupPlaceId(result.item);
          this.selectedItem.setPlace(detailedPlace)
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
    await placeObj.fetchFields({ fields: ['location', 'formattedAddress', 'addressComponents'] })

    const addressComponents = placeObj.addressComponents;
    const cityComponent = addressComponents.find(component => 
      component.types.includes('locality')
    );
    const city = cityComponent ? cityComponent.longText : null;

    const countryComponent = addressComponents.find(component => 
      component.types.includes('country')
    );
    const country = countryComponent ? countryComponent.longText : null;

    return { ...place, address: placeObj.formattedAddress, city: city, country: country }
  }
}


const LocationFinder = {
  mounted() {
    this.gmapApiKey = this.el.dataset['apiKey'];
    this.input = this.el.querySelector('input');
    this.changeLeadingIcon();
    this.changeTrailingIcon();
    this.selectedItem = new EventLocation('empty', null);
    this.selectedItem.onUrlChange(url => {
      this.pushEvent("location-finder", {type: "url", value: url})
    });
    this.selectedItem.onPlaceChange(place => {
      this.pushEvent("location-finder", {type: "place", value: place})
    });
    this.selectedItem.onAddressChange(address => {
      this.pushEvent("location-finder", {type: "address", value: address})
    });
    this.selectedItem.onReset(() => {
      this.pushEvent("location-finder", {type: "reset"})
    });




    this.gmapLookup = new GoogleMapLookup(this.el.dataset['apiKey'])
    this.autocomplete = new EventLocationAutocomplete(this.el, this.gmapLookup, this.selectedItem)
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
      this.selectedItem.setEmpty();
      trailingIcon.classList.toggle('hidden');
    });
  },
  isUrl(text) {
    const urlPattern = /^(https?:\/\/[^\s/$.?#].[^\s]*)$/i
    return urlPattern.test(text)
  }
}

export { LocationFinder };
