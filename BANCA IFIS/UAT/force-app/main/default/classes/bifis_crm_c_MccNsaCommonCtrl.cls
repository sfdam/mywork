/**
* Progetto:         Banca IFIS
* Developer:        Marco Bonin
* Descrizione:      Controller generico di governo della Community Mutui MCC
*/

public with sharing class bifis_crm_c_MccNsaCommonCtrl {

    @AuraEnabled  
    public static void submitFinale (String workflowRecordId){
  
        WorkflowMutui__c actualWorkflow = new WorkflowMutui__c ();
        
        actualWorkflow = [SELECT id, Stato__c, Name, DataInvioIfis__c, Ragione_Sociale__c, PartitaIVA__c FROM WorkflowMutui__c where Id = :workflowRecordId];
        
        actualWorkflow.Stato__c = 'INVIATA';
		actualWorkflow.DataInvioIfis__c = Date.today();
        
        update actualWorkflow;
        
        String userName = UserInfo.getUserName();
        User activeUser = [Select Email From User where Username = : userName limit 1];
        String userEmail = activeUser.Email;

		Parametri_MccNsa__c mccNsaParameters = Parametri_MccNsa__c.getInstance();
		String destinationMail = mccNsaParameters.Mail_Pre_Valutatore_Pratica__c;
		String sourceMail = mccNsaParameters.Mail_Mittente__c;        

		OrgWideEmailAddress owa;
		owa = [SELECT id, Address, DisplayName from OrgWideEmailAddress where DisplayName = 'Portale Pratiche MCC NSA' limit 1];
        
        if(owa != null) {
        	bifis_crm_c_CommonUtils.sentMailToTheSubmitter(
				owa.id, 
				destinationMail, 
				userEmail, 
				actualWorkflow.Ragione_Sociale__c, 
				actualWorkflow.PartitaIVA__c, 
				actualWorkflow.Id, 
				'MCC NSA'
			);
        }
         
        return;
        
    }    
    
    @AuraEnabled 
    public static List<Object> controlliFinali (String workflowRecordId){
        
        List<Object> myResult = new List<Object>();        
        
        List < WorkflowMutui__c > actualWorkflows = new List < WorkflowMutui__c >();
        
        actualWorkflows = [SELECT SAE__c, Fatturato__c, NumeroAddetti__c, PartitaIVA__c, REFERENTI_JSON__c, EmailPEC__c,
						   TipoViaLegale__c,IndirizzoLegale__c,CivicoLegale__c,CapLegale__c,CittaLegale__c,ProvinciaLegale__c,
						   TipoViaSpedizione__c,IndirizzoSpedizione__c,CivicoSpedizione__c,CapSpedizione__c,CittaSpedizione__c,ProvinciaSpedizione__c,
						   TipoViaAltro__c,IndirizzoAltro__c,CivicoAltro__c,CapAltro__c,CittaAltro__c,ProvinciaAltro__c,
						   Tipologia_Mutuo__c,
                           Importo__c, DurataPreAmmortamento__c, DurataTotale__c, Finalita__c, SpreadPositivo__c, SpeseCommissione__c, CostoMediazione__c, GaranziaImporto__c,
						   ImportoSA__c, DurataPreAmmortamentoSA__c, DurataTotaleSA__c, FinalitaSA__c, SpeseCommissioneSA__c,
                           Privacy_Azienda_1__c, Privacy_Azienda_2__c, Privacy_Azienda_3__c, Privacy_Azienda_4__c, Privacy_Azienda_5__c, Privacy_Azienda_Tradizionali__c, Privacy_Esecutore_1__c, Privacy_Esecutore_2__c, Privacy_Esecutore_3__c, Privacy_Esecutore_4__c, Privacy_Esecutore_5__c, Privacy_Esecutore_Tradizionali__c, 
                           MAV_Natura_Rapporto__c, MAV_Tesorerie__c, MAV_Affidamenti__c, MAV_Investimento__c, MAV_Incassi_Pagamenti__c, MAV_Smobilizzo_Italia__c, MAV_Stipendi__c, MAV_Fornitori__c, MAV_Smobilizzo_Estero__c, MAV_Transazioni_Estero__c, MAV_Proventi__c, MAV_Straordinari__c, MAV_Cessione__c, MAV_Altro__c,
						   MTC_Indirizzo__c,
                           TipologiaQuestionario__c, QQSB1__c, QQSB2__c, QQSB3__c, QQSB4__c, QQSB5__c, QQSB6__c, QQSB7__c, QQSB8__c, QQSB9__c, QQSB10__c, QQSB11__c, QQSB12__c, QQSB13__c, QQSB14__c, QQSB15__c, QQSB16__c, QQSB17__c, QQSB18__c, QQCO1__c, QQCO2__c, QQCO3__c, QQCO4__c, QQCO5__c, QQCO6__c, QQCO7__c, QQCO8__c, QQCO9__c, QQCO10__c, QQCO11__c, QQCO12__c, QQCO13__c, QQCO14__c, QQCO15__c, QQCO16__c, QQCO17__c, QQCO18__c, QQCO19__c, QQCO20__c, QQCO21__c, 
                           DOCUMENTO_RSF_JSON__c, DOCUMENTO_MAV_JSON__c, DOCUMENTO_MPE_JSON__c, DOCUMENTO_MPA_JSON__c, DOCUMENTO_MTC_JSON__c, DOCUMENTO_DIT_JSON__c, DOCUMENTO_DIE_JSON__c, DOCUMENTO_SVR_JSON__c,
                           DOCUMENTO_RI_JSON__c, DOCUMENTO_A4_JSON__c, DOCUMENTO_DIA4_JSON__c, DOCUMENTO_PCD_JSON__c, DOCUMENTO_DM10_JSON__c, DOCUMENTO_SDG_JSON__c, DOCUMENTO_DCVC_JSON__c, DOCUMENTO_DAB_JSON__c, DOCUMENTO_ECF_JSON__c, DOCUMENTO_BE3_JSON__c, DOCUMENTO_MU2_JSON__c, DOCUMENTO_BVA_JSON__c, DOCUMENTO_DIC_JSON__c,
                           DOCUMENTO_MUS_JSON__c, DOCUMENTO_DITS_JSON__c, DOCUMENTO_BPR_JSON__c, DOCUMENTO_UAC_JSON__c, DOCUMENTO_PRO_JSON__c, DOCUMENTO_GCE_JSON__c, DOCUMENTO_DM10I_JSON__c, DOCUMENTO_VCL_JSON__c, DOCUMENTO_BESC_JSON__c FROM WorkflowMutui__c where Id = :workflowRecordId];              
        
        boolean errorDetected = false;
        
        WorkflowMutui__c actualWorkflow = actualWorkflows[0];
        
        String[] anagrafeErrors = new List<String>();
        String[] configurazioneProdottoErrors = new List<String>();          
        String[] garanzieGarantiErrors = new List<String>();
        String[] privacyErrors = new List<String>();
        String[] compilazioneMAVErrors = new List<String>();
        String[] tecnicheComunicazioneErrors = new List<String>();      
        String[] questionarioQualitativoErrors = new List<String>();
        String[] noteErrors = new List<String>();
        String[] documentazioneErrors = new List<String>();

		// ANAGRAFE
		
		/*
		* 26/11/2018
		* @msommacal
		* come richiesto da Polina Veleva Emilova nella mail del 26/11/2018 i campi SAE, RAE, ATECO, REA, Provincia CCIAA non devono essere obbligatori
		*/
		/*
        if(actualWorkflow.SAE__c == null){
            anagrafeErrors.add('SAE non valorizzato');errorDetected = true;
        }
		*/
        
        if(actualWorkflow.Fatturato__c == null){
            anagrafeErrors.add('Fatturato non valorizzato');errorDetected = true;
        }
        if(actualWorkflow.NumeroAddetti__c == null){
            anagrafeErrors.add('Numero Addetti non valorizzato');errorDetected = true;
        }
        if(String.isBlank(actualWorkflow.EmailPEC__c)){
            anagrafeErrors.add('EMail PEC non valorizzata');errorDetected = true;
        }

		if(!String.isBlank(actualWorkflow.CivicoLegale__c)){
			if(!Pattern.matches('[a-zA-Z0-9]*', actualWorkflow.CivicoLegale__c)){
				anagrafeErrors.add('Numero Civico Legale invalido (solo numeri e lettere)');errorDetected = true;
			}
		}

		if(!String.isBlank(actualWorkflow.CivicoSpedizione__c)){
			if(!Pattern.matches('[a-zA-Z0-9]*', actualWorkflow.CivicoSpedizione__c)){
				anagrafeErrors.add('Numero Civico Spedizione invalido (solo numeri e lettere)');errorDetected = true;
			}
		}
		// ANAGRAFE REFERENTI

        if(actualWorkflow.REFERENTI_JSON__c == '[]'){
            anagrafeErrors.add('Nessun referente inserito');errorDetected = true; 
        } else{
		
			List<Object> referenti = bifis_crm_c_CommonUtils.parseReferentiJSON(actualWorkflow.REFERENTI_JSON__c);
			Set<String> duplicateChecker = new Set<String>();

			Integer esecutoriCount = 0;
			Integer codiceFiscaleCount = 0;
			Integer codiceFiscaleAnomalo = 0;
			
			for(Object current : referenti){

				Map<String,Object> v = (Map<String,Object>)current;

				duplicateChecker.add((String)v.get('codiceFiscale'));
				codiceFiscaleCount ++;

				String valoreRuolo = (String)v.get('ruolo');

				if(valoreRuolo.containsIgnoreCase('esecutore')){
	
					esecutoriCount++;
	
				}

				String nome = (String)v.get('nome');
				String cognome = (String)v.get('cognome');
				String codiceFiscale = (String)v.get('codiceFiscale');

				UtilCodiceFiscale u = new UtilCodiceFiscale();

				if(u.calculateCognome(cognome) != codiceFiscale.substring(0,3) || u.calculateNome(nome) != codiceFiscale.substring(3,6)){
					codiceFiscaleAnomalo++;
				}

			}

			if(duplicateChecker.size() <> codiceFiscaleCount){
				anagrafeErrors.add('Codici Fiscali ripetuti tra i referenti');errorDetected = true; 
			}

			if(codiceFiscaleAnomalo > 0){
				anagrafeErrors.add('Codice fiscale anomalo (verificare anche Nome e Cognome del referente)');errorDetected = true; 
			}

			if(esecutoriCount < 1){
				anagrafeErrors.add('Nessun referente esecutore inserito');errorDetected = true; 
			}

			if(esecutoriCount > 1){
				anagrafeErrors.add('Solo un referente esecutore può essere inserito');errorDetected = true; 
			}

		}         
        
        // CONFIGURAZIONE PRODOTTO    
				
        if(String.isBlank(actualWorkflow.Tipologia_Mutuo__c)){
            configurazioneProdottoErrors.add('Tipologia Mutui non valorizzata');errorDetected = true; 
        } 
		else {
		
			if(actualWorkflow.Tipologia_Mutuo__c == 'STANDARD' || actualWorkflow.Tipologia_Mutuo__c == 'MISTO' ){

				if(actualWorkflow.Importo__c == null){
					configurazioneProdottoErrors.add('Importo del mutuo non valorizzato');errorDetected = true; 
				}
				if(actualWorkflow.DurataPreAmmortamento__c == null){
					configurazioneProdottoErrors.add('Durata Pre Ammortamento non valorizzata');errorDetected = true; 
				}
				if(actualWorkflow.DurataTotale__c == null){
					configurazioneProdottoErrors.add('Durata Totale non valorizzata');errorDetected = true; 
				}   

				if(String.isBlank(actualWorkflow.Finalita__c)){
					configurazioneProdottoErrors.add('Finalità Mutuo non valorizzata');errorDetected = true; 
				} 
				if(actualWorkflow.SpreadPositivo__c == null){
					configurazioneProdottoErrors.add('Spread Positivo non valorizzato');errorDetected = true; 
				}
				if(actualWorkflow.SpeseCommissione__c == null){
					configurazioneProdottoErrors.add('Importo Commissione MCC mutuo non valorizzato');errorDetected = true; 
				}
				if(actualWorkflow.CostoMediazione__c == null){
					configurazioneProdottoErrors.add('Costo di Mediazione non valorizzato');errorDetected = true; 
				}
				
			} 

			if(actualWorkflow.Tipologia_Mutuo__c == 'ASSICURATIVO' || actualWorkflow.Tipologia_Mutuo__c == 'MISTO'){
				
				if(actualWorkflow.ImportoSA__c == null){
					configurazioneProdottoErrors.add('Importo assicuraivo non valorizzato');errorDetected = true; 
				}
				if(actualWorkflow.DurataPreAmmortamentoSA__c == null){
				}
				if(actualWorkflow.DurataTotaleSA__c == null){
					configurazioneProdottoErrors.add('Durata Totale assicurativa non valorizzata');errorDetected = true; 
				}   

				if(String.isBlank(actualWorkflow.FinalitaSA__c)){
					configurazioneProdottoErrors.add('Finalità assicurazione non valorizzata');errorDetected = true; 
				} 
				if(actualWorkflow.SpeseCommissioneSA__c == null){
					configurazioneProdottoErrors.add('Importo Commissione MCC assicurazione non valorizzato');errorDetected = true; 
				}

			} 

		}
        
        // GARANZIA E GARANTI

        if(actualWorkflow.GaranziaImporto__c == null){
            garanzieGarantiErrors.add('Garanzia su Importo non valorizzata');errorDetected = true; 
        }   
        
        // PRIVACY PF e PG
        
        if(actualWorkflow.Privacy_Azienda_1__c == null || actualWorkflow.Privacy_Azienda_2__c == null || actualWorkflow.Privacy_Azienda_3__c == null || actualWorkflow.Privacy_Azienda_4__c == null || actualWorkflow.Privacy_Azienda_5__c == null || actualWorkflow.Privacy_Azienda_Tradizionali__c == null ){
            privacyErrors.add('Mancata compilazione parziale o totale del questionario AZIENDA');errorDetected = true; 
        }        
        
        if(actualWorkflow.Privacy_Esecutore_1__c == null || actualWorkflow.Privacy_Esecutore_2__c == null || actualWorkflow.Privacy_Esecutore_3__c == null || actualWorkflow.Privacy_Esecutore_4__c == null || actualWorkflow.Privacy_Esecutore_5__c == null || actualWorkflow.Privacy_Esecutore_Tradizionali__c == null ){
            privacyErrors.add('Mancata compilazione parziale o totale del questionario ESECUTORE');errorDetected = true; 
        }             
        
        // COMPILAZIONE MAV
        
        if(String.isBlank(actualWorkflow.MAV_Natura_Rapporto__c)){
            compilazioneMAVErrors.add('Natura del Rapporto non valorizzata');errorDetected = true; 
        }  
        
		if(actualWorkflow.MAV_Tesorerie__c == false && actualWorkflow.MAV_Affidamenti__c == false && actualWorkflow.MAV_Investimento__c == false && actualWorkflow.MAV_Incassi_Pagamenti__c == false && actualWorkflow.MAV_Smobilizzo_Italia__c == false && actualWorkflow.MAV_Stipendi__c == false && actualWorkflow.MAV_Fornitori__c == false && actualWorkflow.MAV_Smobilizzo_Estero__c == false && actualWorkflow.MAV_Transazioni_Estero__c == false){
			compilazioneMAVErrors.add('Scopo del Rapporto non valorizzato');errorDetected = true; 
		}   
	
        if(actualWorkflow.MAV_Proventi__c == false && actualWorkflow.MAV_Straordinari__c == false && actualWorkflow.MAV_Cessione__c == false && actualWorkflow.MAV_Altro__c == false){
            compilazioneMAVErrors.add('Origine dei Fondi non valorizzata');errorDetected = true; 
        } 
        
		// TECNICHE COMUNICAZIONE

		if(actualWorkflow.MTC_Indirizzo__c == 'billing'){
		
			if(String.isBlank(actualWorkflow.TipoViaLegale__c) || String.isBlank(actualWorkflow.IndirizzoLegale__c) || String.isBlank(actualWorkflow.CivicoLegale__c) || String.isBlank(actualWorkflow.CapLegale__c) || String.isBlank(actualWorkflow.CittaLegale__c) || String.isBlank(actualWorkflow.ProvinciaLegale__c)){
				tecnicheComunicazioneErrors.add('L indirizzo (Sede Legale) utilizzato nelle Tecniche di Comunicazione è incompleto');
			}

		}

		if(actualWorkflow.MTC_Indirizzo__c == 'shipping'){
		
			if(String.isBlank(actualWorkflow.TipoViaSpedizione__c) || String.isBlank(actualWorkflow.IndirizzoSpedizione__c) || String.isBlank(actualWorkflow.CivicoSpedizione__c) || String.isBlank(actualWorkflow.CapSpedizione__c) || String.isBlank(actualWorkflow.CittaSpedizione__c) || String.isBlank(actualWorkflow.ProvinciaSpedizione__c)){
				tecnicheComunicazioneErrors.add('L indirizzo (Sede Amministrativa) utilizzato nelle Tecniche di Comunicazione è incompleto');
			}

		}

		if(actualWorkflow.MTC_Indirizzo__c == 'other'){
		
			if(String.isBlank(actualWorkflow.TipoViaAltro__c) || String.isBlank(actualWorkflow.IndirizzoAltro__c) || String.isBlank(actualWorkflow.CivicoAltro__c) || String.isBlank(actualWorkflow.CapAltro__c) || String.isBlank(actualWorkflow.CittaAltro__c) || String.isBlank(actualWorkflow.ProvinciaAltro__c)){
				tecnicheComunicazioneErrors.add('L indirizzo (Altro) utilizzato nelle Tecniche di Comunicazione è incompleto');
			}

		}    
		 
		if(!String.isBlank(actualWorkflow.CivicoAltro__c)){
			if(!Pattern.matches('[a-zA-Z0-9]*', actualWorkflow.CivicoAltro__c)){
				tecnicheComunicazioneErrors.add('Numero Civico Altro invalido (solo numeri e lettere)');errorDetected = true;
			}	
		}	    

        // COMPILAZIONE QQ
        
        if(actualWorkflow.TipologiaQuestionario__c == 'Small Business'){
        
            if(actualWorkflow.QQSB1__c == null || actualWorkflow.QQSB2__c == null || actualWorkflow.QQSB3__c == null || actualWorkflow.QQSB4__c == null || actualWorkflow.QQSB5__c == null || actualWorkflow.QQSB6__c == null || actualWorkflow.QQSB7__c == null || actualWorkflow.QQSB8__c == null || actualWorkflow.QQSB9__c == null || actualWorkflow.QQSB10__c == null || actualWorkflow.QQSB11__c == null || actualWorkflow.QQSB12__c == null || actualWorkflow.QQSB13__c == null || actualWorkflow.QQSB14__c == null || actualWorkflow.QQSB15__c == null || actualWorkflow.QQSB16__c == null || actualWorkflow.QQSB17__c == null || actualWorkflow.QQSB18__c == null ){
                questionarioQualitativoErrors.add('Mancata compilazione parziale o totale del QQ SMALL BUSINESS');errorDetected = true; 
            }        
            
        }
               
        if(actualWorkflow.TipologiaQuestionario__c == 'Corporate'){
            
            if(actualWorkflow.QQCO1__c == null || actualWorkflow.QQCO2__c == null || actualWorkflow.QQCO3__c == null || actualWorkflow.QQCO4__c == null || actualWorkflow.QQCO5__c == null || actualWorkflow.QQCO6__c == null || actualWorkflow.QQCO7__c == null || actualWorkflow.QQCO8__c == null || actualWorkflow.QQCO9__c == null || actualWorkflow.QQCO10__c == null || actualWorkflow.QQCO11__c == null || actualWorkflow.QQCO12__c == null || actualWorkflow.QQCO13__c == null || actualWorkflow.QQCO14__c == null || actualWorkflow.QQCO15__c == null || actualWorkflow.QQSB16__c == null || actualWorkflow.QQCO17__c == null || actualWorkflow.QQCO18__c == null || actualWorkflow.QQCO19__c == null || actualWorkflow.QQCO20__c == null || actualWorkflow.QQCO21__c == null ){
                questionarioQualitativoErrors.add('Mancata compilazione parziale o totale del QQ CORPORATE');errorDetected = true; 
            }
            
        }
        
        // DOCUMENTI

        if(actualWorkflow.DOCUMENTO_RSF_JSON__c == '[]'){
            documentazioneErrors.add('Mancato caricamento documento RSF');errorDetected = true; 
        }          
        if(actualWorkflow.DOCUMENTO_MAV_JSON__c == '[]'){
            
        }   
        if(actualWorkflow.DOCUMENTO_MPE_JSON__c == '[]'){
            documentazioneErrors.add('Mancato caricamento documento Modulo Privacy Esecutore');errorDetected = true; 
        }   
        if(actualWorkflow.DOCUMENTO_MPA_JSON__c == '[]'){
            documentazioneErrors.add('Mancato caricamento documento Modulo Privacy Azienda');errorDetected = true; 
        }   
        if(actualWorkflow.DOCUMENTO_MTC_JSON__c == '[]'){
            documentazioneErrors.add('Mancato caricamento documento Modulo Tecniche di Comunicazione');errorDetected = true; 
        }   
        if(actualWorkflow.DOCUMENTO_DIT_JSON__c == '[]'){

        }   
        if(actualWorkflow.DOCUMENTO_DIE_JSON__c == '[]'){
            documentazioneErrors.add('Mancato caricamento documenti Identità Esecutore');errorDetected = true; 
        }   
        
        if(actualWorkflow.DOCUMENTO_SVR_JSON__c == '[]'){
            documentazioneErrors.add('Mancato caricamento documento Scheda di Valutazione del Rischio');errorDetected = true; 
        }      
        if(actualWorkflow.DOCUMENTO_RI_JSON__c == '[]'){
            documentazioneErrors.add('Mancato caricamento documento Report Impresa');errorDetected = true; 
        }
        if(actualWorkflow.DOCUMENTO_A4_JSON__c == '[]'){
            documentazioneErrors.add('Mancato caricamento documento Allegato 4');errorDetected = true; 
        }  
        if(actualWorkflow.DOCUMENTO_DIA4_JSON__c == '[]'){
            
        }  
        if(actualWorkflow.DOCUMENTO_PCD_JSON__c == '[]'){
            
        }   
        if(actualWorkflow.DOCUMENTO_DM10_JSON__c == '[]'){
            documentazioneErrors.add('Mancato caricamento documento DM 10 / Dichiarazione assenza Dipendenti');errorDetected = true; 
        }      
        if(actualWorkflow.DOCUMENTO_SDG_JSON__c == '[]'){
            documentazioneErrors.add('Mancato caricamento documento Schema del Gruppo');errorDetected = true; 
        }   
        if(actualWorkflow.DOCUMENTO_DCVC_JSON__c == '[]'){
            documentazioneErrors.add('Mancato caricamento documento Visura Camerale/Cerved o Libro Soci');errorDetected = true; 
        }   
        if(actualWorkflow.DOCUMENTO_DAB_JSON__c == '[]'){
            documentazioneErrors.add('Mancato caricamento documento Dettaglio Affidamenti Bancari');errorDetected = true; 
        }       
        if(actualWorkflow.DOCUMENTO_ECF_JSON__c == '[]'){
            documentazioneErrors.add('Mancato caricamento documento Elenco dei Principali Clienti e Fornitori');errorDetected = true; 
        } 
        if(actualWorkflow.DOCUMENTO_BE3_JSON__c == '[]'){
             
        }   
        if(actualWorkflow.DOCUMENTO_MU2_JSON__c == '[]'){
             
        }  
        if(actualWorkflow.DOCUMENTO_BVA_JSON__c == '[]'){
            documentazioneErrors.add('Mancato caricamento documento Bilancio di Verifica/Analitico dell ultimo esercizio');errorDetected = true; 
        }
		
		if(actualWorkflow.Tipologia_Mutuo__c == 'ASSICURATIVO' || actualWorkflow.Tipologia_Mutuo__c == 'MISTO'){
					                       
			if(actualWorkflow.DOCUMENTO_DIC_JSON__c == '[]'){
				documentazioneErrors.add('Mancato caricamento documento Dichiarazione di Impegno del Cliente');errorDetected = true; 
			}   

		}

        if(actualWorkflow.DOCUMENTO_MUS_JSON__c == '[]'){
            
        }           
        if(actualWorkflow.DOCUMENTO_DITS_JSON__c == '[]'){
			   
        }          
        if(actualWorkflow.DOCUMENTO_BPR_JSON__c == '[]'){
			documentazioneErrors.add('Mancato caricamento documento Bilancio Provvisorio');errorDetected = true;      
        }     
        if(actualWorkflow.DOCUMENTO_UAC_JSON__c == '[]'){
			
        }   
        if(actualWorkflow.DOCUMENTO_PRO_JSON__c == '[]'){
			
        }    
        if(actualWorkflow.DOCUMENTO_GCE_JSON__c == '[]'){
			
        }        
        if(actualWorkflow.DOCUMENTO_DM10I_JSON__c == '[]'){
			
        }
        if(actualWorkflow.DOCUMENTO_VCL_JSON__c == '[]'){
			
        }      
        if(actualWorkflow.DOCUMENTO_BESC_JSON__c == '[]'){
            
        }           
        
        myResult.add(anagrafeErrors);
        myResult.add(configurazioneProdottoErrors);
        myResult.add(garanzieGarantiErrors);
        myResult.add(privacyErrors);
        myResult.add(compilazioneMAVErrors);
        myResult.add(tecnicheComunicazioneErrors);
        myResult.add(questionarioQualitativoErrors);
        myResult.add(noteErrors);
        myResult.add(documentazioneErrors);        
        
        if(errorDetected)
        	myResult.add(bifis_crm_c_CommonUtils.KO);
        else
			myResult.add(bifis_crm_c_CommonUtils.OK);
            
        return myResult;
         
    }
    
    
    @AuraEnabled 
    public static String attribuzioneQQ (String workflowRecordId){
        
        List < WorkflowMutui__c > actualWorkflows = new List < WorkflowMutui__c >();
        
        actualWorkflows = [SELECT Fatturato__c FROM WorkflowMutui__c where Id = :workflowRecordId];
        
        // TRICK PER SISTEMARE UN BUG DI SALESFORCE (https://blog.texei.com/lightning-components-auraenabled-method-parameters-whats-working-and-what-s-not-83c351356104)       
        Integer fatturato = Integer.valueOf(actualWorkflows[0].Fatturato__c);
        
		Impostazioni__c i = Impostazioni__c.getInstance();

        return fatturato != null && fatturato >= i.SogliaFatturatoSBCO__c ? 'Corporate' : 'Small Business';
         
    }
    
    @AuraEnabled 
    public static String classificazioneQQ (Integer fatturato){
        
        // TRICK PER SISTEMARE UN BUG DI SALESFORCE (https://blog.texei.com/lightning-components-auraenabled-method-parameters-whats-working-and-what-s-not-83c351356104)       
		Integer fatturatoConv = null;
		
		if(fatturato != null){
			fatturatoConv = Integer.valueOf(fatturato);
		}

		Impostazioni__c i = Impostazioni__c.getInstance();
		
        return fatturatoConv != null && fatturatoConv >= i.SogliaFatturatoSBCO__c ? 'Corporate' : 'Small Business';
         
    }  

}