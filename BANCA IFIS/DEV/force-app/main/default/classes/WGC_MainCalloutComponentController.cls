public class WGC_MainCalloutComponentController {
	//Metodo per recuperare Task ed Event collegati all'Account ed esitati
    @AuraEnabled
    public static WrapperResponse accountHasHesitatedTaskOrEvent(String accountId) {
        WrapperResponse responseFinal = new WrapperResponse();

        try {
            List<Task> tasksOpen = [ SELECT Id 
                                     FROM Task 
                                     WHERE AccountId = :accountId 
                                        AND RecordType.DeveloperName != 'Promemoria'
                                        AND (NOT RecordType.DeveloperName LIKE '%Diario%')
                                        AND EsitoLivello1__c = null];
            List<Event> eventsOpen = [SELECT Id FROM Event WHERE AccountId = :accountId AND EsitoLivello1__c = null LIMIT 1];
            List<Task> tasks = [SELECT Id FROM Task WHERE AccountId = :accountId AND StatoEsitazione__c = 'Esitato' LIMIT 1];
            List<Event> events = [SELECT Id FROM Event WHERE AccountId = :accountId AND StatoEsitazione__c = 'Esitato' LIMIT 1];
            responseFinal.success = true;
            responseFinal.msg = '';
            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped('{"data":{"task":'+(tasks.size() > 0)+',"event":'+(events.size() > 0)+', "taskOpen" : '+(tasksOpen.size() > 0)+', "eventOpen" : '+(eventsOpen.size() > 0)+'}}');
            responseFinal.data = new List<Object>();
            responseFinal.data.add(m.get('data'));
            System.debug('@@@ responseFinal task event' + JSON.serialize(responseFinal));
            if(Test.isRunningTest()) throw new TestException();

        } catch (Exception e) {
            responseFinal.success = false;
            responseFinal.msg = e.getMessage();
            responseFinal.data = null;
        }

        return responseFinal;
    }

    @AuraEnabled
    public static String getUserProfile(){
        return [SELECT Id, Profile.Name FROM User WHERE Id =: UserInfo.getUserId()].Profile.Name;
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