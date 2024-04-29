public class WGC_Obiettivo_FD_Controller {

    @AuraEnabled
    public static WrapperResponse getAllData() {        

        Id profileId = userinfo.getProfileId();
        User user = [ SELECT Id, NDGGruppo__c FROM User WHERE Id =: UserInfo.getUserId()];
        String profileName = [Select Id,Name from Profile where Id=:profileId].Name;

        WrapperResponse result = new WrapperResponse();
        WrapperRecords records = new WrapperRecords();
        
        try{

            Integer fineMese = Date.daysInMonth(System.Today().year(), System.Today().month());
            Integer work = 365;
            if(!Test.isRunningTest()){
                work = U.getWorkingDays(System.now().day() + '/' + System.now().month() + '/' + System.now().year(), String.valueOf(fineMese + '/' + System.now().month() + '/'+System.now().year()).trim());
            }            
            System.debug('work: ' + work);

            // List<Integer> workingDays = new List<Integer>();
            // for(Integer i = 0; i < 12; i++){
            //     if(i == 1){
            //         workingDays.add(U.getWorkingDays( '01'+ '/' + (i + 1) + '/' + System.now().year(), '28'+ '/' + (i + 1) + '/' + System.now().year()));
            //     } else if(i == 10 || i == 3 || i == 5 || i == 8) {
            //         workingDays.add(U.getWorkingDays( '01'+ '/' + (i + 1) + '/' + System.now().year(), '30'+ '/' + (i + 1) + '/' + System.now().year()));
            //     } else {
            //         workingDays.add(U.getWorkingDays( '01'+ '/' + (i + 1) + '/' + System.now().year(), '31'+ '/' + (i + 1) + '/' + System.now().year()));
            //     }
            // }

            // records.workingDays = workingDays;
            records.workMonth = work;

            List<WGC_New_Business__c> accList = new List<WGC_New_Business__c>();
            if(profileName == 'IFIS - Direzione Commerciale - Filo Diretto'){
                accList = [ SELECT Id, Anagrafica__r.Id, Anagrafica__r.Name, Anagrafica__r.StatoCensimento__c, Anagrafica__r.WGC_Qualifica_Corporate__c, 
                                   Anagrafica__r.WGC_Specialista_Factoring__c, Anagrafica__r.WGC_Factoring_Attivo__c, Anagrafica__r.CreatedDate, 
                                   Anagrafica__r.WGC_Originator__c, Data_New_Business__c, Anagrafica__r.WGC_StatoAnagraficaCed__c, Anagrafica__r.WGC_Data_Ex_Cliente_SvilCommFiliali__c   
                            FROM WGC_New_Business__c
                            WHERE NDG_Filo_Diretto__c != NULL AND
                                Data_New_Business__c >= LAST_N_YEARS:1 ];

            } else {
                accList = [ SELECT Id, Anagrafica__r.Id, Anagrafica__r.Name, Anagrafica__r.StatoCensimento__c, Anagrafica__r.WGC_Qualifica_Corporate__c, 
                                   Anagrafica__r.WGC_Specialista_Factoring__c, Anagrafica__r.WGC_Factoring_Attivo__c, Anagrafica__r.CreatedDate, 
                                   Anagrafica__r.WGC_Originator__c, Data_New_Business__c, Anagrafica__r.WGC_StatoAnagraficaCed__c, Anagrafica__r.WGC_Data_Ex_Cliente_SvilCommFiliali__c   
                            FROM WGC_New_Business__c
                            WHERE NDG_Filo_Diretto__c =: user.NDGGruppo__c AND
                                Data_New_Business__c >= LAST_N_YEARS:1 ];
            }            
            records.accountList = accList;

            Set<Id> accIdSet = new Set<Id>();
            for(WGC_New_Business__c acc : accList){
                accIdSet.add(acc.Id);
            }

            List<WGC_Dettaglio_Visite__c> dettaglioVisiteList = new List<WGC_Dettaglio_Visite__c>();
            if(profileName == 'IFIS - Direzione Commerciale - Filo Diretto'){
                dettaglioVisiteList = [ SELECT Id, Name, CreatedDate, Esito_Visita__c, Iniziativa__c, Primo_Prodotto__c, Filiale__c, Data_Visita_Commerciale__c,
                                                Macro_Esito__c, Pratica_Presentata__c, Esito_Pratica__c, Rapporto_Avviato__c, Operatore_Filo_Diretto__c, Ragione_Sociale__c,
                                                Previsione_Avvio_Rapporto__c, Data_Avvio_Rapporto__c, Data_Contatto_Telefonico__c
                                    FROM WGC_Dettaglio_Visite__c
                                    WHERE Data_Visita_Commerciale__c >= LAST_N_YEARS:1 AND
                                          RecordType.DeveloperName = 'Dettaglio_Visita' ];
            } else {
                dettaglioVisiteList = [ SELECT Id, Name, CreatedDate, Esito_Visita__c, Iniziativa__c, Primo_Prodotto__c, Filiale__c, Data_Visita_Commerciale__c,
                                                Macro_Esito__c, Pratica_Presentata__c, Esito_Pratica__c, Rapporto_Avviato__c, Operatore_Filo_Diretto__c, Ragione_Sociale__c,
                                                Previsione_Avvio_Rapporto__c, Data_Avvio_Rapporto__c, Data_Contatto_Telefonico__c, Ragione_Sociale__r.WGC_Specialista_Filo_Diretto__c
                                    FROM WGC_Dettaglio_Visite__c
                                    WHERE Data_Visita_Commerciale__c >= LAST_N_YEARS:1 AND 
                                        Ragione_Sociale__r.WGC_Specialista_Filo_Diretto__c =: user.Id ];
            }
            records.dettaglioVisiteList = dettaglioVisiteList;

            List<WGC_Dettaglio_Visite__c> dettaglioVisitePotenzialeList = new List<WGC_Dettaglio_Visite__c>();
            for(WGC_Dettaglio_Visite__c dv : dettaglioVisiteList){
                if(dv.Data_Contatto_Telefonico__c != null && dv.Data_Contatto_Telefonico__c.month() == System.today().month() && dv.Data_Contatto_Telefonico__c.year() == System.today().year() && dv.Data_Avvio_Rapporto__c > dv.Data_Contatto_Telefonico__c) dettaglioVisitePotenzialeList.add(dv);
            }
            
            System.debug('SV DV POTENZIALE: ' + dettaglioVisitePotenzialeList);
            System.debug(JSON.serialize(dettaglioVisitePotenzialeList));

            //records.potenziale = WGC_HomePage_Obiettivo_FD_Controller.calcolaPotenzialiAttuali((profileName == 'IFIS - Direzione Commerciale - Filo Diretto') ? true : false, dettaglioVisitePotenzialeList);

            System.debug('SV DV POTENZIALE: ' + records.potenziale);
            List<Event> eventList = new List<Event>();
            if(profileName == 'IFIS - Direzione Commerciale - Filo Diretto'){
                eventList = [ SELECT Id, AccountId, OwnerId, Stato__c, Originator__c, WGC_Macro_Esito__c, CreatedDate, Data_Inizio__c                                              
                              FROM Event 
                              WHERE Account.WGC_Specialista_Filo_Diretto__c != NULL
                                AND Account.WGC_Filo_Diretto_Attivo__c = TRUE
                                AND CreatoDaFiloDiretto__c = TRUE
                                AND RecordType.DeveloperName != 'Promemoria'
                                AND (NOT RecordType.DeveloperName LIKE '%Diario%')
                                AND CreatedDate > LAST_N_YEARS:1 ORDER BY CreatedDate ];

            } else {
                eventList = [ SELECT Id, AccountId, OwnerId, Stato__c, Originator__c, WGC_Macro_Esito__c, CreatedDate, Data_Inizio__c                                              
                              FROM Event 
                              WHERE Account.WGC_Specialista_Filo_Diretto__c =: UserInfo.getUserId() 
                                AND Account.WGC_Filo_Diretto_Attivo__c = TRUE
                                AND CreatoDaFiloDiretto__c = TRUE
                                AND RecordType.DeveloperName != 'Promemoria'
                                AND (NOT RecordType.DeveloperName LIKE '%Diario%')
                                AND CreatedDate > LAST_N_YEARS:1 ORDER BY CreatedDate ];
            }
            records.eventList = eventList;

            List<WGC_Linea_Prodotto__c> productList = new List<WGC_Linea_Prodotto__c>();
            if(profileName == 'IFIS - Direzione Commerciale - Filo Diretto'){
                productList = [ SELECT Id, NDG_Filo_Diretto__c, Anagrafica__c, Data_attivazione_linea__c, Data_Ultima_Cessione__c                                              
                              FROM WGC_Linea_Prodotto__c 
                              WHERE NDG_Filo_Diretto__c != NULL
                                AND Data_attivazione_linea__c > LAST_N_YEARS:1 ORDER BY Data_attivazione_linea__c ];
            } else {
                productList = [ SELECT Id, NDG_Filo_Diretto__c, Anagrafica__c, Data_attivazione_linea__c, Data_Ultima_Cessione__c                                              
                              FROM WGC_Linea_Prodotto__c 
                              WHERE NDG_Filo_Diretto__c =: user.NDGGruppo__c
                                AND Data_attivazione_linea__c > LAST_N_YEARS:1 ORDER BY Data_attivazione_linea__c ];
            }
            records.productList = productList;

            List<WGC_Best_Practice__c> bpList = [ SELECT Id, OwnerId, LastModifiedDate, Redemption_Dettaglio__c, Convertion_Dettaglio__c, 
                                                        T0_Dettaglio__c, T1_Dettaglio__c, Qualita_Dettaglio__c, Year__c, Week__c, Month__c, Task__c, Visite__c, 
                                                        Opportunita__c, Clienti_Attivati__c, Prodotti_venduti__c, Filo_diretto__c 
                                                  FROM WGC_Best_Practice__c 
                                                  WHERE Filo_diretto__c = TRUE AND
                                                    (Year__c = 'Corrente' OR Year__c = '')                                                    
                                                  ORDER BY OwnerId, Week__c
                                                  LIMIT 120 ];

            records.bestPracticeList = bpList;

            List<WGC_Budget__c> budgetList = [ SELECT Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate,
                                                  LastModifiedById, SystemModstamp, Anno__c, Mese__c, Clienti_avviati__c, 
                                                  Visite_esitate__c, Pratiche_presentate__c, Turnover__c, Impiego_medio__c, 
                                                  Redditivit_impieghi__c, Prodotti_venduti__c,
                                                  Visite_FD_revisionate__c, Clienti_avviati_FD_revisionati__c, Prodotti_venduti_FD_revisionati__c   
                                           FROM WGC_Budget__c
                                           WHERE OwnerId =: UserInfo.getUserId()
                                               AND Anno__c =: String.valueOf(Date.Today().year()) ];
            records.budgetList = budgetList;

            result.data.add(records);


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
        @AuraEnabled public List<WGC_New_Business__c> accountList;
        @AuraEnabled public List<Opportunity> opportunityList;
        @AuraEnabled public List<Event> eventList;
        @AuraEnabled public List<Task> taskList;
        @AuraEnabled public List<WGC_Linea_Prodotto__c> productList;
        @AuraEnabled public List<WGC_Best_Practice__c> bestPracticeList;
        @AuraEnabled public List<WGC_Budget__c> budgetList;
        // @AuraEnabled public List<Task> taskListIC;

        @AuraEnabled public List<WGC_Dettaglio_Visite__c> dettaglioVisiteList;
        @AuraEnabled public List<Integer> workingDays;
        @AuraEnabled public Decimal potenziale;
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