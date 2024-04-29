import { LightningElement,track,api, wire } from 'lwc';
import {FlowAttributeChangeEvent, FlowNavigationNextEvent} from 'lightning/flowSupport';
import getAllData from '@salesforce/apex/FrodeTableController.getAllData';

import NumeroCarta from '@salesforce/label/c.frodeTable_CLM_NumeroCarta';
import NomeProdotto from '@salesforce/label/c.frodeTable_CLM_NomeProdotto';
import TipologiaCarta from '@salesforce/label/c.frodeTable_CLM_TipologiaCarta';
import ContoAppoggio from '@salesforce/label/c.frodeTable_CLM_ContoAppoggio';
import DataScadenza from '@salesforce/label/c.frodeTable_CLM_DataScadenza';
import DataApertura from '@salesforce/label/c.frodeTable_CLM_DataApertura';
import TipologiaProfilo from '@salesforce/label/c.frodeTable_CLM_TipologiaProfilo';
import StatoCodiceUtenza from '@salesforce/label/c.frodeTable_CLM_StatoCodiceUtenza';





export default class FrodeTable extends LightningElement {
    @track _output;
    @api title;
    @api caseId;
    @track isRendered;
    @api flow;
    @track data1=[];
    @track data2=[];
    @track flow1;
    @track flow2;
    @track preSelectedRows=["a081X0000034w25QAA"];
    @track showError;
    @api errorMessage;
    
    

    @api
    get output(){
        return this._output;
    }

    columns1 = [
        { label: NumeroCarta, fieldName: 'CRM_Numero_Carta_Hash__c', type: 'text', hideDefaultActions: "true"}, 
        { label: NomeProdotto, fieldName: 'Name', type: 'text',hideDefaultActions: "true"},
        { label: TipologiaCarta, fieldName: 'cardType', type: 'text',hideDefaultActions: "true"},
        { label: ContoAppoggio, fieldName: 'iban', type: 'text',hideDefaultActions: "true"},
        { label: DataScadenza, fieldName: 'CRM_ValidityEndDate__c', type: 'text',hideDefaultActions: "true"}
        
    ];


    columns2 = [
        { label: NomeProdotto, fieldName: 'Name', type: 'text',hideDefaultActions: "true"},
        { label: DataApertura, fieldName: 'FinServ__OpenDate__c', type: 'text',hideDefaultActions: "true"},
        { label: TipologiaProfilo, fieldName: 'CRM_ProfileTypology__c', type: 'text',hideDefaultActions: "true"},
        { label: StatoCodiceUtenza, fieldName: 'CRM_UserCodeStatus__c', type: 'text',hideDefaultActions: "true"},
    ];

    

     connectedCallback(){
         console.log('connected');
        this.isRendered=false;
        this.showError=false;
        getAllData({caseId:this.caseId, flow:this.flow})
        .then(result => {
            
            let tempData =[];
            if(this.flow===1){
                console.log(JSON.stringify(result["prodotti"]));
                result["prodotti"].forEach(element =>{
                
                    this.flow1=true;
                    this.flow2=false;
                    if (element.hasOwnProperty('CRM_BankDebitAccount__c')){
                        element.iban=element.CRM_BankDebitAccount__r.CRM_IBAN__c;
                    }
                    element.cardType=result["mapCardType"][element.RecordType.DeveloperName];
                    tempData.push(element);
                    
                });
                this.data1=tempData;
            }
            

                
                

                
                        
            
            if(this.flow===2){
                this.flow1=false;
                this.flow2=true;
                tempData=result["prodotti"];
                this.data2=tempData;

            }

            if(this.data1.length>0){
                    this.preSelectedRows=[...this.preSelectedRows,this.data1[0].Id];
                    console.log('@@selected1:'+JSON.stringify(this.preSelectedRows));
                
            }

            if(this.data2.length>0){
                this.preSelectedRows=[...this.preSelectedRows,this.data2[0].Id];
                console.log('@@selected1:'+JSON.stringify(this.preSelectedRows));
            
        }
            
           
           
           this.isRendered=true;


        }).catch(error => {
            this.isRendered=true;
            console.log('error: '+error.body.message);
            if(error.body.message.includes('Prodotti vuoti')){
                this.showError=true;
            }
            
        });

    }

    renderedCallback(){
        console.log('@@selected1rend:'+JSON.stringify(this.preSelectedRows));
    }

    

    handleSelection(event){
        if(event.detail.selectedRows.length===0 && this.preSelectedRows.length>0){
            if(this.data1.length>0){
                this.preSelectedRows=[this.data1[0].Id];
                this._output=this.preSelectedRows;
                const attributeChangeEvent = new FlowAttributeChangeEvent('output', this._output);
                this.dispatchEvent(attributeChangeEvent);
            }
            if(this.data2.length>0){
                this.preSelectedRows=[this.data2[0].Id];
                this._output=this.preSelectedRows;
                const attributeChangeEvent = new FlowAttributeChangeEvent('output', this._output);
                this.dispatchEvent(attributeChangeEvent);
            }
            
        }
        else{
            this._output= event.detail.selectedRows.map(item => item.Id);
            const attributeChangeEvent = new FlowAttributeChangeEvent('output', this._output);
            this.dispatchEvent(attributeChangeEvent); 
        }
        
    }

   
}