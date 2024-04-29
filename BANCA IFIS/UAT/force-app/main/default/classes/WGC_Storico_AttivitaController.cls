public class WGC_Storico_AttivitaController {

    @AuraEnabled
    public static WrapperResponse getAllData(String accId) {

        WrapperResponse result = new WrapperResponse();
        WrapperRecords records = new WrapperRecords();
        
        try{
            
            List<Task> taskList = [SELECT Id, Subject, CreatedDate, ActivityDate, Recordtype.Developername, Owner.Name, Data_Inizio__c, Data_Fine__c, WGC_Qualifica_Utente_Owner__c, WGC_Ruolo__c, TipoAttivita__c, Originator__c, Originator_di_dettaglio__c, EsitoLivello1__c, EsitoLivello2__c, CommentiEsito__c, WGC_Macro_Esito__c, Description, IsArchived, Campagna__c, Campagna__r.Name, WGC_Opportunita__c, WGC_Opportunita__r.Name FROM Task WHERE AccountId =: accId AND (IsArchived = TRUE OR IsArchived = FALSE) ALL ROWS ];
            records.taskList = taskList;

            List<Event> eventList = [SELECT Id, Subject, CreatedDate, ActivityDate, Recordtype.Developername, Owner.Name, Data_Inizio__c, Data_Fine__c, WGC_Qualifica_Utente_Owner__c, WGC_Ruolo__c, TipoAttivita__c, Originator__c, Originator_di_dettaglio__c, EsitoLivello1__c, EsitoLivello2__c, CommentiEsito__c, WGC_Macro_Esito__c, Description, IsArchived FROM Event WHERE AccountId =: accId AND (IsArchived = TRUE OR IsArchived = FALSE) ALL ROWS ];
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
        return [ SELECT Id, Name, Qualifica_Utente__c FROM User WHERE Id =: UserInfo.getUserId() ];
        
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