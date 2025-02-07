export class EventLocation {
  constructor(type, value) {
    this.type = type;
    this.value = value;
    this.urlListeners = [];
    this.placeListeners = [];
    this.addressListeners = [];
    this.emptyListeners = [];
  }

  onUrlChange(listener) {
    this.urlListeners.push(listener)
  }

  onPlaceChange(listener) {
    this.placeListeners.push(listener)
  }

  onAddressChange(listener) {
    this.addressListeners.push(listener);
  }

  onReset(listener) {
    this.emptyListeners.push(listener);
  }

  setEmpty() {
    this.type = 'empty';
    this.value = null;
    this.notifyEmpty();
  }

  setUrl(url) {
    this.type = 'url'
    this.value = url
    this.notifyUrl()
  }

  setPlace(place) {
    this.type = 'place'
    this.value = place
    this.notifyPlace()
  }

  setAddress(address) {
    this.type = 'address'
    this.value = address
    this.notifyAddress()
  }

  notifyUrl() {
    this.urlListeners.forEach(listener => listener(this.value));
  }
  notifyPlace() {
    this.placeListeners.forEach(listener => listener(this.value));
  }
  notifyAddress() {
    this.addressListeners.forEach(listener => listener(this.value));
  }
  notifyEmpty() {
    this.emptyListeners.forEach(listener => listener());
  }
}
