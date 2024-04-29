import {LightningElement, api} from 'lwc';

const MODAL_DEFAULT_SIZE = "slds-modal slds-fade-in-open";
const MODAL_SMALL_SIZE = "slds-modal_small";
const MODAL_MEDIUM_SIZE = "slds-modal_medium";
const MODAL_LARGE_SIZE = "slds-modal_large";

export default class Modal extends LightningElement {

    sectionClassList = MODAL_DEFAULT_SIZE;
    open = false;
    @api loading = false;

    @api openModal() {
        this.open = true;
    }

    @api closeModal() {
        this.open = false;
    }


    @api
    get size() {
        if(this.sectionClassList.includes(MODAL_SMALL_SIZE)) {
            return "small";
        }
        else if(this.sectionClassList.includes(MODAL_MEDIUM_SIZE)) {
            return "medium";
        }
        else if(this.sectionClassList.includes(MODAL_LARGE_SIZE)) {
            return "large";
        }
        else {
            return "default";
        }
    }

    set size(value) {
        if(value === "small") {
            this.sectionClassList = `${MODAL_DEFAULT_SIZE} ${MODAL_SMALL_SIZE}`
        }
        else if(value === "medium") {
            this.sectionClassList = `${MODAL_DEFAULT_SIZE} ${MODAL_MEDIUM_SIZE}`
        }
        else if(value === "large") {
            this.sectionClassList = `${MODAL_DEFAULT_SIZE} ${MODAL_LARGE_SIZE}`
        }
        else {
            this.sectionClassList = MODAL_DEFAULT_SIZE;
        }
    }
}