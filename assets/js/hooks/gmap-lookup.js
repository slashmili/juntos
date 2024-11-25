import { Loader } from "@googlemaps/js-api-loader"
export default {
  GmapLookup: {
    mounted () {
      const loader = new Loader({
        apiKey: this.el.dataset.apiKey,
        version: "weekly"
      });


      const input = this.el.getElementsByTagName('input')[0]
      this.listeners(input, loader)
    },
    listeners (input, loader) {
      input.addEventListener('input', (event) => {
        if (event.target.value.length == 0) {
          this.pushEvent("gmap-suggested-places", [])
        }
        if (event.target.value.length > 3) {
          this.lookup(event.target.value, loader)
        }
      });

        input.addEventListener('keydown', (event) => {
          if (event.key === 'Enter') {
            event.preventDefault();
          }
        });
    },
    async lookup (searchValue, loader) {
      const { Place, AutocompleteSessionToken, AutocompleteSuggestion } = await loader.importLibrary("places");
      await google.maps.importLibrary("places");
      let request = {
        input: searchValue,
      };

      const token = new AutocompleteSessionToken();
      request.sessionToken = token;
      const { suggestions } =
        await AutocompleteSuggestion.fetchAutocompleteSuggestions(request);

      const places = suggestions.map((suggestion) => {
        const placePrediction = suggestion.placePrediction;
        const name = placePrediction.mainText.toString();
        const address = this.cleanupAddress(name, placePrediction.text.toString());
        return {id: placePrediction.placeId, address:  address, name: name}
      })

      this.pushEvent("gmap-suggested-places", places)


    },
    cleanupAddress(name, address) {
      let regex = new RegExp(name, "i"); 
      return address.replace(regex, "").replace(/^,?\s*/, "");
    },
  }
}
