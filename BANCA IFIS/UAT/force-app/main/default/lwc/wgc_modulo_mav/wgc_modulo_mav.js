import { LightningElement,api,track } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import { loadStyle } from 'lightning/platformResourceLoader';
import cssModuloMavLWC from '@salesforce/resourceUrl/cssModuloMavLWC';
import getMAV from '@salesforce/apex/WGC_ModuloAdeguataVerifica.getMAV';
import getNazioni from '@salesforce/apex/WGC_ModuloAdeguataVerifica.getselectOptions_Nazione';
import getProvince from '@salesforce/apex/WGC_ModuloAdeguataVerifica.getselectOptions_Province';
import getDatiMavAccount from '@salesforce/apex/WGC_ModuloAdeguataVerifica.getDatiMavAccount';
import getProfilo from '@salesforce/apex/WGC_ModuloAdeguataVerifica.getProfilo';
import getScopoFactoring from '@salesforce/apex/WGC_ModuloAdeguataVerifica.getScopoFactoring';
import getScopoFinanziamenti from '@salesforce/apex/WGC_ModuloAdeguataVerifica.getScopoFinanziamenti';
import getScopoServiziBancari from '@salesforce/apex/WGC_ModuloAdeguataVerifica.getScopoServiziBancari';
import getNaturaCreditiErariali from '@salesforce/apex/WGC_ModuloAdeguataVerifica.getNaturaCreditiErariali';
import SaveRecord from '@salesforce/apex/WGC_ModuloAdeguataVerifica.SaveRecord';
import ERR_PAESERELAZIONI from '@salesforce/label/c.WGC_Err_PaeseRelazioni_MAV';
 
export default class Wgc_modulo_mav extends LightningElement {

    @api accountId;
    @api tipologiaMAV;
    @track showSpinner = false;

    @track modulo = {}; 
    @track infoMav = {};
    nazioni;
    nazioniSenzaItalia;
    province;    
    profilo;
    saveReferenti;

    @track scopoFactoring;
    @track scopoFinanziamenti;
    @track scopoServiziBancari;
    @track errorSezione1;
    @track errorSezione2;
    @track errorScopo;
    @track errorCreditiErariali = false;
    @track errorPaeseCasaMadre = false;
    @track errorPaeseSvolgimentoAttivitaPrevalente = false;
    @track errorProvinciaSvolgimentoAttivitaPrevalente = false;

    constructor() {
        super();       
        this.addEventListener('handletitolareeffettivo', this.handleSaveTitolareEffettivo.bind(this));   
    }

    connectedCallback(){   
        loadStyle(this, cssModuloMavLWC);  
        this.initialize();           
    }

    enableSpinner(){
        this.showSpinner = true;
    }

    disableSpinner(){
        this.showSpinner = false;
    }

    get isCreditiCommerciali(){
        return this.tipologiaMAV == 'CC';
    }

    get naturaFactoring(){
        return !this.modulo.Natura_Factoring__c;
    }

    get naturaFinanziamenti(){
        return !this.modulo.Natura_Finanziamenti__c;
    }

    get naturaServiziBancari(){
        return !this.modulo.Natura_Servizi_Bancari__c;
    }

    get disableTextArea(){
        return this.modulo.Natura_Crediti_Erariali__c != 'Altro';
    }

    get daCompilare(){
        return (this.modulo.Altro_Crediti_Erariali__c == undefined || this.modulo.Altro_Crediti_Erariali__c == '') && this.modulo.Natura_Crediti_Erariali__c == 'Altro';
    }

    get origineFondi1(){
        if (this.modulo.OrigineFondi1__c == true){
            return true;
        }else {
            return false;
        }       
    }

    get origineFondi1False(){
        if (this.modulo.OrigineFondi1__c == false){
            return true;
        }else {
            return false;
        }           
    }

    get origineFondi2(){
        if (this.modulo.OrigineFondi2__c == true){
            return true;
        }else {
            return false;
        }       
    }

