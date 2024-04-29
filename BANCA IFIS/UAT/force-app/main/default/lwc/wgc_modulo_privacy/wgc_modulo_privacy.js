import { LightningElement,api,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadStyle } from 'lightning/platformResourceLoader';
import cssPrivacyModalLWC from '@salesforce/resourceUrl/cssPrivacyModalLWC';
import getDefaultData from '@salesforce/apex/WGC_PrivacyPersonaGiuridica.getDefaultData';
import getText from '@salesforce/apex/WGC_PrivacyPersonaGiuridica.getText';
import getReferentiEsecutori from '@salesforce/apex/WGC_PrivacyPersonaGiuridica.getReferentiEsecutori';
import saveAccountPrivacy from '@salesforce/apex/WGC_PrivacyPersonaGiuridica.saveAccountPrivacy';
import SaveRecord from '@salesforce/apex/WGC_PrivacyPersonaGiuridica.SaveRecord';

export default class Wgc_modulo_privacy extends LightningElement {

    @api recordId;
    @api isAccount;
    @track rec = {};
    
    @track masterTitle = 'Privacy Persona Giuridica';
    sezione1Title = 'INFORMATIVA PRIVACY';
    sezione2Title = 'INFORMATIVA PRIVACY RELATIVA ALLE ATTIVITÀ DI TRASFERIMENTO DEI FONDI SVOLTA DALLA SWIFT';
    sezione3Title = 'INFORMATIVA PRIVACY RELATIVA ALLA REGISTRAZIONE DELLE TELEFONATE';
    sezione4Title = 'INFORMATIVA PRIVACY RELATIVA ALL’UTILIZZO DELLE APPLICAZIONI MOBILE';
    sezione5Title = 'INFORMATIVA AI SENSI DELL’ART. 5 DEL CODICE DEONTOLOGICO SUI SISTEMI DI INFORMAZIONI CREDITIZIE';
    sezione6Title = 'CONSENSO';
    notaConsensi = 'rilevazione dei gusti, delle preferenze, delle abitudini, dei bisogni e delle scelte di consumo dell’Interessato (c.d. profilazione) (solo qualora l’Interessato sia una persona fisica)';
    notaConsensi2 = "promozione ed offerta di prodotti/servizi della Banca o ricerche di mercato volte a rilevare il grado di soddisfazione dell'Interessato, attraverso modalità c.d. automatizzate e tradizionali";
    notaConsensi3 = "promozione ed offerta di prodotti/servizi di terzi, attraverso modalità c.d. automatizzate e tradizionali";
    notaConsensi4 = "comunicazione di dati personali a terzi per promozione ed offerta di prodotti/servizi della Banca o ricerche di mercato volte a rilevare il grado di soddisfazione dell'Interessato, attraverso modalità c.d. automatizzate e tradizionali";
    notaConsensi5 = "comunicazione di dati personali a terzi per promozione ed offerta di prodotti/servizi di terzi medesimi, attraverso modalità c.d. automatizzate e tradizionali";
    notaConsensi6 = "Il sottoscritto dichiara di voler ricevere le comunicazioni promozionali (di cui ai suddetti punti da 2 a 5) esclusivamente attraverso le modalità tradizionali (es. posta ordinaria, telefonate con operatore) e non quelle automatizzate (es. e-mail, SMS, MMS, fax, telefonate preregistrate):";
    notaConsensi7 = "Solo modalità tradizionali";

    @track esecutore;
    @track showSpinner;
    sezione1;
    sezione2;
    sezione3;
    sezione4;
    sezione5;
    sezione6;
    listaEsecutori;

    connectedCallback(){   
        loadStyle(this, cssPrivacyModalLWC); 
        this.initialize();        
    }

    enableSpinner(){
        this.showSpinner = true;
    }

    disableSpinner(){
        this.showSpinner = false;
    }

    get listaEsecutoriSize(){
        return this.listaEsecutori.length > 0;
    }

    initialize(){
        this.enableSpinner();
        console.log("recordId: "+this.recordId);
        console.log("isAccount: "+this.isAccount);

        getDefaultData({
            "recordId" : this.recordId
        }).then(result => {
            this.rec = result;
            console.log("rec: "+JSON.stringify(result));
            if(result.NaturaGiuridica__c == "PF"){
                this.masterTitle = "Privacy Persona Fisica";
            } else if(result.WGC_Esecutore_Firmatario_Privacy__c != null &&  result.WGC_Esecutore_Firmatario_Privacy__c != undefined){
                //Imposto di default l'esecutore selezionato
                this.esecutore = result.WGC_Esecutore_Firmatario_Privacy__c;  
            }

            this.handleRadioButton(result);                        
            return getText();              
           
        }).then(result => {
            var risposta = result;
            console.log('@@@ risposta ' , risposta);
            this.sezione1 = risposta.Sezione_1__c;
            this.sezione2 = risposta.Sezione_2__c;
            this.sezione3 = risposta.Sezione_3__c;
            this.sezione4 = risposta.Sezione_4__c;
            this.sezione5 = risposta.Sezione_5__c;
            this.sezione6 = risposta.Sezione_6__c;   
            
            if (this.isAccount){
                return getReferentiEsecutori({"accountId" : this.recordId});
            }

        }).then(risposta => {
            if (risposta!=undefined){
                if(risposta.success){
                    var lista = [];
                    risposta.data.forEach((item, index) =>{
                        lista.push({
                            label: item.Contact.Name,
                            value: item.Contact.Name
                        });                       
                    });
    
                    console.log('@@@ listaEsecutori ' , lista);
                    this.listaEsecutori = lista;
                } else{
                    console.log('@@@ risposta.message ' , risposta.message);
                }
            }            
        }).finally(() => {
            this.disableSpinner();            
        })
        .catch(err => {
            console.log('@@@ err ' , err);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Errore',
                    message: err.message,
                    variant: 'error'
                })
            );

