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

Hooks.MarkdownIndent = {
  mounted() {
    this.el.addEventListener("keydown", (event) => {
      if (event.key === 'Tab' && event.shiftKey) {
        event.preventDefault();
        const start = this.el.selectionStart;
        const end = this.el.selectionEnd;
        const value = this.el.value;

        // Find the start of the current line or selection
        let lineStart = value.lastIndexOf('\n', start - 1) + 1;
        let lineEnd = value.indexOf('\n', end);
        if (lineEnd === -1) lineEnd = value.length;

        const lines = value.substring(lineStart, lineEnd).split('\n');
        let newLines = [];
        let cursorOffset = 0;

        lines.forEach((line, index) => {
          if (line.startsWith('\t')) {
            newLines.push(line.substring(1));
            if (index === 0) cursorOffset = -1; // Adjust cursor if de-indenting the first affected line
          } else if (line.startsWith('  ')) { // Assuming 2 spaces for soft tabs
            newLines.push(line.substring(2));
            if (index === 0) cursorOffset = -2; // Adjust cursor
          } else {
            newLines.push(line);
          }
        });

        this.el.value = value.substring(0, lineStart) + newLines.join('\n') + value.substring(lineEnd);
        this.el.selectionStart = start + cursorOffset;
        this.el.selectionEnd = end + cursorOffset;
        return;
      }

      if (event.key === 'Tab') {
        event.preventDefault();
        const start = this.el.selectionStart;
        const end = this.el.selectionEnd;

        // Insert a tab character
        this.el.value = this.el.value.substring(0, start) + "\t" + this.el.value.substring(end);

        // Move cursor
        this.el.selectionStart = this.el.selectionEnd = start + 1;
        return;
      }

      if (event.key === 'Enter') {
        event.preventDefault();
        const cursorPos = this.el.selectionStart;
        const textBeforeCursor = this.el.value.substring(0, cursorPos);
        const currentLineStart = textBeforeCursor.lastIndexOf('\n') + 1;
        const currentLine = textBeforeCursor.substring(currentLineStart);

        const indentMatch = currentLine.match(/^\s*/);
        const indent = indentMatch ? indentMatch[0] : "";

        const listMarkerMatch = currentLine.match(/^\s*([-*]|\d+\.)\s+/);
        let newIndent = indent;

        if (listMarkerMatch) {
            // If it's a list, carry over the indentation and marker type
            const marker = listMarkerMatch[1];
            if (/\d+\./.test(marker)) {
                // It's a numbered list, increment the number
                const num = parseInt(marker, 10);
                newIndent = indent.replace(/\d+\./, `${num + 1}.`);
            } else {
                // It's a bulleted list
                newIndent = indent;
            }
        }
        
        const textToInsert = "\n" + newIndent;
        const newCursorPos = cursorPos + textToInsert.length;

        // Insert the new line and indentation
        this.el.value = this.el.value.substring(0, cursorPos) + textToInsert + this.el.value.substring(cursorPos);
        this.el.selectionStart = this.el.selectionEnd = newCursorPos;
      }
    });
  }
}

Hooks.AutosizeTextarea = {
  mounted() {
    this.el.style.overflow = 'hidden'; // Hide scrollbar
    this.adjustHeight();
    this.el.addEventListener('input', () => this.adjustHeight());
  },
  updated() {
    this.adjustHeight();
  },
  adjustHeight() {
    this.el.style.height = 'auto'; // Reset height to auto to shrink
    this.el.style.height = this.el.scrollHeight + 'px'; // Set height to scrollHeight    
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

