/**
 * @description       : 
 * @author            : alessandro.dinardo@lutech.it
 * @group             : tengroup
 * @last modified on  : 24-01-2024
 * @last modified by  : alessandro.dinardo@lutech.it
 * description        : CR 76756   del campo "PTF_RiportafogliazioneTAG__c" su tutti gli Account associati a TAG
 *                      aggiorrnare i tag degli account a livello database di salesforce (batch : Batch_AggiornaMassivamenteTag) 
 *                      ed effettuare la sincronizzazione di salesforce analytics tenendo conto dei tempi di attesa della batch
 *                      e della sync  
**/

import { LightningElement, api,track } from 'lwc';
//import showToast
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import executeBatchUpdate from '@salesforce/apex/AggiornaMassivamenteTagController.executeBatchUpdate';
import getBatchJobStatus from '@salesforce/apex/AggiornaMassivamenteTagController.getBatchJobStatus';
import getDateBatchCompleted from '@salesforce/apex/AggiornaMassivamenteTagController.getDateBatchCompleted';
//AD custom labels
import updateTagIntervalDate     from "@salesforce/label/c.updateTagIntervalDate";    
import updateTagStatusBatchJob  from "@salesforce/label/c.updateTagStatusBatchJob";
import updateTagRefreshPage  from "@salesforce/label/c.updateTagRefreshPage";
import updateTagOtherUpdate  from "@salesforce/label/c.updateTagOtherUpdate";
import updateTagSuccess  from "@salesforce/label/c.updateTagSuccess";
import updateTagError   from "@salesforce/label/c.updateTagError";
import updateTagSelectTag from "@salesforce/label/c.updateTagSelectTag";
import attention from "@salesforce/label/c.attention";
import error from "@salesforce/label/c.error";
import success from "@salesforce/label/c.success";


export default class AggiornaMassivamenteTag extends LightningElement {

    @api oldTag;
    @api lastSynch;
    newtag;
    @track statusBatchJob = false;//AD variabile booleana per controllare se la batch ha terminato il suo compito o se sta ancora lavorando 
    @track refreshPage = false;//AD variabile booleana per controllare se la data del job batch è maggiore rispetto alla data dell'ultima sincronizzazione
    @track intervalDate =false;//AD variabile booleana usata per controllare se la modifica viene fatta tra le 22:00 e le 04:00 del mattino
    @track dateBatch;//AD data di completamento batch e punto di riferimento per quando è iniziata la sync
    @track otherUpdate=false;//AD data completamento batch
    @track disableButton = true;//AD bottone modifica cliccabile

    labels = {   updateTagIntervalDate 
                ,updateTagStatusBatchJob 
                ,updateTagRefreshPage 
                ,updateTagOtherUpdate 
                ,updateTagSuccess 
                ,updateTagError  
                ,updateTagSelectTag
                ,attention
                ,error
                ,success};

    async connectedCallback(){
        console.log('AD connectedCallback oldTag :  ' , this.oldTag);
        console.log('AD connectedCallback labels :  ' , JSON.stringify(this.labels));
        this.oldTag='';
        this.lastSynch = new Date(this.lastSynch);//data ultima sincronizzazione
        //console.log('AD connectedCallback lastSynchConverted :  ' , lastSynchConverted);
        console.log('AD connectedCallback lastSynch :  ' , this.lastSynch);

         
        try{

            this.statusBatchJob = await this.checkJobStatus();
            this.refreshPage = await this.dateBatchCompleted();
            this.intervalDate = this.checkCurrentDate();
            this.otherUpdate = this.checkModify();
            //console.log('AD this.statusBatchJob  : ' , this.statusBatchJob );
        
        }catch(error){
            console.log('AD connectedCallback error : ' , error);
        }
        
        console.log('AD connectedCallback this.statusBatchJob  : ' , this.statusBatchJob );       
        console.log('AD connectedCallback this.intervalDate  : ' , this.intervalDate );       
        console.log('AD connectedCallback this.otherUpdate  : ' , this.otherUpdate );       
        
        //AD rendo cliccabile il bottone "modifica"
        if(this.intervalDate&&this.statusBatchJob&&this.otherUpdate){ 
            console.log('AD bottone Modifica cliccabile'); 
            this.disableButton = false;
        }else{
            console.log('AD bottone Modifica disabilitato');
        }

        console.log('AD disableButton ' , this.disableButton);
        if(!this.intervalDate){
            //this.showToast('Attenzione!','Non è possibile effettuare la modifica tra le 22:00 e le 04:00 del mattino.','warning');
            
            this.showToast(this.labels.attention,this.labels.updateTagIntervalDate,'warning');
            return;
        } 

        if(!this.statusBatchJob){
            //this.showToast('Errore!','Modifica in corso, riprova più tardi per eseguire il prossimo.','error');
            this.showToast(this.labels.error,this.labels.updateTagStatusBatchJob,'error');
            return;
        } 
 

        if(!this.otherUpdate){
            //this.showToast('Errore!','Attenzione non è possibile effettuare la modifica è in corso la sincronizzazione.','error');
            this.showToast(this.labels.error,this.labels.updateTagOtherUpdate,'error');
            return;
        } 

        
        
    }

