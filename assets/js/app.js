// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss";

// Import icons for sprite-loader
// navbar brand icon
import "../node_modules/@mdi/svg/svg/skull-crossbones.svg"; // brand
// menus etc
import "../node_modules/bootstrap-icons/icons/person-circle.svg"; // accounts menu
import "../node_modules/bootstrap-icons/icons/person-plus.svg"; // new user / register
import "../node_modules/bootstrap-icons/icons/box-arrow-in-left.svg"; // log in
import "../node_modules/bootstrap-icons/icons/box-arrow-right.svg"; // log out
import "../node_modules/bootstrap-icons/icons/sliders.svg"; // new user / register
// forms etc
import "../node_modules/bootstrap-icons/icons/at.svg";
import "../node_modules/bootstrap-icons/icons/key.svg";
import "../node_modules/bootstrap-icons/icons/key-fill.svg";
import "../node_modules/bootstrap-icons/icons/lock.svg";
import "../node_modules/bootstrap-icons/icons/shield-lock.svg";
import "../node_modules/bootstrap-icons/icons/arrow-repeat.svg";
import "../node_modules/bootstrap-icons/icons/door-open.svg"; // log in
import "../node_modules/@mdi/svg/svg/head-question-outline.svg"; // brand

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html";
import { Socket } from "phoenix";
import topbar from "topbar";
import { LiveSocket } from "phoenix_live_view";

// Bootstrap v5 js imports
import "bootstrap/js/dist/alert";
import "bootstrap/js/dist/collapse";
import "bootstrap/js/dist/dropdown";
// Bootstrap helpers
import "./_hamburger-helper";
import "./_form-validity";
// Bootstrap-liveview helpers
import { AlertRemover } from "./_alert-remover";
import { BsModal } from "./_bs_modal";

// LiveSocket setup
let Hooks = {};
Hooks.AlertRemover = AlertRemover;
Hooks.BsModal = BsModal;
let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
  hooks: Hooks,
});

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", (info) => topbar.show());
window.addEventListener("phx:page-loading-stop", (info) => topbar.hide());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;
