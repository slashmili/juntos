import inputOptGroup from "./hooks/input-otp-group"
import gmapLookup from "./hooks/gmap-lookup"
import gmaps from "./hooks/gmaps"
import textEditor from "./hooks/text-editor"

let Hooks = {
  ...inputOptGroup,
  ...gmapLookup,
  ...gmaps,
  ...textEditor
}

export default Hooks
