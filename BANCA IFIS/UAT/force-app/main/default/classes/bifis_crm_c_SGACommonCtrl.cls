/**
* Progetto:         Banca IFIS
* Developer:        Marco Bonin
* Descrizione:      Controller generico di governo della Community SGA
*/

public with sharing class bifis_crm_c_SGACommonCtrl {
    
    @AuraEnabled
    public static void censisciAccount(WorkflowSGA__c actualWorkflow){
    
		// PROCEDO AL CENSIMENTO DELL'ACCOUNT

		// ANCHE SE QUESTO ANDRA' IN ERRORE, ANDRO' COMUNQUE AVANTI, NOTIFICHERO' LA PROBLEMATICA NELLA
		// SCHEDA DELLA PRATICA (CAMPO Errori_Tecnici__c)

		// VERIFICO SE E' GIA' PRESENTE CONTROLLANDO l'ID ACCOUNT CHE HO ACQUISITO IN FASE DI CHECK NEL FLOW

		if(String.isBlank(actualWorkflow.IDAccount__c)){
		
			// RIACQUISISCO IN TOTO I DATI SULL'ACCOUNT IN BASE ALLA FONTE CHE SARA' O RIBES O CEDACRI

			Account accountTrovato;

			List<Object> risultatoRicerca = bifis_crm_c_CommonUtils.checkPartitaIva(actualWorkflow.PartitaIVA__c);

			Boolean primaFaseControlliOK = true;

			if(risultatoRicerca.isEmpty()){
				actualWorkflow.Errori_Tecnici__c = 'Anomalia nella ricerca anagrafica. Nessun risultato trovato.';
				primaFaseControlliOK = false;
			}
			else{

				accountTrovato = (Account)risultatoRicerca[2];

				if(accountTrovato == null){
					actualWorkflow.Errori_Tecnici__c = 'Anomalia nella ricerca anagrafica. Oggetto Account nullo.';
					primaFaseControlliOK = false;
				}
			}

			// NOTIFICA DEGLI ERRORI NEL WORKFLOW

			if(!primaFaseControlliOK){
				update actualWorkflow;
			}
			else {

				// SCRITTURA DELL'OGGETTO ACCOUNT TROVATO NEI SISTEMI ESTRNI
				// SE QUESTO NON GIA' PRESENTE IN CRM

				if(accountTrovato.Id == null){
					insert accountTrovato;
				}

				// JOIN CON IL WORKFLOW

				actualWorkflow.IDAccount__c = accountTrovato.Id;
				actualWorkflow.Errori_Tecnici__c = null;
				update actualWorkflow;

			}

		}

	}

    @AuraEnabled
    public static boolean preValutaPraticaDaCRM(String workflowRecordId, String posizioneImpresaSegnalata, String esitoPreValutazione){
         
        try{
        
            WorkflowSGA__c actualWorkflow = new WorkflowSGA__c ();
            
            actualWorkflow = [SELECT id, Stato__c, Posizione_Impresa_Segnalata__c, Esito_PRE_VALUTAZIONE__c FROM WorkflowSGA__c where Id = :workflowRecordId];
             
            actualWorkflow.Posizione_Impresa_Segnalata__c = posizioneImpresaSegnalata;
            actualWorkflow.Esito_PRE_VALUTAZIONE__c = esitoPreValutazione;
            
            if(esitoPreValutazione == 'NON_APPROVATA'){
                
                actualWorkflow.Stato__c = 'OPPORTUNITA_PERSA';  
                actualWorkflow.Fase_Chiusura__c = 'PRE_VALUTAZIONE_CLIENTE';  
                
            }
            
            if(esitoPreValutazione == 'APPROVATA'){
                
                if(posizioneImpresaSegnalata == 'PROSPECT'){
                    
                    actualWorkflow.Stato__c = 'VISITA_FINALIZZAZIONE_MANDATO';                 
                    
                }
                 
                if(actualWorkflow.Posizione_Impresa_Segnalata__c== 'CLIENTE'){
                    
                    actualWorkflow.Stato__c = 'VISITA_FINALIZZAZIONE_MANDATO';                       
                    
                }                  
                
            }          
            
            update actualWorkflow; 
            
            return true;
            
        }
        catch(Exception ex){
            
            return false;
        }
        
    }
    
    @AuraEnabled
    public static boolean finalizzaPraticaDaCRM(String workflowRecordId, String esitoVisitaCliente/*, String documentiMCI*/){

        try{
        
            WorkflowSGA__c actualWorkflow = new WorkflowSGA__c ();
            
            actualWorkflow = [SELECT id, Stato__c, Esito_Visita_Cliente__c, DOCUMENTO_MCI_JSON__c FROM WorkflowSGA__c where Id = :workflowRecordId];
            
            actualWorkflow.Esito_Visita_Cliente__c = esitoVisitaCliente;
            
            if(esitoVisitaCliente == 'SI'){
                
                actualWorkflow.Stato__c = 'VALUTAZIONE_PRATICA';  
                //actualWorkflow.DOCUMENTO_MCI_JSON__c = documentiMCI;  
                
            }
            
            if(esitoVisitaCliente == 'NO'){
                
                actualWorkflow.Stato__c = 'OPPORTUNITA_PERSA';  
                actualWorkflow.Fase_Chiusura__c = 'VISITA_FINALIZZAZIONE_MANDATO';   
                
            }          
            
            update actualWorkflow;
            
            return true;
            
        }
        catch(Exception ex){
            
            return false;
        }
        
    }    
    
    @AuraEnabled
    public static boolean valutaPraticaDaCRM(String workflowRecordId, String esitoValutazione){
        
        try{
        
            WorkflowSGA__c actualWorkflow = new WorkflowSGA__c ();
            
            actualWorkflow = [SELECT id, Stato__c, Esito_VALUTAZIONE__c FROM WorkflowSGA__c where Id = :workflowRecordId];
            
            actualWorkflow.Esito_VALUTAZIONE__c = esitoValutazione;
            
            if(esitoValutazione == 'APPROVATA'){

                actualWorkflow.Stato__c = 'ATTIVAZIONE_RAPPORTO';  
                
            }
            
            if(esitoValutazione == 'NON_APPROVATA'){
                
                actualWorkflow.Stato__c = 'OPPORTUNITA_PERSA';  
                actualWorkflow.Fase_Chiusura__c = 'VALUTAZIONE_PRATICA';   
                
            }          
                        
            update actualWorkflow;
            
            return true;
            
        }
        catch(Exception ex){
            
            return false;
        }

    }    
    
    @AuraEnabled 
    public static Map<String,String> getValoriPicklistStato (){
        
       Map<String,String> result = new Map<String,String>(); 
        
       List<SelectOption> options = new List<SelectOption>();
       Schema.DescribeFieldResult fieldResult = WorkflowSGA__c.Stato__c.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
       for( Schema.PicklistEntry f : ple)
       {
               result.put(f.getValue(), f.getLabel());
       }     
        
       return result; 
    }    
    
    @AuraEnabled 
    public static void submitFinale (String workflowRecordId){
        
        WorkflowSGA__c actualWorkflow = new WorkflowSGA__c ();

        actualWorkflow = [SELECT id, Stato__c, Name, Ragione_Sociale__c, PartitaIVA__c, DataInvioIfis__c, IDAccount__c FROM WorkflowSGA__c where Id = :workflowRecordId];

        actualWorkflow.Stato__c = 'PRE_VALUTAZIONE_CLIENTE';
        actualWorkflow.DataInvioIfis__c = Date.today();
        
        update actualWorkflow;
        
        String userName = UserInfo.getUserName();
        User activeUser = [Select Email From User where Username = : userName limit 1];
        String userEmail = activeUser.Email;

		Parametri_SGA__c sgaParameters = Parametri_SGA__c.getInstance();
		String destinationMail = sgaParameters.Mail_Pre_Valutatore_Pratica__c;
		String sourceMail = sgaParameters.Mail_Mittente__c;        

		OrgWideEmailAddress owa = [SELECT id, Address, DisplayName from OrgWideEmailAddress where DisplayName = 'Portale Pratiche SGA' limit 1];
        
        if(owa != null){
        
        	bifis_crm_c_CommonUtils.sentMailToTheSubmitter(owa.id, destinationMail, userEmail, actualWorkflow.Ragione_Sociale__c, actualWorkflow.PartitaIVA__c, actualWorkflow.Name, 'SGA');        
        
        }            
            
        return; 
        
    }        
    
    @AuraEnabled 
    public static List<Object> controlliFinali (String workflowRecordId){
        
        List<Object> myResult = new List<Object>();        
        
        List < WorkflowSGA__c > actualWorkflows = new List < WorkflowSGA__c >();
        
        actualWorkflows = [SELECT Fatturato__c, FatturatoAnnoPrecedente__c, Ebitda__c, Oneri_Finanziari__c, PFN__c, PN__c, Passivita_Totali__c, Passivita_Correnti__c, Debiti_Complessivi__c, DSO__c, DIOH__c, Liquidita_Immediate__c, Liquidita_Differite__c,
                           Importo__c, Corrispettivi_Factoring__c, Importo_Massimo_Factoring_Complessivo__c, Scadenza__c,
                           DOCUMENTO_ALT_JSON__c, DOCUMENTO_BOM_JSON__c, DOCUMENTO_CRI_JSON__c, DOCUMENTO_ECF_JSON__c, DOCUMENTO_PDR_JSON__c
                           FROM WorkflowSGA__c where Id = :workflowRecordId];              
        
        boolean errorDetected = false;
        
        WorkflowSGA__c actualWorkflow = actualWorkflows[0];
        
        String[] informazioniQuantiQualitativeErrors = new List<String>();
        String[] configurazioneSegnalazioneErrors = new List<String>();          
        String[] documentazioneErrors = new List<String>();
        
        // INFORMAZIONI QUANTITATIVE QUALITATIVE

		// NESSUN CONTROLLO SUL QUATI QUALITATIVO. MAIL GASTI DEL 12/10/2018 10:19
        
        /*
        
        if(actualWorkflow.Fatturato__c == null){
            informazioniQuantiQualitativeErrors.add('Fatturato non valorizzato');errorDetected = true;
        }
        
        if(actualWorkflow.FatturatoAnnoPrecedente__c == null){
            informazioniQuantiQualitativeErrors.add('Fatturato Anno Precedente non valorizzato');errorDetected = true;
        }
        
        if(actualWorkflow.Ebitda__c == null){
            informazioniQuantiQualitativeErrors.add('Ebitda non valorizzato');errorDetected = true;
        }
        
        if(actualWorkflow.Oneri_Finanziari__c == null){
            informazioniQuantiQualitativeErrors.add('Oneri Finanziari non valorizzati');errorDetected = true;
        }
        
        if(actualWorkflow.PFN__c == null){
            informazioniQuantiQualitativeErrors.add('Posizione Finanziaria Netta non valorizzata');errorDetected = true;
        }
        
        if(actualWorkflow.PN__C == null){
            informazioniQuantiQualitativeErrors.add('Patrimonio Netto non valorizzato');errorDetected = true;
        }
        
        if(actualWorkflow.Passivita_Totali__c == null){
            informazioniQuantiQualitativeErrors.add('Passività Totali non valorizzate');errorDetected = true;
        }
        
        if(actualWorkflow.Passivita_Correnti__c == null){
            informazioniQuantiQualitativeErrors.add('Passività Correnti non valorizzate');errorDetected = true;
        }
        
        if(actualWorkflow.Debiti_Complessivi__c == null){
            informazioniQuantiQualitativeErrors.add('Debiti Complessivi non valorizzati');errorDetected = true;
        }        
        
        if(actualWorkflow.DSO__c == null){
            informazioniQuantiQualitativeErrors.add('Giorni Medi Incasso non valorizzati');errorDetected = true;
        }   
        
        if(actualWorkflow.DIOH__c == null){
            informazioniQuantiQualitativeErrors.add('Giorni di Rotazione Magazzino non valorizzati');errorDetected = true;
        }   
        
        if(actualWorkflow.Liquidita_Immediate__c == null){
            informazioniQuantiQualitativeErrors.add('Liquidità Immediate non valorizzate');errorDetected = true;
        }   
        
        if(actualWorkflow.Liquidita_Differite__c == null){
            informazioniQuantiQualitativeErrors.add('Liquidità Differite non valorizzate');errorDetected = true;
        }   
        
		*/
        
        // CONFIGURAZIONE SEGNALAZIONE
        
        if(actualWorkflow.Importo__c == null){
            configurazioneSegnalazioneErrors.add('Importo Piano di Rientro non valorizzato');errorDetected = true;
        }        
        
        if(actualWorkflow.Corrispettivi_Factoring__c == null){
            configurazioneSegnalazioneErrors.add('Percentuale Corrispettivi Factoring verso SGA non valorizzati');errorDetected = true;
        }  
        
		// NESSUN CONTROLLO SU QUESTO CAMPO. MAIL GASTI DEL 17/10/2018 12:19

        if(actualWorkflow.Importo_Massimo_Factoring_Complessivo__c == null){
            configurazioneSegnalazioneErrors.add('Importo Massimo Complessivo Legato al Factoring non valorizzato');errorDetected = true;
        }        
		
        if(actualWorkflow.Scadenza__c == null){
            configurazioneSegnalazioneErrors.add('Scadenza non valorizzata');errorDetected = true;
        }   		  
        
        // CONFIGURAZIONE DOCUMENTAZIONE
        
        if(actualWorkflow.DOCUMENTO_PDR_JSON__c  == '[]'){
            documentazioneErrors.add('Documento Piano di Rientro non caricato');errorDetected = true;
        }     
        
        if(actualWorkflow.DOCUMENTO_CRI_JSON__c  == '[]'){
            documentazioneErrors.add('Documento Centrale Rischi non caricato');errorDetected = true;
        }   
        
        if(actualWorkflow.DOCUMENTO_BOM_JSON__c  == '[]'){
            documentazioneErrors.add('Documento Bozza Mandato non caricato');errorDetected = true;
        }   
        
        myResult.add(informazioniQuantiQualitativeErrors);
        myResult.add(configurazioneSegnalazioneErrors);
        myResult.add(documentazioneErrors);        
        
        if(errorDetected)
            myResult.add(bifis_crm_c_CommonUtils.KO);
        else
            myResult.add(bifis_crm_c_CommonUtils.OK);
        
        return myResult;
        
    }       
    
}