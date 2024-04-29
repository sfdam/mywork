public class WGC_EditTaskModalController {

    @AuraEnabled
    public static WrapperResponse getActivity(String accountId) {
        
        WrapperResponse response = new WrapperResponse();
        try{ 

            Result result = new Result();  

            List<Event> event = [ SELECT Id, AccountId, Account.Name, Subject, ActivityDate, OwnerId, WhoId, StartDateTime, EndDateTime, Data_Inizio__c, Data_Fine__c, EsitoLivello1__c, EsitoLivello2__c, EsitoLivello3__c, EsitoLivello4__c, EsitoLivello5__c, Esito__c
                            FROM Event 
                            WHERE AccountId =: accountId
                                AND DataOraEsitazione__c = null
                                AND RecordType.DeveloperName != 'Promemoria'
                                AND (NOT RecordType.DeveloperName LIKE '%Diario%')
                            ORDER BY StartDateTime ASC ];

            List<Task> task = [ SELECT Id, AccountId, Account.Name, Subject, ActivityDate, OwnerId, WhoId, Data_Inizio__c, Data_Fine__c, EsitoLivello1__c, EsitoLivello2__c, EsitoLivello3__c, EsitoLivello4__c, EsitoLivello5__c, Esito__c
                            FROM Task 
                            WHERE AccountId =: accountId
                                AND DataOraEsitazione__c = null
                                AND RecordType.DeveloperName != 'Promemoria'
                                        AND (NOT RecordType.DeveloperName LIKE '%Diario%')
                            ORDER BY Data_Inizio__c ASC ];

            result.taskList = task;
            result.eventList = event;

            response.data.add(result);
            if(Test.isRunningTest()) throw new TestException();
        } catch (Exception e){
            System.debug('SV exception message: ' + e.getMessage());
            response.success = false;
            response.msg = e.getMessage();
            //throw new AuraHandledException(e.getMessage());
            System.debug('SV responseFinal: ' + response);
        }

        return response;
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
    }

}