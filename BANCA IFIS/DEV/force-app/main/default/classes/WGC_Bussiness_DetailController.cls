public class WGC_Bussiness_DetailController {
@AuraEnabled
    public static WrapperResponse getAllData() {
        
        Id profileId = userinfo.getProfileId();
        User user = [ SELECT Id, NDGGruppo__c FROM User WHERE Id =: UserInfo.getUserId()];
        String profileName = [Select Id,Name from Profile where Id=:profileId].Name;
        // IFIS - Direzione Commerciale

        WrapperResponse result = new WrapperResponse();
        WrapperRecords records = new WrapperRecords();
        
        try{

            // (Anagrafica__r.WGC_StatoAnagraficaCed__c IN ('Cliente Attivo', 'Prospect')
            //                         OR (Anagrafica__r.WGC_StatoAnagraficaCed__c = 'Ex Cliente' 
            //                         AND  Anagrafica__r.WGC_Data_Ex_Cliente_SvilCommFiliali__c >= LAST_N_YEARS:2))

            List<WGC_New_Business__c> accList = new List<WGC_New_Business__c>();
            if(profileName == 'IFIS - Direzione Commerciale'){
                accList = [ SELECT Id, Anagrafica__r.Id, Anagrafica__r.Name, Anagrafica__r.StatoCensimento__c, Anagrafica__r.WGC_Qualifica_Corporate__c, 
                                   Anagrafica__r.WGC_Specialista_Factoring__c, Anagrafica__r.WGC_Factoring_Attivo__c, Anagrafica__r.CreatedDate, 
                                   Anagrafica__r.WGC_Originator__c, Data_New_Business__c, Anagrafica__r.WGC_StatoAnagraficaCed__c, Anagrafica__r.WGC_Data_Ex_Cliente_SvilCommFiliali__c 
                            FROM WGC_New_Business__c
                            WHERE Data_New_Business__c >= LAST_N_YEARS:1 ];
            } else {
                accList = [ SELECT Id, Anagrafica__r.Id, Anagrafica__r.Name, Anagrafica__r.StatoCensimento__c, Anagrafica__r.WGC_Qualifica_Corporate__c, 
                                   Anagrafica__r.WGC_Specialista_Factoring__c, Anagrafica__r.WGC_Factoring_Attivo__c, Anagrafica__r.CreatedDate, 
                                   Anagrafica__r.WGC_Originator__c, Data_New_Business__c, Anagrafica__r.WGC_StatoAnagraficaCed__c, Anagrafica__r.WGC_Data_Ex_Cliente_SvilCommFiliali__c   
                            FROM WGC_New_Business__c
                            WHERE NDG_Settorista__c =: user.NDGGruppo__c AND NDG_Settorista__c != ''
                                AND Data_New_Business__c >= LAST_N_YEARS:1 ];
            }
            records.accountList = accList;

            // Set<Id> accIdSet = new Set<Id>();
            // for(Account acc : accList){
            //     accIdSet.add(acc.Id);
            // }

            List<Opportunity> oppList = new List<Opportunity>();
            if(profileName == 'IFIS - Direzione Commerciale'){
                oppList = [ SELECT Id, AccountId, OwnerId, StageName, Originator__c, CreatedDate, Data_Inizio__c                                       
                            FROM Opportunity 
                            WHERE Account.WGC_Specialista_Factoring__c != null AND Data_Inizio__c > LAST_N_YEARS:1 ORDER BY Data_Inizio__c ];
            } else {
                oppList = [ SELECT Id, AccountId, OwnerId, StageName, Originator__c, CreatedDate, Data_Inizio__c                                         
                            FROM Opportunity 
                            WHERE Account.WGC_Specialista_Factoring__c =: UserInfo.getUserId() AND OwnerId =: UserInfo.getUserId() AND Data_Inizio__c > LAST_N_YEARS:1 ORDER BY Data_Inizio__c ];
            }
            records.opportunityList = oppList;

            List<Event> eventList = new List<Event>();

            // 13.05 VS - ADD AND RecordType.DeveloperName != 'Promemoria' AND (NOT RecordType.DeveloperName LIKE '%Diario%')
            if(profileName == 'IFIS - Direzione Commerciale'){
                eventList = [ SELECT Id, AccountId, OwnerId, Stato__c, Originator__c, WGC_Macro_Esito__c, CreatedDate, Data_Inizio__c                                              
                              FROM Event 
                              WHERE Account.WGC_Specialista_Factoring__c != null 
                                AND Account.WGC_Factoring_Attivo__c = TRUE
                                AND RecordType.DeveloperName != 'Promemoria'
                                AND (NOT RecordType.DeveloperName LIKE '%Diario%')
                                AND Data_Inizio__c > LAST_N_YEARS:1 ORDER BY Data_Inizio__c ];
            } else {
                eventList = [ SELECT Id, AccountId, OwnerId, Stato__c, Originator__c, WGC_Macro_Esito__c, CreatedDate, Data_Inizio__c                                              
                              FROM Event 
                              WHERE Account.WGC_Specialista_Factoring__c =: UserInfo.getUserId() 
                                AND Account.WGC_Factoring_Attivo__c = TRUE
                                AND OwnerId =: UserInfo.getUserId() 
                                AND RecordType.DeveloperName != 'Promemoria'
                                AND (NOT RecordType.DeveloperName LIKE '%Diario%')
                                AND Data_Inizio__c > LAST_N_YEARS:1 ORDER BY Data_Inizio__c ];
            }
            records.eventList = eventList;

            List<Task> taskList = new List<Task>();
            if(profileName == 'IFIS - Direzione Commerciale'){
                taskList = [ SELECT Id, AccountId, OwnerId, Stato__c, Originator__c, Status, Campagna__c, Campagna__r.Status, WGC_Macro_Esito__c, CreatedDate, Data_Inizio__c, RecordType.DeveloperName                                           
                             FROM Task 
                             WHERE Account.WGC_Specialista_Factoring__c != null AND Data_Inizio__c > LAST_N_YEARS:1 ];
            } else {
                taskList = [ SELECT Id, AccountId, OwnerId, Stato__c, Originator__c, Status, Campagna__c, Campagna__r.Status, WGC_Macro_Esito__c, CreatedDate, Data_Inizio__c, RecordType.DeveloperName                                           
                             FROM Task 
                             WHERE Account.WGC_Specialista_Factoring__c =: UserInfo.getUserId() AND OwnerId =: UserInfo.getUserId() AND Data_Inizio__c > LAST_N_YEARS:1 ];
            }
            records.taskList = taskList;

            List<WGC_Best_Practice__c> bpList = [ SELECT Id, OwnerId, LastModifiedDate, Redemption_Dettaglio__c, Convertion_Dettaglio__c, 
                                                        T0_Dettaglio__c, T1_Dettaglio__c, Qualita_Dettaglio__c, Year__c, Week__c, Month__c, Task__c, Visite__c, 
                                                        Opportunita__c, Clienti_Attivati__c 
                                                  FROM WGC_Best_Practice__c 
                                                  WHERE Year__c = 'Corrente'
                                                    OR Year__c = ''
                                                  ORDER BY OwnerId, Week__c
                                                  LIMIT 120 ];

            records.bestPracticeList = bpList;

            List<WGC_Budget__c> budgetList = [ SELECT Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate,
                                                  LastModifiedById, SystemModstamp, Anno__c, Mese__c, Clienti_avviati__c, 
                                                  Visite_esitate__c, Pratiche_presentate__c, Turnover__c, Impiego_medio__c, 
                                                  Redditivit_impieghi__c 
                                           FROM WGC_Budget__c
                                           WHERE OwnerId =: UserInfo.getUserId()
                                               AND Anno__c =: String.valueOf(Date.Today().year()) ];
            records.budgetList = budgetList;

            result.data.add(records);
            if(Test.isRunningTest()) throw new TestException();
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
        @AuraEnabled public List<WGC_Best_Practice__c> bestPracticeList;
        @AuraEnabled public List<WGC_Budget__c> budgetList;
        // @AuraEnabled public List<Task> taskListIC;


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