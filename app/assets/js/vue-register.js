import Vue from "vue";
import {Map, Marker, Polyline, Circle} from "./app-components/google-map";
import {Modal, ModalHeader, ModalBody, ModalFooter} from "./app-components/modal";

Vue.component("google-map", Map);
Vue.component("google-map-marker", Marker);
Vue.component("google-map-polyline", Polyline);
Vue.component("google-map-circle", Circle);

Vue.component("modal", Modal);
Vue.component("modal-header", ModalHeader);
Vue.component("modal-body", ModalBody);
Vue.component("modal-footer", ModalFooter);

export default Vue;