    get origineFondi2False(){
        if (this.modulo.OrigineFondi2__c == false){
            return true;
        }else {
            return false;
        }           
    }

    get origineFondi3(){
        if (this.modulo.OrigineFondi3__c == true){
            return true;
        }else {
            return false;
        }       
    }

    get origineFondi3False(){
        if (this.modulo.OrigineFondi3__c == false){
            return true;
        }else {
            return false;
        }           
    }

    get origineFondi4(){
        if (this.modulo.OrigineFondi4__c == true){
            return true;
        }else {
            return false;
        }       
    }

    get origineFondi4False(){
        if (this.modulo.OrigineFondi4__c == false){
            return true;
        }else {
            return false;
        }           
    }
    

    get compilaOrigineFondiAltro(){
        return (this.modulo.OrigineFondiAltro__c == null || this.modulo.OrigineFondiAltro__c == '') && this.modulo.OrigineFondi4__c == true;
    }

    get classSpecificaAltro(){
        return 'label-fix ' + (this.modulo.OrigineFondiAltro__c == null && this.modulo.OrigineFondi4__c == true ? 'error' : ' ');
    }

    initialize(){
        this.enableSpinner();
        console.log('ACCOUNT ID MODULO MAV',this.accountId);
        console.log('TIPOLOGIA MAV',this.tipologiaMAV);
        getMAV({accountId : this.accountId}).then(result => {            
            var risposta = result;
            console.log('@@@ risposta ' , risposta);
            if(risposta != null || risposta != undefined){
                this.modulo =  risposta;
            }
        });

        this.caricaNazioni();
        this.caricaProvince();
        this.getProfile();
        this.getDatiAccount();        
    }

    caricaNazioni() {
        console.log("carica nazioni");
        getNazioni().then(result => {            
            if(result){
                var allValues = result;
                
				var opts = [];
                var optsBis = [];  

                for (var k in allValues) {
                    opts.push({
                        label: k,
                        value: k
                    });

					if (k != 'ITALIA') {
						optsBis.push({
                        label: k,
                        value: k
						});
					}
                }

                console.log("nazioni",opts);
                this.nazioni =  opts;
                this.nazioniSenzaItalia = optsBis;	
			}
        });
    }

	caricaProvince() {
        console.log("carica province");
        getProvince().then(result => {            
            if(result){
				var allProvince = result;

				var prv = [];               
				
                for (var k in allProvince) {
                    prv.push({
                        label: allProvince[k],
                        value: k
                    });
                }

                this.province =  prv;
			}			 
		});		
    }

    getProfile(){
        console.log("carica profilo");
        getProfilo().then(result => {
            if (result){
                var risposta = result;
                if(risposta != null || risposta != undefined){
                   this.profilo = risposta;
                }
            }            
        });
    }

    getDatiAccount(){
        getDatiMavAccount({accountId : this.accountId}).then(result => {
            if (result){
                var risposta = result;
                console.log('@@@ recuperaDatiMavAccount ' , risposta);
                if(risposta != null || risposta != undefined){
					this.infoMav =  risposta;
                }

                let profilo = this.profilo;
                let tipologiaMAV = this.tipologiaMAV;
                if (tipologiaMAV == 'CC'){
                    this.caricaScopiRapporto();
                }else if (tipologiaMAV == 'CE') {
                    this.caricaNaturaCreditiErariali();
                }
            }            
        });
    }

