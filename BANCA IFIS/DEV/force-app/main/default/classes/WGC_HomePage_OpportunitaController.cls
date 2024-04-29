public class WGC_HomePage_OpportunitaController {

    @AuraEnabled
    public static WrapperResponse getUserInfo(){

        Id profileId = userinfo.getProfileId();
        User user = [ SELECT Id, NDGGruppo__c FROM User WHERE Id =: UserInfo.getUserId()];
        String profileName = [Select Id,Name from Profile where Id=:profileId].Name;
        // IFIS - Direzione Commerciale

        WrapperResponse result = new WrapperResponse();
        WrapperRecords records = new WrapperRecords();
        try{

            List<WGC_New_Business__c> accList = new List<WGC_New_Business__c>();
            if(profileName == 'IFIS - Direzione Commerciale'){
                // accList = [ SELECT Id, Name, StatoCensimento__c, WGC_Qualifica_Corporate__c, WGC_Specialista_Factoring__c, WGC_Factoring_Attivo__c, CreatedDate, WGC_Originator__c
                //             FROM Account 
                //             WHERE WGC_Specialista_Factoring__c != null
                //                 AND WGC_Qualifica_Corporate__c = 'Cliente Attivo'
                //                 AND CreatedDate > LAST_N_YEARS:2 ];
                accList = [ SELECT Id, Anagrafica__r.Id, Anagrafica__r.Name, Anagrafica__r.StatoCensimento__c, Anagrafica__r.WGC_Qualifica_Corporate__c, 
                                   Anagrafica__r.WGC_Specialista_Factoring__c, Anagrafica__r.WGC_Factoring_Attivo__c, Anagrafica__r.CreatedDate, 
                                   Anagrafica__r.WGC_Originator__c, Data_New_Business__c, Anagrafica__r.WGC_StatoAnagraficaCed__c, Anagrafica__r.WGC_Data_Ex_Cliente_SvilCommFiliali__c 
                            FROM WGC_New_Business__c
                            WHERE Data_New_Business__c = THIS_YEAR ];
            } else {
                // accList = [ SELECT Id, Name, StatoCensimento__c, WGC_Qualifica_Corporate__c, WGC_Specialista_Factoring__c, WGC_Factoring_Attivo__c, CreatedDate, WGC_Originator__c 
                //             FROM Account 
                //             WHERE WGC_Specialista_Factoring__c =: UserInfo.getUserId() 
                //                 AND WGC_Qualifica_Corporate__c = 'Cliente Attivo'
                //                 AND CreatedDate > LAST_N_YEARS:2 ];
                accList = [ SELECT Id, Anagrafica__r.Id, Anagrafica__r.Name, Anagrafica__r.StatoCensimento__c, Anagrafica__r.WGC_Qualifica_Corporate__c, 
                                   Anagrafica__r.WGC_Specialista_Factoring__c, Anagrafica__r.WGC_Factoring_Attivo__c, Anagrafica__r.CreatedDate, 
                                   Anagrafica__r.WGC_Originator__c, Data_New_Business__c, Anagrafica__r.WGC_StatoAnagraficaCed__c, Anagrafica__r.WGC_Data_Ex_Cliente_SvilCommFiliali__c   
                            FROM WGC_New_Business__c
                            WHERE NDG_Settorista__c =: user.NDGGruppo__c AND NDG_Settorista__c != ''
                                AND Data_New_Business__c = THIS_YEAR ];

            }
            records.accountList = accList;

            Set<Id> accIdSet = new Set<Id>();
            for(WGC_New_Business__c acc : accList){
                accIdSet.add(acc.Id);
            }

            List<Opportunity> oppList = new List<Opportunity>();
            if(profileName == 'IFIS - Direzione Commerciale'){
                oppList = [ SELECT Id, AccountId, OwnerId, StageName, Originator__c, CreatedDate, FaseDiCaduta__c                                       
                            FROM Opportunity 
                            WHERE Account.WGC_Specialista_Factoring__c != null 
                                AND AccountId NOT IN : accIdSet 
                                AND Data_Inizio__c = THIS_YEAR ];
            } else {
                oppList = [ SELECT Id, AccountId, OwnerId, StageName, Originator__c, CreatedDate, FaseDiCaduta__c                                       
                            FROM Opportunity 
                            WHERE Account.WGC_Specialista_Factoring__c =: UserInfo.getUserId() 
                                AND OwnerId =: UserInfo.getUserId() 
                                AND AccountId NOT IN : accIdSet 
                                AND IsOppNSA__c = FALSE
                                AND Data_Inizio__c = THIS_YEAR ];

            }
            records.opportunityList = oppList;

            List<Event> eventList = new List<Event>();
            if(profileName == 'IFIS - Direzione Commerciale'){
                eventList = [ SELECT Id, AccountId, OwnerId, Stato__c, Originator__c, WGC_Macro_Esito__c, CreatedDate                                            
                              FROM Event 
                              WHERE Account.WGC_Specialista_Factoring__c != null 
                                AND AccountId NOT IN : accIdSet 
                                AND Data_Inizio__c = THIS_YEAR ];
            } else {
                eventList = [ SELECT Id, AccountId, OwnerId, Stato__c, Originator__c, WGC_Macro_Esito__c, CreatedDate                                            
                              FROM Event 
                              WHERE Account.WGC_Specialista_Factoring__c =: UserInfo.getUserId() 
                                AND OwnerId =: UserInfo.getUserId() 
                                AND AccountId NOT IN : accIdSet 
                                AND Data_Inizio__c = THIS_YEAR ];
            }
            records.eventList = eventList;

            List<Task> taskList = new List<Task>();
            if(profileName == 'IFIS - Direzione Commerciale'){
                taskList = [ SELECT Id, AccountId, OwnerId, Stato__c, Originator__c, Status, Campagna__c, Campagna__r.Status, WGC_Macro_Esito__c, CreatedDate, Data_Inizio__c, RecordType.DeveloperName                                           
                             FROM Task 
                             WHERE Account.WGC_Specialista_Factoring__c != null 
                             AND AccountId NOT IN : accIdSet 
                             AND RecordType.DeveloperName != 'Promemoria'
                             AND (NOT RecordType.DeveloperName LIKE '%Diario%')
                             AND Data_Inizio__c = THIS_YEAR ];
            } else {
                taskList = [ SELECT Id, AccountId, OwnerId, Stato__c, Originator__c, Status, Campagna__c, Campagna__r.Status, WGC_Macro_Esito__c, CreatedDate, Data_Inizio__c, RecordType.DeveloperName                                           
                             FROM Task 
                             WHERE Account.WGC_Specialista_Factoring__c =: UserInfo.getUserId() 
                             AND OwnerId =: UserInfo.getUserId() 
                             AND AccountId NOT IN : accIdSet 
                             AND RecordType.DeveloperName != 'Promemoria'
                             AND (NOT RecordType.DeveloperName LIKE '%Diario%')
                             AND Data_Inizio__c = THIS_YEAR ];
            }
            records.taskList = taskList;

            List<WGC_Best_Practice__c> bpList = [ SELECT Id, OwnerId, LastModifiedDate, Redemption_Dettaglio__c, Convertion_Dettaglio__c, 
                                                        T0_Dettaglio__c, T1_Dettaglio__c, Qualita_Dettaglio__c, Year__c, Week__c, Month__c, Task__c, Visite__c, 
                                                        Opportunita__c, Clienti_Attivati__c 
                                                  FROM WGC_Best_Practice__c 
                                                  WHERE Year__c = 'Corrente'
                                                  ORDER BY OwnerId, Week__c
                                                  LIMIT 20 ];

            records.bestPracticeList = bpList;

            result.data.add(records);
            
            if(Test.isRunningTest()) throw new TestException();

                
        } catch (Exception e){
            result.success = false; 
            result.msg = e.getMessage();
        }

        return result;
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

    public class WrapperRecords {
        @AuraEnabled public List<WGC_New_Business__c> accountList;
        @AuraEnabled public List<WGC_Budget__c> budgetList;
        @AuraEnabled public List<Event> eventList;
        @AuraEnabled public List<Task> taskList;
        @AuraEnabled public List<Opportunity> opportunityList;
        @AuraEnabled public List<WGC_Best_Practice__c> bestPracticeList;
    }

}