            this.close();
        });  
    }

    handleRadioButton (result){
        if (result.ConsensoAllaProfilazione__c){
            this.rec.consensoProfilazioneTrue = true;
        }else {
            this.rec.consensoProfilazioneFalse = true;
        }

        if (result.ConsensoProdottiBancaRicercheMercato__c){
            this.rec.ConsensoProdottiBancaRicercheMercatoTrue = true;
        }else {
            this.rec.ConsensoProdottiBancaRicercheMercatoFalse = true;
        }
        
        if (result.ConsensoProdottiSocietaTerze__c){
            this.rec.ConsensoProdottiSocietaTerzeTrue = true;
        }else {
            this.rec.ConsensoProdottiSocietaTerzeFalse = true;
        }

        if (result.ConsensoAttivitaPromRicercheMercato__c){
            this.rec.ConsensoAttivitaPromRicercheMercatoTrue = true;
        }else {
            this.rec.ConsensoAttivitaPromRicercheMercatoFalse = true;
        }

        if (result.ConsensoAttivitaPromozionaleTerzi__c){
            this.rec.ConsensoAttivitaPromozionaleTerziTrue = true;
        }else {
            this.rec.ConsensoAttivitaPromozionaleTerziFalse = true;
        }

        if (result.ConsensoSoloModalitaTradizionali__c){
            this.rec.ConsensoSoloModalitaTradizionaliTrue = true;
        }else {
            this.rec.ConsensoSoloModalitaTradizionaliFalse = true;
        }
    }

    close(){         
        this.dispatchEvent(new CustomEvent('closeprivacymodal', { bubbles: true, composed: true, detail : { open: false } }));
    }

    changeEsecutore(event){       
       this.esecutore = event.target.value;
    }

    onGroup (event){
		var selected = event.target.label;
		var nm = event.target.name;
        console.log('@@@ selected ' , selected);

        if(selected == 'Acconsento' || selected == 'Si'){
            selected = true;
        }

        if(selected == 'Non Acconsento' || selected == 'No'){
            selected = false;
        }
      
        console.log('@@@ nm ' , nm);
        console.log('@@@ selected ' , selected);
        let tmp = ''+nm;
        this.rec[tmp] = selected;    
    }
    
    saveRecord(event){
        event.preventDefault();
        this.enableSpinner();
        
        SaveRecord({
            "recordId" : this.recordId,
            "record" : JSON.stringify(this.rec)
        }).then(risposta => {
            //Evento per aggiornare la info di account
            this.dispatchEvent(
                new CustomEvent('refreshcontact', { bubbles: true, composed: true, detail : { success: true} })
            );        

            if(risposta.success){
                const evt = new ShowToastEvent({
                    title: 'Successo!',
                    message: "Salvataggio avvenuto con successo",
                    variant: 'success',
                    mode: 'pester'
                });
    
                this.dispatchEvent(evt); 

                //Lancio evento per componente documentale                
                this.dispatchEvent(new CustomEvent('privacy', { bubbles: true, composed: true, detail : { success: true} }));
               
            } else{
                const evt = new ShowToastEvent({
                    title: 'Errore!',
                    message: risposta.message,
                    variant: 'error'                    
                });

                this.dispatchEvent(evt)

                //Lancio evento per componente documentale
                this.dispatchEvent(new CustomEvent('privacy', { bubbles: true, composed: true, detail : { success: false} }));
            }

        }).finally(() => {
            this.disableSpinner();      
            this.close();       
        })
        .catch(err => {
            console.log('@@@ err ' , err);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Errore',
                    message: err.message,
                    variant: 'error'
                })
            );

            this.close();
        }); 		
    }

    saveRecordWithEsecutore(event){
        event.preventDefault();
        this.enableSpinner();

        saveAccountPrivacy({
			"accountId" : this.recordId,
			"record" : JSON.stringify(this.rec),
			"esecutore" : this.esecutore
		}).then(response => {
            var risposta = response;

            //Evento per aggiornare la info di account
            this.dispatchEvent(
                new CustomEvent('refreshprivacy', { bubbles: true, composed: true, detail : { success: true} })
            ); 

            if(risposta.success){
                const evt = new ShowToastEvent({
                    title: 'Successo!',
                    message: "Salvataggio avvenuto con successo",
                    variant: 'success',
                    mode: 'pester'
                });
    
                this.dispatchEvent(evt); 
               
            } else{
                const evt = new ShowToastEvent({
                    title: 'Errore!',
                    message: risposta.message,
                    variant: 'error'                    
                });

                this.dispatchEvent(evt)
            }
            
        }).finally(() => {
            this.disableSpinner(); 
            this.close();           
        })
        .catch(err => {
            console.log('@@@ err ' , err);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Errore',
                    message: err.message,
                    variant: 'error'
                })
            );

            this.close();
        });  
    }
}