    handleFilter(event){
        this.newtag = event.target.value;
    }

    //AD bottone modifica 
    async handleClick(){

        console.log('AD handleClick newtag : ' , this.newtag);
        console.log('AD handleClick oldTag : ' , this.oldTag);
        try{

            this.statusBatchJob = await this.checkJobStatus();
            this.refreshPage = await this.dateBatchCompleted();
            this.intervalDate = this.checkCurrentDate();
            this.otherUpdate = this.checkModify();
            //console.log('AD this.statusBatchJob  : ' , this.statusBatchJob );
        
        }catch(error){
            console.log('AD showToast error : ' , error);
        }
        
        console.log('AD this.statusBatchJob  : ' , this.statusBatchJob );       
        console.log('AD this.refreshPage  : ' , this.refreshPage );       
        console.log('AD this.intervalDate  : ' , this.intervalDate );       
        console.log('AD this.otherUpdate  : ' , this.otherUpdate );       
        
        /** */
        if(!this.intervalDate){
            //this.showToast('Attenzione!','Non è possibile effettuare la modifica tra le 22:00 e le 04:00 del mattino.','warning');
            this.showToast(this.labels.attention,this.labels.updateTagIntervalDate,'warning');
            return;
        } 

        if(!this.statusBatchJob){
            //this.showToast('Errore!','Modifica in corso, riprova più tardi per eseguire il prossimo.','error');
            this.showToast(this.labels.error,this.labels.updateTagStatusBatchJob,'error');
            return;
        } 

        if(!this.refreshPage){
            //this.showToast('Attenzione!','Ricarico la pagina per aggiornare la data di sincronizzazione.','warning');
            this.showToast(this.labels.attention,this.labels.updateTagRefreshPage,'warning');
            setTimeout(()=>window.location.reload(),3000);
            return;
        } 

        if(!this.otherUpdate){
            //this.showToast('Errore!','Attenzione non è possibile effettuare la modifica è in corso la sincronizzazione.','error');
            this.showToast(this.labels.error,this.labels.updateTagOtherUpdate,'error');

            return;
        }

        //AD se l'utente ha selezionato il tag da modificare ed è diverso da NULL
        //chiamo il metodo apex executeBatchUpdate passandogli il vecchio e il nuovo tag da aggiornare
        //oldTag valore vecchio da modificare
        //newtag nuovo valore 
        if(this.oldTag && this.oldTag != 'null'){
            console.log('AD eseguo la batch di update');

            /** */
            executeBatchUpdate({oldTag:this.oldTag,newTag:this.newtag}).then(result=>{
                console.log('AD executeBatchUpdate result : ' , result);
                if(result!='errore'){
                   //this.showToast('Successo!','Modifica in corso , attendere il giorno successivo per eseguire il prossimo.','success'); 
                   this.showToast(this.labels.success, this.labels.updateTagSuccess,'success'); 
                   //AD rendo non cliccabile il bottone "modifica"
                    this.disableButton = true;

                }
            }).catch(error=>{
                console.log('AD executeBatchUpdate error : ' , error);
                //this.showToast('Attenzione!','Errore durante la modifica.','error');
                this.showToast(this.labels.attention,this.labels.updateTagError,'error');
            }).finally(()=>{
                console.log('AD executeBatchUpdate finally');
                
            })
        }else{
            console.log('AD selezionare oldTag');
            //this.showToast('Errore!','Attenzione selezionare un TAG prima di effettuare la modifica.','error');
            this.showToast(this.labels.error,this.labels.updateTagSelectTag,'error');
            //window.location.reload();

        }
        

    }

