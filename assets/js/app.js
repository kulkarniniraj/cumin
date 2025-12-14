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
import Alpine from "../vendor/alpine.cdn.min"
import Chart from "../vendor/chart.js"

window.Chart = Chart
window.Alpine = Alpine
Alpine.start()

// Start AlpineJS when LiveView is done loading the page
window.addEventListener("phx:page-loading-stop", (_info) => Alpine.start());

let Hooks = {}
Hooks.AdminCharts = {
  mounted() {
    const data1 = {
      labels: ['Red', 'Blue', 'Yellow'],
      datasets: [{
        data: [30, 50, 20],
        backgroundColor: ['#ff6384', '#36a2eb', '#ffce56']
      }]
    };

    const data2 = {
      labels: ['Apples', 'Oranges', 'Bananas'],
      datasets: [{
        data: [40, 35, 25],
        backgroundColor: ['#4bc0c0', '#ff9f40', '#9966ff']
      }]
    };

    new Chart(this.el.querySelector('#ticketsByTypeChart'), {
      type: 'pie',
      data: data1
    });

    new Chart(this.el.querySelector('#ticketsByStatusChart'), {
      type: 'pie',
      data: data2
    });

    new Chart(this.el.querySelector('#ticketsByUserChart'), {
      type: 'pie',
      data: data2
    });
  }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken},
  hooks: Hooks
})


// Alpine.start()

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

