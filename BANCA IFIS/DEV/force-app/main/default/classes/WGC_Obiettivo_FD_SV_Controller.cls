public class WGC_Obiettivo_FD_SV_Controller {
	@AuraEnabled
    public static WrapperResponse getAllData() {   
        
        Id profileId = userinfo.getProfileId();
        User user = [ SELECT Id, NDGGruppo__c FROM User WHERE Id =: UserInfo.getUserId()];
        String profileName = [Select Id,Name from Profile where Id=:profileId].Name;
        String AnnoCorrente = String.ValueOf(System.Today().Year());
		Map<id, user> userfd = new Map<id, user>([SELECT id,NDGGRUPPO__c,Filiale__c,WGC_Team_Filo_Diretto__c,Qualifica_Utente__c FROM user where WGC_Team_Filo_Diretto__c != null ]);

        WrapperResponse result = new WrapperResponse();
        WrapperRecords records = new WrapperRecords();
        
        try{
            Integer fineMese = Date.daysInMonth(System.Today().year(), System.Today().month());
            Integer work = 365;
            if(!Test.isRunningTest()){
                work = U.getWorkingDays(System.now().day() + '/' + System.now().month() + '/' + System.now().year(), String.valueOf(fineMese + '/' + System.now().month() + '/'+System.now().year()).trim());
            }            
            System.debug('work: ' + work);
            records.workMonth = work;

            List<WGC_Budget__c> budgetVisiteList = new List<WGC_Budget__c>();
            budgetVisiteList = [ SELECT Clienti_avviati_FD_revisionati__c,Visite_FD_revisionate__c,Prodotti_venduti_FD_revisionati__c,Anno__c,Filo_Diretto__c,Mese__c,OwnerId
                                    FROM WGC_Budget__c
                                    WHERE Filo_Diretto__c= true AND
                                          Anno__c = :AnnoCorrente AND OwnerId in:userfd.keyset()  ];
            
            Map<id,WGC_Dettaglio_Visite__c> dettaglioVisiteList; //= new Map<id,WGC_Dettaglio_Visite__c>();
			dettaglioVisiteList = new Map<id,WGC_Dettaglio_Visite__c>([SELECT Id, Data_avvio_rapporto__c, Data_Contatto_Telefonico__c, Data_Visita_Commerciale__c, Esito_Visita__c,
                                                                       			Esito_Pratica__c, Data_Esito_Pratica__c, Iniziativa__c, Macro_Esito__c, Nome_Settorista__c, Operatore_Filo_Diretto_Actual__c, 
                                                                       			Operatore_Filo_Diretto__c, Ragione_Sociale__r.WGC_Specialista_Filo_Diretto__r.Name, 
                                                                       			Ragione_Sociale__r.WGC_Specialista_Filo_Diretto__r.Filiale__c, Ragione_Sociale__r.WGC_Specialista_Filo_Diretto__r.WGC_Team_Filo_Diretto__c, 
                                                                       			Ragione_Sociale__r.WGC_Specialista_Filo_Diretto__r.Qualifica_Utente__c, Pratica_Presentata__c, 
                                                                       			Primo_Prodotto__c, Ragione_Sociale__c, Rapporto_Avviato__c, Settorista__c, Settorista__r.Name, Famiglia_Primo_Prodotto__c, Previsione_Avvio_Rapporto__c
                                                                            FROM WGC_Dettaglio_Visite__c 
                                                                            WHERE Data_Visita_Commerciale__c = THIS_YEAR AND 
                                                                            Ragione_Sociale__r.WGC_Specialista_Filo_Diretto__c in:userfd.keyset()]);
			
            List<WGC_Prodotto_DettaglioVisite__c> ProdottodettaglioVisiteList = new List<WGC_Prodotto_DettaglioVisite__c>();
            ProdottodettaglioVisiteList = [SELECT Prodotto__r.Anagrafica__c, Prodotto__r.Area_Prodotto__c, Prodotto__r.Data_Estinzione__c, Prodotto__r.Data_scadenza_linea__c, Prodotto__r.Data_Apertura__c, 
                                           			Prodotto__r.Famiglia_Prodotto__c, Prodotto__r.NDG_Filo_Diretto__c, Prodotto__r.Opportunit__c, Dettaglio_Visite__c, 
                                           			Dettaglio_Visite__r.Qualifica_Corporate__c, Dettaglio_Visite__r.Primo_Prodotto__c, Dettaglio_Visite__r.Famiglia_Primo_Prodotto__c, 
                                           			Data_ultima_cessione__c, Prodotto__c, Qualifica_Prodotto__c, Stato_Prodotto__c, Tipologia_Prodotto__c, Prodotto__r.RecordType.Name,
                                           			Famiglia_Prodotto__c, Dettaglio_Visite__r.Operatore_Filo_Diretto__c, Dettaglio_Visite__r.Ragione_Sociale__r.Name
                                                FROM WGC_Prodotto_DettaglioVisite__c
                                                WHERE Dettaglio_Visite__c  in:dettaglioVisiteList.keyset()];
            
            List<Event> eventList = new List<Event>();
            eventList = [ SELECT Id, AccountId, OwnerId, Stato__c, Originator__c, WGC_Macro_Esito__c, CreatedDate, Data_Inizio__c, WGC_Data_Creazione__c, CreatedById                                              
                              FROM Event 
                              WHERE Account.WGC_Specialista_Filo_Diretto__c != NULL
                                AND Account.WGC_Filo_Diretto_Attivo__c = TRUE
                                AND CreatoDaFiloDiretto__c = TRUE
                                AND RecordType.DeveloperName != 'Promemoria'
                                AND (NOT RecordType.DeveloperName LIKE '%Diario%')
                                AND CreatedDate > LAST_N_YEARS:1 ORDER BY CreatedDate ];
            
            records.budgetList=budgetVisiteList;
            records.dettaglioVisiteList=dettaglioVisiteList.values();
            records.ProdottodettaglioVisiteList=ProdottodettaglioVisiteList;
            records.eventList = eventList;

            result.data.add(records);
        } catch(exception e){
            result.success = false; 
            result.msg = e.getMessage();
            return result;
        }
    
        return result;
    }
    
    @AuraEnabled
    public static WrapperResponse getUsersFD() {
        
        
        WrapperResponse result = new WrapperResponse();
        
        try{
            
            result.data = [ SELECT id,Name,NDGGRUPPO__c,Filiale__c,WGC_Team_Filo_Diretto__c,Qualifica_Utente__c FROM user where WGC_Team_Filo_Diretto__c != null ];
            
        } catch(exception e){
            result.success = false; 
            result.msg = e.getMessage();
            return result;
        }
    
        return result;
    
    }
    
    
    /*..........................................*/
    /* Wrapper class to display Position       */
    /*.........................................*/
    
    public class WrapperRecords {
        @AuraEnabled public List<WGC_Dettaglio_Visite__c> dettaglioVisiteList;
        @AuraEnabled public List<WGC_Prodotto_DettaglioVisite__c> ProdottodettaglioVisiteList;
        @AuraEnabled public List<WGC_Budget__c> budgetList;
        @AuraEnabled public List<Event> eventList;
        @AuraEnabled public List<Integer> workingDays;
        @AuraEnabled public Integer workMonth;
        
    }

    /*..........................................*/
    /* Wrapper class to display Response       */
    /*.........................................*/
    
    public class WrapperResponse {
        
        @AuraEnabled public Boolean success;
        @AuraEnabled public String msg;
        @AuraEnabled public List<Object> data;
        
        public WrapperResponse(){
            success = true;
            msg = '';
            data = new List<Object>();
        }
    }
}