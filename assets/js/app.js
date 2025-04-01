// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"
import Hooks from "./hooks"



let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let timeZone = Intl.DateTimeFormat().resolvedOptions().timeZone
let liveSocket = new LiveSocket("/live", Socket, {
  hooks: Hooks,
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken, timeZone: timeZone}
})

// set value and bubbles
window.addEventListener("juntos:force_set_value", (event) => {
  event.srcElement.value = event.detail.value;
  event.srcElement.dispatchEvent(new Event("change", { bubbles: true }));
});

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

function base64ToBlob(base64, mimeType) {
    const byteCharacters = atob(base64); // Decode base64
    const byteNumbers = new Uint8Array(byteCharacters.length);
    for (let i = 0; i < byteCharacters.length; i++) {
        byteNumbers[i] = byteCharacters.charCodeAt(i);
    }
    return new Blob([byteNumbers], { type: mimeType });
}

window.addEventListener(`phx:download`, (event) => {
  const blob = base64ToBlob(event.detail.content_base64, event.detail.content_type);
  const link = document.createElement('a');
  link.href = URL.createObjectURL(blob);
  link.download = event.detail.filename;
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
});

window.addEventListener("phx:live_reload:attached", ({detail: reloader}) => {
  // enable server log streaming to client.
  // disable with reloader.disableServerLogs()
  reloader.enableServerLogs()
   window.liveReloader = reloader
})
// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

window.matchMedia('(prefers-color-scheme: light)').addEventListener('change', event => {
  document.documentElement.classList.toggle('dark', !event.matches);
});

// Remove dark mode if system prefers light
if (window.matchMedia('(prefers-color-scheme: light)').matches) {
  document.documentElement.classList.remove('dark');
}
