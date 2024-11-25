import { Loader } from "@googlemaps/js-api-loader"
export default {
  Gmaps: {
    mounted() {
      const loader = new Loader({
        apiKey: this.el.dataset.apiKey,
        version: "weekly"
      });
      this.loadMap(loader)
    },
    async loadMap(loader) {
      const { Map } =  await loader.importLibrary("maps");
      const { Place } = await loader.importLibrary("places");
      const { AdvancedMarkerElement } = await loader.importLibrary("marker");
      place = JSON.parse(this.el.dataset.place)
      const placeObj = new Place({id: place.id})
      await placeObj.fetchFields({fields: ['location', 'formattedAddress']})
      //Replace current place with more detials
      this.pushEvent("select-place-update-address", { ...place, address: placeObj.formattedAddress})
      const map = new Map(this.el, {
        center: placeObj.location,
        mapId: this.el.dataset.mapId,
        zoom: 15,
        zoomControl: false,
        mapTypeControl: false,
      })
      const marker = new AdvancedMarkerElement({
        map,
        position: placeObj.location,
      });
    }
  }
}

