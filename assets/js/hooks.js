import inputOptGroup from "./hooks/input-otp-group"
import gmapLookup from "./hooks/gmap-lookup"
import gmaps from "./hooks/gmaps"
import textEditor from "./hooks/text-editor"
import listNavigator from "./hooks/list-navigator"
import fdropdown from "./hooks/flowbit-dropdown"
import dialog from "./hooks/dialog"
import eventGroupByDate from "./hooks/event-group-by-date"

let Hooks = {
  ...inputOptGroup,
  ...gmapLookup,
  ...gmaps,
  ...textEditor,
  ...listNavigator,
  ...fdropdown,
  ...dialog,
  ...eventGroupByDate
}

export default Hooks
