import { api, LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRecord from '@salesforce/apex/ART_AdvancedOrderEditController.getRecord';
import ART_Error from '@salesforce/label/c.ART_Error';
import WHOLESALER from '@salesforce/label/cgcloud.WHOLESALER';
import ART_Basket from '@salesforce/label/c.ART_Basket';
import ORDER_HEADER from '@salesforce/label/cgcloud.ORDER_HEADER';
import ART_CopiaCommissioneDeLabel from '@salesforce/label/c.ART_CopiaCommissioneDeLabel';
import downloadPDF from '@salesforce/apex/ART_AdvancedOrderTabsetController.getPdfFileAsBase64String'; // LV 24/03/2023

import orderDelete from '@salesforce/apex/ART_AdvancedOrderBasketController.orderDelete'; // AL 2024-04-08 - Aggiunta metodo orderDelete della classe ART_AdvancedOrderBasketController

import { CurrentPageReference } from 'lightning/navigation';
import ART_Copy from '@salesforce/label/c.ART_Copy';
import ART_Delete from '@salesforce/label/c.ART_Delete';

export default class ArtAdvancedOrderTabset extends LightningElement() {
    @api objectApiName;
    @api recordId;
    @track showWholesaler = false;
    
    label = {
        ART_Error,
        WHOLESALER,
        ART_Basket,
        ORDER_HEADER,
        ART_CopiaCommissioneDeLabel, // LV 21/03/2023
        ART_Copy,
        ART_Delete,
    }
    // DK START DE-041_042
    @track selectedTab = 'OrderHeader';
    @track isOpenClone = false;

    @track disableCopy = true;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        console.log('DK currentPageReference: ' + JSON.stringify(currentPageReference));
        if (currentPageReference.state.c__selectedTab) {
            this.selectedTab = currentPageReference.state.c__selectedTab;
        }
        if(currentPageReference.state.c__isOpenClone){
            this.isOpenClone = true;
        }
        console.log('DK selectedTab: ' + this.selectedTab);
        console.log('DK isOpenClone: ' + this.isOpenClone);
    }
    // DK END DE-041_042

    connectedCallback() {
        getRecord({recordId:this.recordId}).then(r=>{
            this.showWholesaler = (r["ART_Order_Type__c"]==="T");
        }).catch(e=>{
            let errMessage = (e.message!==undefined ? e.message : (e.body!==undefined && e.body.message!==undefined ? e.body.message : e.toString()));
            const evt = new ShowToastEvent({
                title:this.labelART_Error,
                message:errMessage,
                variant:"error",
                mode:"sticky"
            });
            this.dispatchEvent(evt);
        });
    }

    // LV 24/03/2023 start    
    boolShowSpinner = false;
    pdfString;
    handleDownloadCopiaCommissioneDe() {
        this.boolShowSpinner = true;
        downloadPDF({idRecord: this.recordId }).then(response => {
            setTimeout(() => {
                window.open("/servlet/servlet.FileDownload?file=" + response, "_blank");
            })
 
        }).catch(error => {
            console.log('Error: ' +error.body.message);
        });
    }
    // LV 24/03/2023 end

    handleActive(event) {
        this.selectedTab = event.target.value;
    }
    
    // AL 2024-04-08 -- Aggiunta azione per massive deleta
    callDelete() {
        console.log('in callDelete0');
        let chonenRecordsToDelete =this.template.querySelector("[data-item='orderBasket']");
        chonenRecordsToDelete.actionDeleteChosenRecord();
        console.log('OK');
    }
    // AL 2024-04-08 -- Fine

    @track isClone = false;
    callClone(){
        try {
            console.log('DK this.selectedTab: ' + this.selectedTab);
            this.selectedTab = 'basket';
            this.isClone = true;
            this.sleep(200).then(() => {
                do{
                    console.log('waiting...');
                }while(this.ccbBasketDone === false);
                console.log('DK START callClone');
                this.template.querySelector("[data-item='orderBasket']").handleClone();
            });

        } catch (error) {
            console.log(error);
        }
    }

    handleCcbDone(){
        console.log('DK handleCcbDone');
        if(this.isClone){

            this.template.querySelector("[data-item='orderBasket']").handleClone();
        }
    }

    sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }
}