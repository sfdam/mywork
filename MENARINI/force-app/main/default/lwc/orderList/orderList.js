import {LightningElement, track, api, wire} from "lwc";
import {ShowToastEvent} from "lightning/platformShowToastEvent";
import {reduceErrors} from "c/utils";

const TARGET_OBJECT = "Order";
const BASE_FILTERS = [{fieldName: "Id", fieldValue: null, filterType: "NOT_EQUAL"},  {fieldName: "THR_OrderType__c", fieldValue: ["Customer Service Ord", "Contract invoice",  "Contract invoice (I)", "Domestic order", "Order for Samples", "Referto/Test order", "Rush order", "Shipment only", "Spontaneous shipment", "Standard Order", "Std. Order (I)", "ZCS", "ZDOR", "ZIOR", "ZOR", "ZORS", "ZROR", "ZSHD", "ZTST"], filterType: "IN"}];
const TARGET_FIELDS = [{fieldName: "OrderNumber"}, {fieldName: "THR_OrderType__c", toLabel: true}, {fieldName: "OrderReferenceNumber", customLabel: "N° ordine"}, {fieldName: "PoDate", customLabel: "Data ordine"}, {fieldName: "THR_Division__c", customLabel: "Divisione", toLabel: true}, {fieldName: "Status", toLabel: true}];
const CURRENT_VIEW = "Order View";
const VIEW_OPTIONS = [ 
    {label: "Order View", value: "Order View", fields: ["OrderReferenceNumber", "PoDate", "THR_Division__c", "Status"]},
    {label: "Custom View", value: "Custom View", fields: [ "OrderReferenceNumber", "PoDate", "THR_Division__c", "Status"]}
];

export default class OrderList extends LightningElement {
    loaded = false;
    enhancedRecordListConfiguration;

    connectedCallback() {
        try {
            this.loaded = false;

            this.enhancedRecordListConfiguration = {
                targetObject: TARGET_OBJECT,
                targetFields: [...TARGET_FIELDS],
                distinctTargetOrderByField: "PoDate",
                targetOrderByField: "PoDate",
                ascending: false,
                entriesForPage: 25,
                showRowActions: true,
                actions: [{label: "Dettaglio ordine", name: "orderItems"}],
                filterGroups: [{logicalOperator: "AND", filters: [...BASE_FILTERS]}],
                currentView: CURRENT_VIEW,
                viewOptions: [...VIEW_OPTIONS],
                totalLabel: 'Totale ordini'
            };
        }
        catch (error) {
            this.dispatchEvent(new ShowToastEvent({variant: "error", title: "Error", message: `${reduceErrors(error)}`}));
        }
        
        finally {
            this.loaded = true;
        }
    }

    order = {};
        handleRowActions(event) {
            this.order = event?.detail?.row;

            switch (event.detail.action.name) {
                case 'orderItems':
                    this.template.querySelector('.order-items-modal').openModal();
                    break;
            }
        }
        closeModal(event) {
            this.template.querySelector('.order-items-modal').closeModal();
        }
}