import {LightningElement, track, api, wire} from "lwc";
import {ShowToastEvent} from "lightning/platformShowToastEvent";
import {reduceErrors} from "c/utils";

const TARGET_OBJECT = "OrderItem";
const BASE_FILTERS = [{fieldName: "Id", fieldValue: null, filterType: "NOT_EQUAL"}];
const TARGET_FIELDS = [{fieldName: "OrderItemNumber"}, {fieldName: "Product_Industry_Standard__c", customLabel: "AIC Prodotto"}, {fieldName: "Product_Material_Name__c", customLabel: "Prodotto"}, {fieldName: "THR_Position__c", customLabel: "Riga Ordine"}, {fieldName: "THR_MaterialDescription__c", customLabel: "Codice Prodotto"}, {fieldName: "Quantity"}, {fieldName: "THR_OrderItemStatus__c", toLabel: true, customLabel: "Stato Riga"}, {fieldName: "THR_Description__c"}];
const CURRENT_VIEW = "Order View";
const VIEW_OPTIONS = [
    {label: "Order View", value: "Order View", fields: [ "THR_Position__c", "Product_Industry_Standard__c", "Product_Material_Name__c", "Quantity", "THR_OrderItemStatus__c"]},
    {label: "Custom View", value: "Custom View", fields: [ "THR_Position__c", "Product_Industry_Standard__c", "Product_Material_Name__c", "Quantity", "THR_OrderItemStatus__c"]}
];

export default class OrderItemList extends LightningElement {
    loaded = false;
    @api orderId;
    enhancedRecordListConfiguration;

    connectedCallback() {
        try {
            this.loaded = false;
            const filterGroups = [{logicalOperator: "AND", filters: [...BASE_FILTERS]}];

            if(this.orderId?.length > 0) {
                filterGroups[0].filters.push({fieldName: 'OrderId', fieldValue: this.orderId, filterType: 'EQUAL'});
            }
            if(this.orderId?.length > 0) {
                this.enhancedRecordListConfiguration = {
                    targetObject: TARGET_OBJECT,
                    targetFields: [...TARGET_FIELDS],
                    distinctTargetOrderByField: "OrderItemNumber",
                    targetOrderByField: "OrderItemNumber",
                    ascending: true,
                    entriesForPage: 25,
                    showRowActions: false,
                    actions: [],
                    filterGroups: filterGroups,
                    currentView: CURRENT_VIEW,
                    viewOptions: [...VIEW_OPTIONS],
                    totalLabel: 'Totale Righe Ordine'
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