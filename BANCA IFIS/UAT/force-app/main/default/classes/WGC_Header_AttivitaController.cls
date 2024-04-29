public class WGC_Header_AttivitaController {

    @AuraEnabled
    public static WrapperResponse getActivityUser(){

        WrapperResponse responseFinal = new WrapperResponse();
        try{
            Result result = new Result();        
            
            List<Event> event = [ SELECT Id, AccountId, Account.Name, Subject, ActivityDateTime, OwnerId, WhoId, StartDateTime, EndDateTime, Data_Inizio__c, Data_Fine__c, EsitoLivello1__c, EsitoLivello2__c, EsitoLivello3__c, EsitoLivello4__c, EsitoLivello5__c, Esito__c
                            FROM Event 
                            WHERE ActivityDateTime >= LAST_N_MONTHS:12
                                AND OwnerId =: UserInfo.getUserId() 
                                AND (
                                        (Account.WGC_Specialista_Factoring__c =: UserInfo.getUserId())
                                        OR (Account.WGC_Specialista_Leasing__c =: UserInfo.getUserId())
                                        OR (Account.WGC_Specialista_Crediti_Erariali__c =: UserInfo.getUserId())
                                        OR (Account.WGC_Specialista_IFIS_Finance__c =: UserInfo.getUserId())
                                        OR (Account.WGC_Specialista_Finanza_Strutturata__c =: UserInfo.getUserId())
                                        OR (Account.WGC_Specialista_Filo_Diretto__c =: UserInfo.getUserId())
                                        OR (Account.WGC_Specialista_IFIS_International__c =: UserInfo.getUserId())
                                      )
                                AND EsitoLivello1__c = null
                                AND WhatId != null
                            ORDER BY StartDateTime ASC ];

            
            List<Task> task = [ SELECT Id, AccountId, Account.Name, Subject, ActivityDate, OwnerId, Owner.Name, WhoId, Data_Inizio__c, Data_Fine__c, Status, RecordType.DeveloperName
                            FROM Task 
                            WHERE Data_Inizio__c >= LAST_N_MONTHS:12
                                AND OwnerId =: UserInfo.getUserId()
                                AND (
                                        (Account.WGC_Specialista_Factoring__c =: UserInfo.getUserId())
                                        OR (Account.WGC_Specialista_Leasing__c =: UserInfo.getUserId())
                                        OR (Account.WGC_Specialista_Crediti_Erariali__c =: UserInfo.getUserId())
                                        OR (Account.WGC_Specialista_IFIS_Finance__c =: UserInfo.getUserId())
                                        OR (Account.WGC_Specialista_Finanza_Strutturata__c =: UserInfo.getUserId())
                                        OR (Account.WGC_Specialista_Filo_Diretto__c =: UserInfo.getUserId())
                                        OR (Account.WGC_Specialista_IFIS_International__c =: UserInfo.getUserId())
                                      )
                                AND EsitoLivello1__c = null
                                AND RecordType.DeveloperName != 'Promemoria'
                                AND (NOT RecordType.DeveloperName LIKE '%Diario%')
                                AND RecordType.DeveloperName != 'Previsione_Avvio_Rapporto'
                                AND RecordType.DeveloperName != 'Segnalazione'
                            ORDER BY ActivityDate ASC ];


            List<Opportunity> opp = [SELECT Id, AccountId, Account.Name, Name, StageName, CloseDate, IsClosed, IsWon, Data_Inizio__c, Data_Fine__c, Data_flow__c 
                            FROM Opportunity 
                            WHERE IsClosed = false
                            AND OwnerId =: UserInfo.getUserId() 
                            ORDER BY Data_Inizio__c ASC];


            result.eventList = event;
            result.taskList = task;
            result.opportunityList = opp;
            responseFinal.data.add(result);

            if(Test.isRunningTest()) throw new TestException();

        } catch (Exception e){
            System.debug('SV exception message: ' + e.getMessage());
            responseFinal.success = false;
            responseFinal.msg = e.getMessage();
            //throw new AuraHandledException(e.getMessage());
            System.debug('SV responseFinal: ' + responseFinal);
        }

        return responseFinal;
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

    public class Result {
        @AuraEnabled public List<Task> taskList;
        @AuraEnabled public List<Event> eventList;
        @AuraEnabled public List<Opportunity> opportunityList;
    }

}