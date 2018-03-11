import Vue from "vue";
import {Modal, ModalHeader, ModalBody, ModalFooter} from "./app-components/modal";

Vue.component("modal", Modal);
Vue.component("modal-header", ModalHeader);
Vue.component("modal-body", ModalBody);
Vue.component("modal-footer", ModalFooter);

export default Vue;