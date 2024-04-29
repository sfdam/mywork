public class TXT_Storico_AttivitaController {
 @AuraEnabled
    public static WrapperResponse getAllData(String accId, String societa) {

        WrapperResponse result = new WrapperResponse();
        WrapperRecords records = new WrapperRecords();
        
        try{

            List<Contact> contactList = [SELECT Id, AccountId, LastName, FirstName, Societa__c FROM Contact WHERE AccountId =: accId AND Societa__c =: societa ];
            records.contactList = contactList;

            Set<Id> contId = new Set<Id>();
            for(Contact c : contactList){
                contId.add(c.Id);
            }

            List<Task> taskList = [SELECT Id, Subject, CreatedDate, ActivityDate, OwnerId, Owner.Name, Description, Note_Attivita__c, Societa_Utente__c, Status, Priority, IsArchived FROM Task WHERE (Lead__c =: accId) AND Societa_Utente__c =: societa AND (IsArchived = TRUE OR IsArchived = FALSE) ALL ROWS ];
            records.taskList = taskList;

            List<Event> eventList = [SELECT Id, Subject, CreatedDate, ActivityDate, OwnerId, Owner.Name, Description, Note_Attivita__c, Societa_Utente__c, IsArchived FROM Event WHERE (Lead__c =: accId) AND Societa_Utente__c =: societa AND (IsArchived = TRUE OR IsArchived = FALSE) ALL ROWS ];
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
    public static User getUserInfo() {
        return [ SELECT Id, Name, Societa__c FROM User WHERE Id =: UserInfo.getUserId() ];
        
    }

    @AuraEnabled
    public static Map < String, String > getselectOptions(sObject objObject, string fld) {
        system.debug('objObject --->' + objObject);
        system.debug('fld --->' + fld);
        Map < String, String > allOpts = new Map < String, String > ();
        // Get the object type of the SObject.
        Schema.sObjectType objType = objObject.getSObjectType();
        
        // Describe the SObject using its object type.
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        
        // Get a map of fields for the SObject
        map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
        
        // Get the list of picklist values for this field.
        list < Schema.PicklistEntry > values =
            fieldMap.get(fld).getDescribe().getPickListValues();
        
        system.debug('values --->' + values);
        
        // Add these values to the selectoption list.
        for (Schema.PicklistEntry a: values) {
            allOpts.put(a.getLabel(), a.getValue());
        }
        system.debug('allOpts ---->' + allOpts);
        
        return allOpts;
    }

    /*..........................................*/
    /* Wrapper class to display Position       */
    /*.........................................*/
    
    public class WrapperRecords {

        @AuraEnabled public List<Task> taskList;
        @AuraEnabled public List<Event> eventList;
        @AuraEnabled public List<Contact> contactList;

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