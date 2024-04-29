import {LightningElement, track, api, wire} from "lwc";
import {ShowToastEvent} from "lightning/platformShowToastEvent";
import {reduceErrors} from "c/utils";

const TARGET_OBJECT = "Case";
const BASE_FILTERS = [{fieldName: "Id", fieldValue: null, filterType: "NOT_EQUAL"}, {fieldName: "Community_Visibility__c", fieldValue: false , filterType: "NOT_EQUAL"}];
const TARGET_FIELDS = [{fieldName: "CaseNumber"}, {fieldName: "CreatedDate", customLabel: "Data Segnalazione"}, {fieldName: "THR_RequestType__c", toLabel: true}, {fieldName: "THR_CommercialDivision__c", toLabel: true}, {fieldName: "THR_DDTNumber__c"}, {fieldName: "THR_DDTdate__c"}, {fieldName: "Status", toLabel: true}, {fieldName: "ClosedDate", customLabel: "Data Di Chiusura"}, {fieldName: "THR_ClosureReason__c", customLabel: "Esito Finale", toLabel: true, wrapText: true}, {fieldName: "THR_Dettaglio_dell_esito__c", wrapText: true}];
const CURRENT_VIEW = "Case View";
const VIEW_OPTIONS = [
    {label: "Case View", value: "Case View", fields: ["CaseNumber", "CreatedDate", "THR_RequestType__c", "THR_CommercialDivision__c", "THR_DDTNumber__c", "THR_DDTdate__c", "Status", "ClosedDate", "THR_ClosureReason__c", "THR_Dettaglio_dell_esito__c"]},
    {label: "Custom View", value: "Custom View", fields: ["CaseNumber", "CreatedDate", "THR_RequestType__c", "THR_CommercialDivision__c", "THR_DDTNumber__c", "THR_DDTdate__c", "Status", "ClosedDate",  "THR_ClosureReason__c", "THR_Dettaglio_dell_esito__c"]}
];

export default class CaseList extends LightningElement {
    loaded = false;
    enhancedRecordListConfiguration;

    connectedCallback() {
        try {
            this.loaded = false;

            this.enhancedRecordListConfiguration = {
                targetObject: TARGET_OBJECT,
                targetFields: [...TARGET_FIELDS],
                distinctTargetOrderByField: "CaseNumber",
                targetOrderByField: "CreatedDate",
                ascending: false,
                entriesForPage: 25,
                showRowActions: false,
                actions: [{label: "Details", name: "details"}],
                filterGroups: [{logicalOperator: "AND", filters: [...BASE_FILTERS]}],
                currentView: CURRENT_VIEW,
                viewOptions: [...VIEW_OPTIONS],
                totalLabel: 'Totale Reclami'
            };
        }
        catch (error) {
            this.dispatchEvent(new ShowToastEvent({variant: "error", title: "Error", message: `${reduceErrors(error)}`}));
        }
        finally {
            this.loaded = true;
        }
    }
}