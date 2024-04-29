import {LightningElement, track, api, wire} from "lwc";
import {ShowToastEvent} from "lightning/platformShowToastEvent";
import {reduceErrors} from "c/utils";

const TARGET_OBJECT = "THR_InvoiceItem__c";
const BASE_FILTERS = [{fieldName: "Id", fieldValue: null, filterType: "NOT_EQUAL"}];
const TARGET_FIELDS = [{fieldName: "Name"}, {fieldName: "THR_ItemNumber__c", customLabel: "Numero riga"}, {fieldName: "Product_Industry_Standard__c", customLabel: "AIC prodotto"}, {fieldName: "THR_ProductName__c", customLabel: "Prodotto"}, {fieldName: "THR_NetValue__c", customLabel: "Valore netto"}, {fieldName: "THR_Quantity__c"}, {fieldName: "THR_DDT__c"}, {fieldName: "THR_DateDDT__c"}];
const CURRENT_VIEW = "Invoice View";
const VIEW_OPTIONS = [
    {label: "Invoice View", value: "Invoice View", fields: [ "THR_ItemNumber__c","Product_Industry_Standard__c", "THR_ProductName__c", "THR_Quantity__c", "THR_NetValue__c", "THR_DDT__c", "THR_DateDDT__c"]},
    {label: "Custom View", value: "Custom View", fields: [ "THR_ItemNumber__c", "Product_Industry_Standard__c", "THR_ProductName__c", "THR_Quantity__c", "THR_NetValue__c", "THR_DDT__c", "THR_DateDDT__c"]}
];

export default class InvoiceItemList extends LightningElement {
    loaded = false;
    @api invoiceId;
    enhancedRecordListConfiguration;

    connectedCallback() {
        try {
            this.loaded = false;
            const filterGroups = [{logicalOperator: "AND", filters: [...BASE_FILTERS]}];

            if(this.invoiceId?.length > 0) {
                filterGroups[0].filters.push({fieldName: 'THR_InvoiceNumber__c', fieldValue: this.invoiceId, filterType: 'EQUAL'});
            }

            if(this.invoiceId?.length > 0) {
                this.enhancedRecordListConfiguration = {
                    targetObject: TARGET_OBJECT,
                    targetFields: [...TARGET_FIELDS],
                    distinctTargetOrderByField: "Name",
                    targetOrderByField: "Name",
                    ascending: true,
                    entriesForPage: 25,
                    showRowActions: false,
                    actions: [],
                    filterGroups: filterGroups,
                    currentView: CURRENT_VIEW,
                    viewOptions: [...VIEW_OPTIONS],
                    totalLabel: 'Totale righe documento'
                };
            }
        }
        catch (error) {
            this.dispatchEvent(new ShowToastEvent({variant: "error", title: "Error", message: `${reduceErrors(error)}`}));
        }
        finally {
            this.loaded = true;
        }
    }
}