public class WGC_HomePage_Obiettivo_FD_Controller {

    @AuraEnabled
    public static WrapperResponse getAllData(){
        
        Id profileId = userinfo.getProfileId();
        User user = [ SELECT Id, NDGGruppo__c FROM User WHERE Id =: UserInfo.getUserId()];
        String profileName = [Select Id,Name from Profile where Id=:profileId].Name;
        String AnnoCorrente = String.ValueOf(System.Today().Year());
		Map<id, user> userfd = new Map<id, user>([SELECT id,NDGGRUPPO__c,Filiale__c,WGC_Team_Filo_Diretto__c,Qualifica_Utente__c FROM user where WGC_Team_Filo_Diretto__c != null ]);

        WrapperResponse result = new WrapperResponse();
        WrapperRecords records = new WrapperRecords();

        try{

            Impostazioni__c imp = Impostazioni__c.getOrgDefaults();

            records.impostazioni = imp;

            Integer fineMese = Date.daysInMonth(System.Today().year(), System.Today().month());
            Integer work = 365;
            if(!Test.isRunningTest()){
                work = U.getWorkingDays(System.now().addDays(-1).day() + '/' + System.now().month() + '/' + System.now().year(), String.valueOf(fineMese + '/' + System.now().month() + '/'+System.now().year()).trim());
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
                                                                            WHERE Data_Visita_Commerciale__c >= LAST_N_YEARS:1 AND 
                                                                            Ragione_Sociale__r.WGC_Specialista_Filo_Diretto__c in:userfd.keyset()]);
            
            records.budgetList=budgetVisiteList;
            records.dettaglioVisiteList=dettaglioVisiteList.values();

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
        @AuraEnabled public List<WGC_Budget__c> budgetList;
        @AuraEnabled public Integer workMonth;
        @AuraEnabled public Impostazioni__c impostazioni;
        
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