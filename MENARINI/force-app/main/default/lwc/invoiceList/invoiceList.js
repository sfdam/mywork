import {LightningElement, track, api, wire} from "lwc";
import {ShowToastEvent} from "lightning/platformShowToastEvent";
import {reduceErrors} from "c/utils";

const TARGET_OBJECT = "THR_Invoice__c";
const BASE_FILTERS = [{fieldName: "Id", fieldValue: null, filterType: "NOT_EQUAL"}, {fieldName: "THR_InvoiceType__c", fieldValue: ["CN from IE to UE Aff", "Contract invoice", "Cr Memo from Ret (1)", "Cr Memo from Return", "Credit Memo", "Customer Invoice", "Debit Memo", "Domestic custom. Inv", "ZFCR Foreign Credit Memo", "ZFR2 Foreign Credit Memo", "ZFR3 Foreign Credit Memo", "ZFF1 Foreign Customer Inv", "ZFF2 Foreign Customer Inv", "ZFF3 Foreign Customer Inv", "ZFD1 Foreign Debit Memo", "ZFD2 Foreign Debit Memo", "ZFD3 Foreign Debit Memo", "ZFDR Foreign Debit Memo", "Inv from IE to EU Af", "MD Manual Invoice", "Contract invoice (I)" ], filterType: "IN"}];
const TARGET_FIELDS = [{fieldName: "Name"}, {fieldName: "THR_InvoiceType__c", toLabel: true, customLabel: "Tipo documento"}, {fieldName: "THR_AccountingDocumentFI__c", customLabel: "N° documento"}, {fieldName: "THR_AccountingDocumentDate__c", customLabel: "Data emissione"}, {fieldName: "THR_Division__c", toLabel: true, customLabel: "Divisione"}, {fieldName: "Net_Value_RU__c", customLabel: "Valore netto"}, {fieldName: "THR_InvoiceExpiryDate__c", customLabel: "Data scadenza"}];
const CURRENT_VIEW = "Invoice View";
const VIEW_OPTIONS = [
    {label: "Invoice View", value: "Invoice View", fields: ["THR_InvoiceType__c", "THR_AccountingDocumentFI__c", "THR_AccountingDocumentDate__c", "THR_Division__c","Net_Value_RU__c", "THR_InvoiceExpiryDate__c"]},
    {label: "Custom View", value: "Custom View", fields: ["THR_InvoiceType__c", "THR_AccountingDocumentFI__c", "THR_AccountingDocumentDate__c", "THR_Division__c","Net_Value_RU__c", "THR_InvoiceExpiryDate__c"]}
];

export default class InvoiceList extends LightningElement {
    loaded = false;
    enhancedRecordListConfiguration;

    connectedCallback() {
        try {
            this.loaded = false;

            this.enhancedRecordListConfiguration = {
                targetObject: TARGET_OBJECT,
                targetFields: [...TARGET_FIELDS],
                distinctTargetOrderByField: "THR_AccountingDocumentDate__c",
                targetOrderByField: "THR_AccountingDocumentDate__c",
                ascending: false,
                entriesForPage: 25,
                showRowActions: true,
                actions: [{label: "Dettaglio documento", name: "invoiceItems"}],
                filterGroups: [{logicalOperator: "AND", filters: [...BASE_FILTERS]}],
                currentView: CURRENT_VIEW,
                viewOptions: [...VIEW_OPTIONS],
                totalLabel: 'Totale documenti'
            };
        }
        catch (error) {
            this.dispatchEvent(new ShowToastEvent({variant: "error", title: "Error", message: `${reduceErrors(error)}`}));
        }
        finally {
            this.loaded = true;
        }
    }

    invoice = {};

    handleRowActions(event) {
        this.invoice = event?.detail?.row;

        switch (event.detail.action.name) {
            case 'invoiceItems':
                this.template.querySelector('.invoice-items-modal').openModal();
                break;
        }
    }

    closeModal(event) {
        this.template.querySelector('.invoice-items-modal').closeModal();
    }
}