    caricaScopiRapporto() {       	
        var optsScopoFactoring=[];
        var optsScopoFinanziamenti=[];
        var optsScopoServiziBancari=[];

        var modulo = this.modulo;
        
        getScopoFactoring().then(result => {            

			var scopo = result;
            for(var a in scopo){
                optsScopoFactoring.push({label: scopo[a], value: a, selected: (a == modulo.Scopo_Factoring__c) ? true : false});
            }

            this.scopoFactoring =  optsScopoFactoring;
            return getScopoFinanziamenti();
        }).then(result => {            

            var scopo = result;
            for(var a in scopo){
                optsScopoFinanziamenti.push({label: scopo[a], value: a, selected: (a == modulo.Scopo_Finanziamenti__c) ? true : false});
            }
            
            this.scopoFinanziamenti = optsScopoFinanziamenti;
            return getScopoServiziBancari();
        }).then(result => {           

            var scopo = result;

            for(var a in scopo){
                optsScopoServiziBancari.push({label: scopo[a], value: a, selected: (a == modulo.Scopo_Servizi_Bancari__c) ? true : false});
            }
            
            this.scopoServiziBancari = optsScopoServiziBancari;
            this.disableSpinner();
        })
    }

    caricaNaturaCreditiErariali(){
        var modulo = this.modulo;
        var optsNaturaCreditiErariali=[];
        
        getNaturaCreditiErariali().then(result => {
            var scopo = result;

            for(var a in scopo){
                optsNaturaCreditiErariali.push({label: scopo[a], value: a, selected: (a == modulo.Scopo_Factoring__c) ? true : false});
            }
            
			this.naturaCreditiErariali = optsNaturaCreditiErariali;
			if (modulo !=undefined && modulo.Natura_Crediti_Erariali__c == undefined) {
				this.modulo.Natura_Crediti_Erariali__c = 'Cessione di crediti fiscali'; 
            }

            this.disableSpinner();
        })  
    }
    
    close(){         
        this.dispatchEvent(new CustomEvent('modalmav', { bubbles: true, composed: true, detail : { open: false } }));
    }

    onChangeToggle(event){
        var value = event.target.checked;
		var name = event.target.name;
		this.modulo[name] = value;		
		if (!value){
            this.modulo['Scopo'+name.substring(6,name.length)] = '';
        }	
        
        console.log("modulo changeToogle",JSON.stringify(this.modulo));
    }

    onChangePicklist(event){
        var value = event.target.value;
		var name = event.target.dataset.id;
        this.modulo[name] = value;		
        console.log("modulo changePicklist",JSON.stringify(this.modulo));
    }

    onChangeNaturaCreditiErariali(event){
		var value = event.target.value;
		var name = event.target.dataset.id;
        this.modulo[name] = value;			
		if (value != 'Altro') {
            this.modulo['Altro_Crediti_Erariali__c'] = '';			
        }
        console.log("modulo changeNaturaCrediti",JSON.stringify(this.modulo));
    }
    
    onChangeTextNaturaCreditiErariali(event){
        var value = event.target.value;
		var name = event.target.dataset.id;
        this.modulo[name] = value;
        console.log("modulo changeTextNaturaCrediti",JSON.stringify(this.modulo));
    }

    onChangeAltro(event){
        var value = event.target.value;
		var name = event.target.name;
        this.modulo[name] = value;
        console.log("modulo changeAltro",JSON.stringify(this.modulo));
    }

    onGroup(event){
        var selected = event.target.label;
		var nm = event.target.name;
		if(selected == "Si"){
			selected = true;
		}else {
            selected = false;
        }
		
		('OrigineFondi1__c' == nm && selected) ? this.modulo.OrigineFondi1__c =  true : this.modulo.OrigineFondi1__c =  false;
		('OrigineFondi2__c' == nm && selected) ? this.modulo.OrigineFondi2__c =  true : this.modulo.OrigineFondi2__c =  false;
		('OrigineFondi3__c' == nm && selected) ? this.modulo.OrigineFondi3__c =  true : this.modulo.OrigineFondi3__c =  false;
        ('OrigineFondi4__c' == nm && selected) ? this.modulo.OrigineFondi4__c =  true : this.modulo.OrigineFondi4__c =  false;
        
		if ('OrigineFondi4__c' != nm){
            this.modulo.OrigineFondiAltro__c = '';
        }	
        
        console.log("modulo onGroup",JSON.stringify(this.modulo));
    }

    onChangePaeseCasaMadre(event){
        this.infoMav.PaeseCasaMadre__c = event.target.value;
	}

