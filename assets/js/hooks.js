import inputOptGroup from "./hooks/input-otp-group"
import gmapLookup from "./hooks/gmap-lookup"
import gmaps from "./hooks/gmaps"

let Hooks = {
  ...inputOptGroup,
  ...gmapLookup,
  ...gmaps
}

export default Hooks
