import { LightningElement,api,track } from 'lwc';

import getRecordNotes from '@salesforce/apex/CheckupListViewController.getRecordNotes';

export default class CheckNotes extends LightningElement {


    @api recordId;
    @api isError = false;
    @api errorMessage;
    @api isEmptyList = false;
    @api isLoading = false;
    @api fieldsToShow;
    @api numberOfRecords;
    @track records = [];

    @track columns = [];

    connectedCallback(){
        this.isLoading = true;
        console.log('RECORDID ',this.recordId);
        console.log('fieldsToShow ', this.fieldsToShow);

         var listColumn = this.fieldsToShow.split(';');
         var obj;
         listColumn.forEach(element => {
             obj = JSON.parse(element);
             console.log('obj.label: '+obj.label+' obj.fieldName: '+obj.fieldName+' type: obj.type: '+ obj.type+' fixedWidth: obj.fixedWidth: '+obj.fixedWidth);
             
            this.columns.push({label: obj.label,fieldName: obj.fieldName, type: obj.type, wrapText: obj.wrapText,hideDefaultActions: obj.hideDefaultActions,fixedWidth:parseInt(obj.fixedWidth)});
         });
         var lastElement = JSON.parse(listColumn[2]);
         /*this.columns.push({label: 'Nota',fieldName: 'id', type: 'text', wrapText: 'true',hideDefaultActions: 'true'});
         this.columns.push({label: 'CreatedDate',fieldName: 'CreatedDate', type: 'date', wrapText: 'false',hideDefaultActions:  'true',fixedWidth:100});
         this.columns.push({label: 'Autore',fieldName: 'CRM_Autore__c', type: 'text', wrapText: 'false',hideDefaultActions:  'true',fixedWidth: 100});*/
         var firstElement = JSON.parse(listColumn[0]);
         var listElementTemp = [];
         getRecordNotes({recordId: this.recordId, numberOfRecords: this.numberOfRecords /*, noteField: firstElement.fieldName*/})
         .then(result => {
                console.log('records ',result);
                /*this.records = result;
                if(this.records.length == 0){
                    this.isEmptyList = true;
                }*/
                result.forEach(element => {
                    console.log('name: '+element[firstElement.fieldName]);
                    if(element[firstElement.fieldName]!=undefined){
                        listElementTemp.push(element);
                    }
                });
            console.log('list post ',listElementTemp);
            console.log('records post ',this.records);
                this.records = listElementTemp.slice(0,this.numberOfRecords);
                if(this.records.length == 0){
                    this.isEmptyList = true;
                }else{
                    this.isLoading = false; 
                }
                console.log('records post 2 ',this.records);
         })
         .catch(error => {
             console.log('ENTRA??');
             this.isError = true;
             this.errorMessage = error.body.message;
             console.log('errore ',this.errorMessage);
            
        });
         
     }
}