	onChangePaeseSvolgimentoAttivitaPrevalente(event){
        this.infoMav.PaeseSvolgimentoAttivitaPrevalente__c = event.target.value;
	}

	onChangeProvinciaSvolgimentoAttivitaPrevalente(event){
		this.infoMav.ProvinciaSvolgimentoAttivitaPrevalente__c = event.target.value;
    }

    onChangePaeseRelazioni1(event){       
		this.infoMav.PaeseRelazioni1__c =  event.target.value;		
    }

    onChangePaeseRelazioni2(event){       
		this.infoMav.PaeseRelazioni2__c =  event.target.value;		
    }

    onChangePaeseRelazioni3(event){       
		this.infoMav.PaeseRelazioni3__c =  event.target.value;		
    }
    
    convalidaDati(){
        var modulo = this.modulo;
        console.log("convalida dati: ",JSON.stringify(modulo));
		var tipologiaMAV = this.tipologiaMAV;

		if ( tipologiaMAV == 'CC') {
			if ((modulo.Natura_Factoring__c && (modulo.Scopo_Factoring__c == undefined || modulo.Scopo_Factoring__c == '' )) ||
				(modulo.Natura_Finanziamenti__c && (modulo.Scopo_Finanziamenti__c == undefined || modulo.Scopo_Finanziamenti__c == '' )) ||
				(modulo.Natura_Servizi_Bancari__c && (modulo.Scopo_Servizi_Bancari__c == undefined || modulo.Scopo_Servizi_Bancari__c == '' ))) {
					this.errorSezione1 =  true;
					this.errorScopo = 'Compilare la selezione corrispondente alla sezione';
					return false;
			} else if (!modulo.Natura_Factoring__c && !modulo.Natura_Finanziamenti__c && !modulo.Natura_Servizi_Bancari__c) {
				this.errorSezione1 =  true;
				this.errorScopo = 'Compilare almeno una campo di questa sezione';
				return false;
			} else {
				this.errorSezione1 = false;
			}
		}  else if (tipologiaMAV == 'CE') {
			if (modulo.Natura_Crediti_Erariali__c == 'Altro' && (modulo.Altro_Crediti_Erariali__c == '' || modulo.Altro_Crediti_Erariali__c == undefined)) {
				this.errorCreditiErariali =  true;
				this.errorScopo =  'Compilare il campo \'Altro\'';
				return false;
			} else {
				this.errorCreditiErariali =  false;
			}
        }
        
        if(this.infoMav.PaeseRelazioni1__c == undefined || this.infoMav.PaeseRelazioni1__c == null || this.infoMav.PaeseRelazioni1__c == ''){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Errore!',
                    // message: 'Popolare almeno il campo Paese relazioni 1',
                    message: ERR_PAESERELAZIONI,
                    variant: 'error'
                })
            );

            return false;
        }

		if((modulo.OrigineFondi1__c == false && modulo.OrigineFondi2__c == false && modulo.OrigineFondi3__c == false && modulo.OrigineFondi4__c == false) ||
				modulo.OrigineFondi4__c == true && (modulo.OrigineFondiAltro__c == null || modulo.OrigineFondiAltro__c == undefined || modulo.OrigineFondiAltro__c == '')){
				this.errorSezione2 = true;
				return false;
		} else {
                 this.errorSezione2 = false;
			}		

		//Controllo campo Paese Casa Madre
		var mav = this.infoMav;
		if (mav.WGC_Gruppo_frm__c == true) {
			if (mav.PaeseCasaMadre__c != null && mav.PaeseCasaMadre__c != undefined && mav.PaeseCasaMadre__c != '') {
				this.errorPaeseCasaMadre =  false;
			} else {			
				this.errorPaeseCasaMadre = true;
				return false;
			}
		} else {
			this.errorPaeseCasaMadre = false;
		}
        
		//Controllo campo Paese svolgimento attività prevalente
		if (mav.PaeseSvolgimentoAttivitaPrevalente__c != null && mav.PaeseSvolgimentoAttivitaPrevalente__c != undefined && mav.PaeseSvolgimentoAttivitaPrevalente__c != '') {
			this.errorPaeseSvolgimentoAttivitaPrevalente =  false;
		} else {			
			this.errorPaeseSvolgimentoAttivitaPrevalente = true;
			return false;
        }
        
		//Controllo campo Provincia svolgimento attività
		if (mav.ProvinciaSvolgimentoAttivitaPrevalente__c != null && mav.ProvinciaSvolgimentoAttivitaPrevalente__c != undefined && mav.ProvinciaSvolgimentoAttivitaPrevalente__c != '') {
			this.errorProvinciaSvolgimentoAttivitaPrevalente = false;
		} else {			
			this.errorProvinciaSvolgimentoAttivitaPrevalente = true;
			return false;
		}


		console.log('@@@ altro ' , modulo.OrigineFondi4__c + ' ' + modulo.OrigineFondiAltro__c);
		//Ritorno true solo se passo tutte le validazioni
		return true;
    }
    
    salvaModulo(titolari){
        this.enableSpinner();
        //Convalida dati
        var esito = false;
		esito = this.convalidaDati();
		console.log('@@@ esito ', esito);
        if(esito == false){
			this.saveReferenti =  false;            
            this.disableSpinner();
            return false;
        }

        var rec = this.modulo; 
        console.log("modulo da salvare",JSON.stringify(rec));     
        
        //Azione da gestire al ritorno dell'evento dal componente dei titolari esecutori
        SaveRecord({
            "recordId" : this.accountId,
			"recordMAV" : JSON.stringify(rec),
			"recordAccountContact" : JSON.stringify(titolari.relation),
			"flagConsensi" : titolari.flagConsensi,
			"informazioniMav" : this.infoMav,
			"tipologiaMav" : this.tipologiaMAV,
			"visitaLocaliAzienda" : 'false'
        }).then(risposta => { 
            console.log("risposta salva modulo", JSON.stringify(risposta));
            if(risposta.success){
                this.close();
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Successo!',
                        message: 'Salvataggio avvenuto con successo',
                        variant: 'success'
                    })
                );                
                
                this.dispatchEvent(
                    new CustomEvent('changemavinfo', { bubbles: true, composed: true, detail : { success: true} })
                );               
                
                //Inserire evento per update mav
                this.disableSpinner();
            }else{
                this.dispatchEvent(
                    new ShowToastEvent({ 
                        title: 'Errore!',
                        message: 'Errore durante il salvataggio',
                        variant: 'error'
                    })
                );

                this.disableSpinner();
            }
        }).catch(err => {
            console.log('@@@ err ' , err);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Errore!',
                    message: 'Errore durante il salvataggio',
                    variant: 'error'
                })
            );
            this.disableSpinner();
        }); 
    }
    
    saveRecord(){
        this.saveReferenti = true;
    }

    handleSaveTitolareEffettivo(event){  
        this.enableSpinner();     
        var parametriTitolareEsecutivo = event.detail;
        console.log('@@@ parametri ' , JSON.stringify(parametriTitolareEsecutivo));

        if(parametriTitolareEsecutivo.success){ 
            console.log("handleSaveTitolareEffettivo SUCCESS");          
            this.saveReferenti = false;            
            this.salvaModulo(parametriTitolareEsecutivo.json);
        } else if(!parametriTitolareEsecutivo.success && parametriTitolareEsecutivo.json.anagNotCompleted){
            this.saveReferenti = false;             
            this.close();
        } else if(!parametriTitolareEsecutivo.success && parametriTitolareEsecutivo.json.relation == null && parametriTitolareEsecutivo.json.flagConsensi == null){
           this.saveReferenti = false;
           this.disableSpinner();             
        } else{
            this.saveReferenti = false; 
            this.disableSpinner();                        
        }        
    }
}