import { LightningElement,api,track } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getConsensi from '@salesforce/apex/WGC_Modal_TitolareEsecutore_Controller.getConsensi';
import getReferenti from '@salesforce/apex/WGC_Modal_TitolareEsecutore_Controller.getReferenti';

export default class Wgc_titolare_esecutore extends LightningElement {

    @api accountId;        
    @track consensi;
    @track contactList;
    privateToBeSaved;
 
    @api
    get toBeSaved(){
        return this.privateToBeSaved;
    }

    set toBeSaved(val){
        console.log("set to be saved");
        this.privateToBeSaved = val;
        if (val){
            var listaReferenti = this.contactList;
            var consensi = this.consensi;
            console.log('@@@ listaReferenti da salvare ' , listaReferenti);           
			if(listaReferenti != null && listaReferenti != undefined && listaReferenti.length > 0){				
				var esitoValidazione = this.validaDati(listaReferenti);				
				console.log('@@@ esitoValidazione ' , esitoValidazione);
				if(esitoValidazione){	
                    console.log("CONSENSI: ",consensi);				
                    var obj = {relation: this.contactList, flagConsensi : consensi};
                    this.dispatchEvent(
                        new CustomEvent('handletitolareeffettivo', { bubbles: true, composed: true, detail : { json: obj, success: true} })
                    );				
					
				}else{					
                    var obj = {relation: null, flagConsensi : null};
                    this.dispatchEvent(
                        new CustomEvent('handletitolareeffettivo', { bubbles: true, composed: true, detail : { json: obj, success: false} })
                    );									
					return;
				}
			}else{
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "ERRORE!",
                        message: "Popolare la lista referenti prima di salvare il modulo adeguata verifica",
                        variant: "error"
                    })	
                );	
			}
        }
    }

    get contactExists(){
        return this.contactList !=undefined && this.contactList.length > 0;
    }

    get tipologiaTitolareEffettivo(){
        return [
            { label: 'Proprietà diretta', value: 'Proprietà diretta' },
            { label: 'Proprietà indiretta', value: 'Proprietà indiretta' },
            { label: 'Controllo', value: 'Controllo' },
            { label: 'Potere di amministrazione e direzione', value: 'Potere di amministrazione e direzione' }
        ];
    }

    get tipologiaComportamento(){
        return [
            { label: 'Normale', value: '1' },
            { label: 'Interposizione soggetti terzi', value: '2' },
            { label: 'Riluttante o incapace a fornire info', value: '3' },
            { label: 'Documenti identificativi contraffatti o difformi', value: '4' },
            { label: 'Intende operare con prassi illogiche e svantaggiosi', value: '5' }            
        ];
    }

    constructor() {
        super();       
    }

    connectedCallback(){    
        this.initialize();          
    }

    initialize(){
        getConsensi({"accountId" : this.accountId}).then(risposta => {             
            console.log('@@@ risposta consensi ' , risposta);
            this.consensi =  risposta.PartecipazioneSocietaFiduciarie2__c;
            this.mavCompleto = risposta.WGC_MAV_Completo__c;            
            this.getRef();
        });
    }

    getRef(){
        var accId = this.accountId;
        getReferenti({"accountId" : accId}).then(risposta => {   
            if(risposta == null){
                console.log('@@@ msg ' );
                var obj = {anagNotCompleted : true};

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'ATTENZIONE!',
                        message: 'Nessun Referente disponibile per la compilazione MAV',
                        variant: 'warning'
                    })
                );  

                this.dispatchEvent(
                    new CustomEvent('handletitolareeffettivo', { bubbles: true, composed: true, detail : { json: obj, success: false} })
                );   

                this.contactList = risposta;

            }else {                
                this.contactList = this.handleTitolari(risposta); 
            }            

            console.log("contactList: ",JSON.stringify(this.contactList));
            this.checkUniqueRole();
        });		
    }
    
    changeConsensi(event){
        this.consensi = event.target.checked;
    }

    checkUniqueRole(){       
        var referenti = this.contactList;		
        if(referenti != null && referenti != undefined && referenti.length > 0){
            referenti.forEach((item, index) =>{
                if((item.Ruolo_Pratica == null || item.Ruolo_Pratica == undefined) && 
                    (!item.titolareEffettivo && item.titolareEsecutore )){
                        item.Ruolo_Pratica = {};
                        item.Ruolo_Pratica.value = item.WGC_Ruolo.value;
                        
                }else{
                    console.log('@@@ prova ' , JSON.stringify(item.Ruolo_Pratica) + ' - ' + JSON.stringify(item.Name));
                }
            });
        }
        console.log('@@@ referenti init ' , referenti);        
    }

    changeRole(event){
        var newValue = event.target.value;
		console.log('@@@ newValue role ' , newValue);
		var name = event.target.name;
		var arrContact = this.contactList;		
		arrContact[name].Ruolo_Pratica.value = newValue;
		console.log('@@@ wgc ruolo after ' , arrContact[name].WGC_Ruolo.value );
		console.log('@@@ ruolo pratica after ' , arrContact[name].Ruolo_Pratica.value );
		this.contactList = this.handleTitolari(arrContact);
		console.log('@@@ aaa ' , JSON.stringify(arrContact[name]));
    }

    flagSeleziona(event){
		var newValue = event.target.checked;
		var name = event.target.name;
		var arrContact = this.contactList;		
		if(newValue) {
			this.checkCensimentoFull(arrContact[name].contactFull, false);
		} else{
			arrContact[name].Ruolo_Pratica.value = null;
		}
        arrContact[name].isRelation = newValue;        
		this.contactList = this.handleTitolari(arrContact);
    }

    handleTitolari(arrContact){
        arrContact.forEach((item, index) =>{
            if (item.Name!=undefined && item.Name!=''){
                item.hasName = true;
            }else {
                item.hasName = false;
            }

            if (item.titolareEffettivo && item.titolareEsecutore){
                item.hasBothTitolare = true;
            }else {
                item.hasBothTitolare = false;
            }

            item.isNotRelation = !item.isRelation;

            //ruoli
            let ruoli = [];
            ruoli.push({label:'Titolare Effettivo' , value: item.titolareEffettivo});
            ruoli.push({label:'Esecutore' , value: item.titolareEsecutore});
            ruoli.push({label:'Titolare Effettivo ed Esecutore' , value: item.titolareEffettivo + ';' + item.titolareEsecutore});
            item.ruoli = ruoli;
            item.ruoliTitolare = [];
            item.ruoliTitolare.push(ruoli[0]);
            item.ruoliEsecutore = [];
            item.ruoliEsecutore.push(ruoli[1]);

            if (item.titolareEffettivo && !item.titolareEsecutore){
                item.onlyTitolareEffettivo = true;
            }else {
                item.onlyTitolareEffettivo = false;
            }

            if (!item.titolareEffettivo && item.titolareEsecutore){
                item.onlyTitolareEsecutore = true;
            }else {
                item.onlyTitolareEsecutore = false;
            }

            if((item.isRelation && (item.Ruolo_Pratica.value == item.titolareEsecutore || item.Ruolo_Pratica.value == '')) || item.isRelation == false){
                item.disabledTipologia = true;
				item.WGC_Tipologia_Titolare_Effettivo = null;
            }else {
                item.disabledTipologia = false;
            }

            if((item.isRelation && (item.Ruolo_Pratica.value == item.titolareEffettivo || item.Ruolo_Pratica.value == '')) || item.isRelation == false){
                item.disabledComportamento = true;
				item.comportamentoCliente = null;
            }else {
                item.disabledComportamento = false;
            }           
        });

        return arrContact;
    }
    
    checkCensimentoFull(censimento, isInit){
        if(!censimento){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "ERRORE!",
                    message: "Il referente selezionato non presenta un'anagrafica completa. Ti invitiamo ad eseguire il completamento dei dati nella scheda del referente interessato",
                    variant: "error"
                })	
            );		
		}
    }

    changeTitolare(event){
        var newValue = event.target.value;
		var name = event.target.name;
		var arrContact = this.contactList;
		arrContact[name].WGC_Tipologia_Titolare_Effettivo = newValue;
		this.contactList = arrContact;
    }

    changeComportamento (event){
		var newValue = event.target.value;
		var name = event.target.name;
		var arrContact = this.contactList;
		arrContact[name].comportamentoCliente = newValue;
		this.contactList = arrContact;
    }
    
    validaDati(selezionati){
        var esitoCensimentoContactFull = this.checkCensimentoFullContact();
		console.log('@@@ esito Check censimento ' , esitoCensimentoContactFull);

		var esitoReferentiSelezionati = this.checkReferentiSelezionati(selezionati);

		var esitoTitEff_Esec = this.checkTitEffTitEsec(selezionati);
		console.log('@@@ controllo ' , esitoTitEff_Esec);
		console.log('@@@ controllo totale ' , esitoReferentiSelezionati && esitoCensimentoContactFull && esitoTitEff_Esec);
		if(esitoReferentiSelezionati && esitoCensimentoContactFull && esitoTitEff_Esec){
			console.log('@@@ controllo sbagliato ' );
			var esitoCheckPicklist = this.checkPicklistPopulated(selezionati);
			
			if(esitoCheckPicklist){
				var esitoCountEsecutori = this.checkCountEsecutori(selezionati);

				if(esitoCountEsecutori){
					return true;
				}else{
					return false;
				}
			}else{
				return false;
			}
		}else {
			console.log('@@@ false');
			return false;
		}
    }

    checkCensimentoFullContact(){
		var referenti = this.contactList;
		console.log('@@@ referenti ' , referenti);
		var check = true;
		for(var key in referenti){
			if(referenti[key].contactFull == false && referenti[key].isRelation){
				check = false;
				break;
			}
		}

		if(!check){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "ERRORE!",
                    message: "Referenti selezionati non censiti full",
                    variant: "error"
                })	
            );				
		}

		return check;
    }
    
    checkReferentiSelezionati(selezionati){		
		var countSelezionati = 0;
		selezionati.forEach((item,index) =>{
			if(item.isRelation){
				countSelezionati ++;
			}
		});
		
		if(countSelezionati == 0){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "ERRORE!",
                    message: "Selezionare almeno un referente",
                    variant: "error"
                })	
            );	
			
			return false;
		}else{
			return true;
		}
    }
    
    checkTitEffTitEsec(referenti){
		var flagConsensi = this.consensi;
		console.log('@@@ flagConsensi ' , flagConsensi);

		var countEsec = 0;
		var countTitEff = 0;

		referenti.forEach((item, index) =>{
			console.log('@@@ controllo esec ' , item.isRelation && item.Ruolo_Pratica.value.includes(item.titolareEsecutore));
			console.log('@@@ controllo tit eff ' , item.isRelation && item.Ruolo_Pratica.value.includes(item.titolareEffettivo));
			console.log('@@@ controllo titeff esec ' , item.isRelation && item.Ruolo_Pratica.value == item.titolareEffettivo + ';' + item.titolareEsecutore );
            if(item.isRelation && item.Ruolo_Pratica.value == item.titolareEffettivo + ';' + item.titolareEsecutore){
					countTitEff++;
					countEsec++;
        	}else if(item.isRelation && item.Ruolo_Pratica.value.includes(item.titolareEsecutore) ){
				countEsec++;
			}else if(item.isRelation && item.Ruolo_Pratica.value.includes(item.titolareEffettivo)){
				countTitEff++;
			}
		});

		console.log('@@@ countTitEff ' , countTitEff);
		console.log('@@@ countEsec ' , countEsec);

		if((countEsec == 0 || countTitEff == 0 && !flagConsensi) || (countEsec == 0 && flagConsensi)){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "ERRORE!",
                    message: "Non è possibile completare il Modulo di Adeguata Verifica senza aver indicato almeno un Titolare Effettivo ed un Esecutore",
                    variant: "error"
                })	
            );	
			
			return false;
		}else{
			return true;
		}
    }
    
    checkPicklistPopulated(selezionati){
		var esitoFinale;
		var listaEsiti = [];

		for(var key in selezionati){			
			if(selezionati[key].Ruolo_Pratica != undefined && selezionati[key].Ruolo_Pratica.value != undefined){	
                console.log("Ruolo pratica: "+selezionati[key].Ruolo_Pratica); 			
				if(((selezionati[key].Ruolo_Pratica.value.includes('J') || selezionati[key].Ruolo_Pratica.value.includes('J1')) ||
					selezionati[key].Ruolo_Pratica.value.includes(selezionati[key].titolareEffettivo + ';' + selezionati[key].titolareEsecutore)) &&
					selezionati[key].isRelation && 
					(selezionati[key].WGC_Tipologia_Titolare_Effettivo == '') || (selezionati[key].WGC_Tipologia_Titolare_Effettivo == null && selezionati[key].Ruolo_Pratica.value.includes('J')) || (selezionati[key].WGC_Tipologia_Titolare_Effettivo == undefined && selezionati[key].Ruolo_Pratica.value.includes('J'))){
                        console.log('@@@ ruolo w tipologia ' , selezionati[key]);
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: "ERRORE!",
                                message: "Popolare il campo Tipologia titolare effettivo",
                                variant: "error"
                            })	
                        );						
						esitoFinale = false;
						
				}else if((selezionati[key].Ruolo_Pratica.value == null || selezionati[key].Ruolo_Pratica.value == undefined || selezionati[key].Ruolo_Pratica.value == '') && selezionati[key].isRelation){
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: "ERRORE!",
                            message: "Popolare il campo Ruolo",
                            variant: "error"
                        })	
                    );
                   
					esitoFinale = false;
					
				}else{
					esitoFinale = true;					
				}
			}

			listaEsiti.push(esitoFinale);
		}

		if(listaEsiti.includes(false)){
			return false;
		}else{
			return true;
		}
    }
    
    checkCountEsecutori (selezionati){
		var countEsecutori = 0;
		selezionati.forEach((item, index) =>{			
			if(item.Ruolo_Pratica != undefined && item.Ruolo_Pratica.value != undefined){	
				if(item.Ruolo_Pratica.value.includes(item.titolareEsecutore) && item.isRelation){
					countEsecutori++;
				}
			}
		});

		if(countEsecutori > 1){            
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "ERRORE!",
                    message: "Non è possibile selezionare più titolari esecutori",
                    variant: "error"
                })	
            );
			return false;
		}else{
			return true;
		}
	}
}