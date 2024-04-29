/**
 * @description       : 
 * @author            : alessandro.dinardo@lutech.it
 * @group             : tengroup
 * @last modified on  : 22-01-2024
 * @last modified by  : alessandro.dinardo@lutech.it
 * description        : CR 76756 lwc usato per la modifica e visualizzazione del campo "PTF_RiportafogliazioneTAG__c" di Account
**/
import { LightningElement , api, track,wire} from 'lwc';

//import showToast
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getNdgFromAccount from '@salesforce/apex/AggiornamentoTagNdgController.getNdgFromAccount';
import updateNdgValue from '@salesforce/apex/AggiornamentoTagNdgController.updateNdgValue';
import {getRecord,getRecordNotifyChange,notifyRecordUpdateAvailable} from 'lightning/uiRecordApi';
//AD custom labels
import updateSingleTagSuccess from "@salesforce/label/c.updateSingleTagSuccess";
import updateSingleTagError from "@salesforce/label/c.updateSingleTagError";
import attention from "@salesforce/label/c.attention";
import error from "@salesforce/label/c.error";
import success from "@salesforce/label/c.success";



export default class AggiornaTagNdg extends LightningElement {
    
    @api recordId;
    @track ndgValue='';
    loadedData = false;

    labels = {updateSingleTagSuccess
                ,updateSingleTagError
                ,attention
                ,error
                ,success};

    //@wire(getRecord, { recordId: '$recordId'})
    //record; //AD attualmente non usato per notifyRecordUpdateAvailable
    
    connectedCallback(){
        
        console.log('AD AggiornaTagNdg connectedCallback');
        console.log('AD AggiornaTagNdg recordId : ' , this.recordId);
        //AD prendo l'attuale tag dell'account e lo mostro nella textArea
        getNdgFromAccount({idAccount : this.recordId})
        .then(result=>{

            console.log('AD getNdgFromAccount result : ' , result);
            if(result){
                this.ndgValue = result.toString();
            }
            
        }).catch(function(error){
            console.log('AD getNdgFromAccount error : ' , error);
        }) 
       
    } 
    
    handleChange(event){
        this.ndgValue = event.target.value;
    }

    async handleClick(){

        console.log('AD handleClick');
        console.log('AD handleClick tag inserito : ' , this.ndgValue);
        if(this.recordId){

            try{

                this.loadedData=true;//AD variabile per gestire lo spinner di caricamento
                //console.log('AD handleClick this.recordId : ' , this.recordId);
                let risposta = await this.updateAccount();
                console.log('AD handleClick updateAccount risposta : ' , risposta);

                //await notifyRecordUpdateAvailable([{recordId: risposta}]);//AD attualmente non funzionante
                
                if(risposta != ''){  
                    //this.showToast('Successo!','Modifica del TAG avvenuta con successo , aggiorno la pagina','success')
                    this.showToast(this.labels.success,this.labels.updateSingleTagSuccess,'success')
                    //eval("$A.get('e.force:refreshView').fire();");//AD attualmente non funzionante
                    setTimeout(()=>window.location.reload(),3000);//AD sostituzione per "refreshView"

                }else{
                    //this.showToast('Errore!','Errore durante la modifica del TAG','error')     
                    this.showToast(this.labels.error,this.labels.updateSingleTagError,'error')
                }
                 
                this.loadedData=false;
                
            }catch(error){
                console.log('AD handleClick error : ' , error);
            }
            
        }else{
            console.log('AD record id non presente');
        }
    }

    //AD modifico il tag dell'account
    //this.recordId identificativo dell'account
    //this.ndgValue tag da sostituire
    updateAccount(){

        return new Promise((resolve,reject)=>{
            updateNdgValue({idAccount : this.recordId , ndgValue : this.ndgValue})
            .then(result=>{
                console.log('AD updateNdgValue result : ' , result);
                resolve(result)
          
            }).catch(function(error){
                console.log('AD updateNdgValue error : ' , error);
                reject(error)
            })
        })

    }
    //AD funzione che si occupa di inviare gli alert
    showToast(title,message,variant){
        console.log('AD showToast');

        try{
            const toastEvent = new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            });
            this.dispatchEvent(toastEvent);
        }catch(error){
            console.log('AD showToast error : ' , error);

        }
    }

}