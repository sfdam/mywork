public class TXT_CalendarCustomController {
    @AuraEnabled
    public static User getUserInfo() {
        return [ SELECT Id, Name, Societa__c FROM User WHERE Id =: UserInfo.getUserId() ];
        
    }
    
    

    /*..........................................*/
    /* Wrapper class to display Position       */
    /*.........................................*/
    /*
    public class WrapperRecords {

        @AuraEnabled public List<Task> taskList;
        @AuraEnabled public List<Event> eventList;
        @AuraEnabled public List<Contact> contactList;

    }
	*/
    /*..........................................*/
    /* Wrapper class to display Response       */
    /*.........................................*/
    /*
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
	*/
}