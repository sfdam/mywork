import { LightningElement, api, track, wire} from 'lwc';
import fetchOpportunitaEsitoIncontro from '@salesforce/apex/OpportunitaEsitoIncontroController.fetchOpportunitaEsitoIncontro';
import {notifyRecordUpdateAvailable } from "lightning/uiRecordApi";
import updateOpportunitaEsitoIncontro from '@salesforce/apex/OpportunitaEsitoIncontroController.updateOpportunitaEsitoIncontro';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import NAME from "@salesforce/schema/Opportunity.Name";
import DATAINVESTMENTCOMMITTEE from "@salesforce/schema/Opportunity.Data_investment_committee__c";
import ORARIOIBCOMMITTEE from "@salesforce/schema/Opportunity.Orario_IB_Committee__c";
import DELIBERATOIBCOMMITTEE from "@salesforce/schema/Opportunity.Deliberato_IB_Committee__c";
import DATADELIBERAINVESTMENTCOMMITTEE from "@salesforce/schema/Opportunity.Data_delibera_investment_committee__c";
import CIBVERBALEMEETING from "@salesforce/schema/Opportunity.CIB_Verbale_Meeting__c";
import DATASTIPULASIGNING from "@salesforce/schema/Opportunity.Data_Stipula_Signing__c";
import FORECASTEROGAZIONISAVED from "@salesforce/schema/Opportunity.Forecast_Erogazioni_Saved__c";
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import OPPORTUNITY_OBJECT from '@salesforce/schema/Opportunity';

const columns = [
    { label: 'Nome Opportunità', fieldName: NAME.fieldApiName, type: 'string', editable: false },
    { label: 'Nome Opportunità', fieldName: 'CIB_Nome_Opportunita__c', type: 'string', editable: false},
    { label: 'Nome Account', fieldName: 'AccountName', type: 'string', editable: false},
    { label: 'Titolare Opportunità', fieldName: 'OwnerName', type: 'string', editable: false},
    { label: 'Data IB Committee', fieldName: DATAINVESTMENTCOMMITTEE.fieldApiName, type: 'date-local', editable: true },
    //{ label: 'Orario IB Committee', fieldName: ORARIOIBCOMMITTEE.fieldApiName, type: 'string', editable: true },
    {
        label: 'Deliberato IB Committee', fieldName: DELIBERATOIBCOMMITTEE.fieldApiName, type: 'picklistColumn', editable: true, typeAttributes: {
            placeholder: 'Seleziona', options: { fieldName: 'pickListOptions' }, 
            value: { fieldName: DELIBERATOIBCOMMITTEE.fieldApiName }, // default value for picklist,
            context: { fieldName: 'Id' } // binding opportunity Id with context variable to be returned back
        }
    },
    { label: 'Data delibera IB Committee', fieldName: DATADELIBERAINVESTMENTCOMMITTEE.fieldApiName, type: 'date-local', editable: true },
    { label: 'Verbale Meeting', fieldName: CIBVERBALEMEETING.fieldApiName, type: 'string', editable: true }/*,
    { label: 'Data Stipula Signing', fieldName: DATASTIPULASIGNING.fieldApiName, type: 'date-local', editable: true},
    { label: 'Forecast Erogazioni Saved', fieldName: FORECASTEROGAZIONISAVED.fieldApiName, type: 'boolean', editable: true}*/

];

export default class OpportunitaEsitoIncontroComponent extends LightningElement {
    @api recordId;
    @track data = [];
    error;
    columns = columns;
    @track draftValues = [];
    @track opportunity = [];
    @track options = [];
    recordTypeId;
    @track pickListOptions = [];
    @track lastSavedData = [];
    isLoading = true;
    isUsedAsRelatedList = true;
    @api cardIcon = '';
    @api cardTitle = '';
    @api columnWidthsMode = 'fixed';
    @api defaultSortDirection = 'asc';
    @api hideCheckboxColumn = false;
    @api hideTableHeader = false;
    @api maxColumnWidth = 1000;
    @api maxRowSelection = 50;
    @api minColumnWidth = 50;
    @api resizeColumnDisabled = false;
    @api rowNumberOffset = 0;
    @api showCard = false;
    @api showRowNumberColumn = false;
    @api showViewRowAction = false;
    @api suppressBottomBar = false;

    @track emptyOppRows = false;
    
    @wire(getObjectInfo, { objectApiName: OPPORTUNITY_OBJECT })
    getObjectInfo(result) {
        if(result.data){
            console.log('data1: ',result.data);
            const rtis = result.data.recordTypeInfos;
            console.log('rt: ',rtis);
            this.recordTypeId = Object.keys(rtis).find((rti) => rtis[rti].name === 'Structured Finance');
        }
    }
    //fetch picklist options
    @wire(getPicklistValues, {
        recordTypeId: '$recordTypeId',
        fieldApiName: DELIBERATOIBCOMMITTEE
        })    
    wirePickList({ error, data }) {
        this.pickListOptions = undefined;
        if (data) {
            console.log('data: ',data);
            for(var key in data.values){
                this.options.push({label: data.values[key].label, value: data.values[key].value});
            }
            this.pickListOptions = this.options;
            console.log('LV picklist', this.pickListOptions);
        } else if (error) {
            console.log(error);
        }
    }

    //here I pass picklist option so that this wire method call after above method
    _wiredOpportunityData;
    @wire(fetchOpportunitaEsitoIncontro, { pickList: '$pickListOptions'})
    opportunity(wireResult) {
        console.log('chiama wired');
        const {error, data} = wireResult;
        this._wiredOpportunityData = wireResult;
        this.opportunity = data;

        if (data) {
            this.isLoading = false;
            this.opportunity = JSON.parse(JSON.stringify(data));
            console.log('LV this.data', JSON.stringify(this.opportunity));
 
            if(!this.opportunity.length > 0){
                this.emptyOppRows = true;
            }

            this.opportunity.forEach(element => {
                element.pickListOptions = this.pickListOptions;
                console.log('LV ele.pickListOptions', element.pickListOptions);
                element.OwnerName = element.Owner ? element.Owner.Name : '';
                element.AccountName = element.Account ? element.Account.Name : '';
            })
            
            this.lastSavedData = JSON.parse(JSON.stringify(this.opportunity));
            console.log('LV this.lastSavedData', JSON.stringify(this.lastSavedData));

 
        } else if (error) {
            this.opportunity = undefined;
        }
    }

    async handleSave(event) {
        const updatedFields = event.detail.draftValues;
        console.log('LV event.detail', event.detail);
        console.log('LV draftValues ', updatedFields);
    
        // Prepare the record IDs for notifyRecordUpdateAvailable()
        const notifyChangeIds = updatedFields.map(row => { return { "recordId": row.Id } });

        console.log('LV notifyChangeIds' , JSON.stringify(notifyChangeIds));
    
        try {
            
            // Pass edited fields to the updateOpportunity Apex controller
            
            const result = await updateOpportunitaEsitoIncontro({data: updatedFields});
            console.log(JSON.stringify("Apex update result: "+ result));
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Salvataggio dell\'opportunità avvenuto con successo',
                    variant: 'success'
                })
            );
            
            // Refresh LDS cache and wires
            notifyRecordUpdateAvailable(notifyChangeIds);

            // Clear all draft values in the datatable
            this.draftValues = [];
            // Display fresh data in the datatable
            return refreshApex(this._wiredOpportunityData);

        } catch(error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: error.body.message,
                    variant: 'error'
                })
            );
        };
    }
}