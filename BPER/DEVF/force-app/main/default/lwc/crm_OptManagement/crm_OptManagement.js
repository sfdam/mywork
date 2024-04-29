import { LightningElement, api, track } from 'lwc';
import getOpportunities from '@salesforce/apex/CRM_OptManagement.getOpportunities';
import getCointestazioni from '@salesforce/apex/CRM_OptManagement.getCointestazioni';

export default class Crm_OptManagement extends LightningElement
{
    @track isLoading = true;
    @track data = []
    columns =
    [
        {
            label: 'NOME',
            fieldName: 'nameUrl',
            type: 'url',
            typeAttributes: {label: { fieldName: 'name' } },
            initialWidth: 175
        },
        {
            label: 'OGGETTO',
            fieldName: 'oggetto',
            type: 'text',
            initialWidth: 175
        },{
            label: 'NOME ACCOUNT',
            fieldName: 'accountName',
            type: 'text',
            initialWidth: 175
        },
        {
            label: 'ORIGINE',
            fieldName: 'origine',
            type: 'text',
            initialWidth: 175
        },
        {
            label: 'BISOGNO',
            fieldName: 'bisogno',
            type: 'text',
            initialWidth: 175
        },
        {
            label: 'DATA SCADENZA',
            fieldName: 'dataScadenza',
            type: 'datetime',
            initialWidth: 175
        },
        {
            label: 'ESITO CONTATTO',
            fieldName: 'esitoContatto',
            type: 'text',
            initialWidth: 175
        },
        {
            label: 'ASSEGNATARIO',
            fieldName: 'assegnatario',
            type: 'text',
            initialWidth: 175
        }
    ];
    @api recordId;

    connectedCallback()
    {
        getOpportunities({accountId : this.recordId})
        .then((result) => {

            console.log(result);
            result = result.map(row => ({
                Id: row.Id,
                nameUrl: '/' + row.Id,
                name: row.Name,
                accountName: row.Account.Name,
                origine: row.CRM_Canale__c,
                oggetto:row.CRM_Oggetto__c,
                bisogno: row.CRM_Bisogno__c,
                dataScadenza: row.CloseDate,
                esitoContatto: row.CRM_EsitoContatto__c,
                assegnatario: row.CRM_AssegnatarioFormulaNew__c
            }));
            this.data = result
            //console.log(result);

            getCointestazioni({accountId : this.recordId})
            .then((result) => {

                result = result.map(row => ({
                    Id: row.Id,
                    nameUrl: '/' + row.Id,
                    name: row.Name,
                    accountName: row.Account.Name,
                    origine: row.CRM_Canale__c,
                    oggetto:row.CRM_Oggetto__c,
                    bisogno: row.CRM_Bisogno__c,
                    dataScadenza: row.CloseDate,
                    esitoContatto: row.CRM_EsitoContatto__c,
                    assegnatario: row.CRM_AssegnatarioFormulaNew__c
                }));

                this.data = this.data.concat(result)
                this.isLoading = false
                //console.log(result);
            })
            .catch((error) => {
                console.log(error);
            })
        })
        .catch((error) => {
            console.log(error);
        })
    }
    
    refreshClick(){
        this.connectedCallback();
    }
}