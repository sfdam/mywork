import { LightningElement,api } from 'lwc';
import {ShowToastEvent} from "lightning/platformShowToastEvent";
import getOptions from '@salesforce/apex/LookupComboboxController.getOptions';

const GENERIC_ERROR_MESSAGE = "Si è verificato un errore";

export default class LookupCombobox extends LightningElement {

    @api label = "Related to"
    @api targetObject;
    @api targetField;
    @api queryLimit = "10";
    @api optionIcon;
    options = [];
    selectedOption;

    mouseOverContainer = false;

    mouseOverContainerHandler(event) {
        this.mouseOverContainer = true;
    }

    mouseLeaveContainerHandler(event) {
        this.mouseOverContainer = false;
    }

    connectedCallback() {
        window.document.addEventListener("click", this.clickOutsideContainerBind);
    }

    disconnectedCallback() {
        window.document.removeEventListener('click', this.clickOutsideContainerBind);
    }

    clickOutsideContainerBind = this.clickOutsideContainer.bind(this);

    clickOutsideContainer(event) {
        if(this.mouseOverContainer === false) {
            this.template.querySelector(".slds-combobox__input").classList.remove("slds-has-focus");
            const dropdownTrigger = this.template.querySelector(".slds-dropdown-trigger");
            dropdownTrigger.classList.remove("slds-is-open");
            dropdownTrigger.setAttribute("aria-expanded", false);
        }
    }

    focusHandler(event) {
        if(this.selectedOption == null && this.options?.length > 0) {
            event.currentTarget.classList.add("slds-has-focus");
            const dropdownTrigger = this.template.querySelector(".slds-dropdown-trigger");
            dropdownTrigger.classList.add("slds-is-open");
            dropdownTrigger.setAttribute("aria-expanded", true);
        }
    }

    async searchHandler(event) {
       try {
            event.stopPropagation();
            this.loading = true;
            const searchValue = event?.target?.value;
            let options = [];

            if (searchValue?.length >= 3) {
                options = await getOptions({targetObject: this.targetObject, targetField: this.targetField, searchValue: searchValue, queryLimit: this.queryLimit});
            }

            const input = this.template.querySelector(".slds-combobox__input");
            const dropdownTrigger = this.template.querySelector(".slds-dropdown-trigger");
            this.options = options.map((option, index) => {return {label: option.label, value: option.value, key: `${index}`};});

            if(this.selectedOption == null && this.options?.length > 0) {
                input.classList.add("slds-has-focus");
                dropdownTrigger.classList.add("slds-is-open");
                dropdownTrigger.setAttribute("aria-expanded", true);
            }
            else {
                input.classList.remove("slds-has-focus");
                dropdownTrigger.classList.remove("slds-is-open");
                dropdownTrigger.setAttribute("aria-expanded", false);
            }

        }
        catch (error) {
            this.dispatchEvent(new ShowToastEvent({variant: "error", title: "Error", message: GENERIC_ERROR_MESSAGE}));
        }
        finally {
            this.loading = false;
        }
    }

    optionSelectionHandler(event) {
        const option = this.options.find(option => option.key === event.currentTarget?.dataset?.key);
        if(option) {
            this.selectedOption = option;
            const input = this.template.querySelector(".slds-combobox__input");
            input.classList.remove("slds-has-focus");
            input.value = option.label;
            const comboBoxFormElement = this.template.querySelector(".slds-combobox__form-element.slds-input-has-icon");
            comboBoxFormElement.classList.remove("slds-input-has-icon_right");
            comboBoxFormElement.classList.add("slds-input-has-icon_left-right");
            const dropdownTrigger = this.template.querySelector(".slds-dropdown-trigger");
            dropdownTrigger.classList.remove("slds-is-open");
            dropdownTrigger.setAttribute("aria-expanded", false);
            this.dispatchEvent(new CustomEvent('select', {detail: this.selectedOption}));
        }
    }

    removeSelection(event){
        this.selectedOption = null;
        const input = this.template.querySelector(".slds-combobox__input");
        input.classList.remove("slds-has-focus");
        input.value = "";
        const comboBoxFormElement = this.template.querySelector(".slds-combobox__form-element.slds-input-has-icon");
        comboBoxFormElement.classList.add("slds-input-has-icon_right");
        comboBoxFormElement.classList.remove("slds-input-has-icon_left-right");
        const dropdownTrigger = this.template.querySelector(".slds-dropdown-trigger");
        dropdownTrigger.classList.remove("slds-is-open");
        dropdownTrigger.setAttribute("aria-expanded", false);
        this.dispatchEvent(new CustomEvent('remove'));
    }
}