    //AD l'utente non può effettuare la modifica tra le 22:00 e le 04:00 del mattino
    checkCurrentDate(){
        console.log('AD checkCurrentDate ');

        let risposta = false;
        
        //let testData ='2024-02-08T22:00:00.000Z';//ad test per entrare nella condizione
        //let testDataConversion = new Date(testData);

        const dateNow = new Date();
        const startDate = new Date(dateNow.getFullYear(),dateNow.getMonth(),dateNow.getDate(),22,0,0);

        const nextDay = new Date(dateNow);
        nextDay.setDate(dateNow.getDate()+1);
        const endDate = new Date(nextDay.getFullYear(),nextDay.getMonth(),nextDay.getDate(),4,0,0); 
        //console.log('AD checkCurrentDate dateNow : ' , dateNow);
        //console.log('AD checkCurrentDate startDate : ' , startDate);
        //console.log('AD checkCurrentDate endDate : ' , endDate);
        if(dateNow >= startDate && dateNow <= endDate){
            console.log('AD checkCurrentDate non è possibile effettuare sinc in questo orario');
            risposta = false;
        }else{
            risposta=true;
            console.log('AD checkCurrentDate è possibile effettuare sinc  ');

        }

        return risposta;
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

    //AD funzione checkJobStatus controlla lo stato della batch
    //true funzione terminata
    //false sta lavorando ancora
    checkJobStatus(){

        return new Promise((resolve,reject)=>{
            getBatchJobStatus().then(result=>{
                //console.log('AD getBatchJobStatus result : ' , result);
                resolve(result);
            }).catch(error=>{
                console.log('AD getBatchJobStatus error : ' , error);
                reject(error);
            })
        })
        
    }

    //AD 
    //se l'utente effettua una nuova modifica bisogna controllare se la data corrente rientra o meno nel tempo
    //di esecuzione della sync aggiungo 5 ore alla data di completamento batch per avere una stima della durata del processo di sync
    checkModify(){
        console.log('AD checkModify');

        console.log('AD checkModify this.dateBatch : ' , this.dateBatch);
        let risposta  = false 
        this.dateBatch.setHours(this.dateBatch.getHours()+5);
        const dateNow = new Date();
        console.log('AD checkModify this.dateBatch + 5 ore : ' , this.dateBatch);
        
        console.log('AD checkModify dateNow : ' , dateNow);
        //la sync è ancora in corso 
        if(dateNow<this.dateBatch){
            console.log('AD checkModify modifica no possibile è in corso la sync');
            risposta =false;
        }else{
            //la sync è terminata in corso 
            console.log('AD checkModify modifica possibile');
            risposta = true
        }

        return risposta
    }

    //AD controllo se la data della batch è maggiore rispetto alla data di sincronizzazione
    dateBatchCompleted(){
        console.log('AD getDateBatchCompleted');
        let risposta = false;
        return new Promise((resolve,reject)=>{
            getDateBatchCompleted().then(result=>{
                //console.log('AD getBatchJobStatus result : ' , result);
                this.dateBatch = new Date(result);//data completamento batch
                let lastSynch = new Date(this.lastSynch);//data ultima sincronizzazione
                console.log('AD getDateBatchCompleted dateBatch : ' , this.dateBatch);
                console.log('AD getDateBatchCompleted lastSynch : ' , lastSynch);
                
                //se la data di completamento batch è più grande della sync 
                //vuoldire che il componente non ha ancora ricevuto la data di sync
                //aggiornata (bisogna ricaricare la pagina)
                if(this.dateBatch>lastSynch){
                    console.log('AD continuo a bloccare');
                    risposta = false;
                }else{
                    console.log('AD data batch ok');
                    risposta = true;

                }
                resolve(risposta);
            }).catch(error=>{
                 console.log('AD getBatchJobStatus error : ' , error);
                reject(error);
            })
        }) 
    }

    
}