public class TXT_CreateActivityController {

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
     @AuraEnabled
     public static Boolean createNewTask( String dueDate, string DueTime,  String user_id, String what_id, String sObjectName, String title, String note, String Status, String Descrizione_Attivita, String Note_Attivita, String Motivazione_chiamata, String Esito_Chiamata ){
        system.debug('dueDate: '+dueDate);
        system.debug('DueTime: '+DueTime);
        system.debug('user_id: '+user_id);
        system.debug('what_id: '+what_id);
        system.debug('sObjectName: '+sObjectName);
        system.debug('title: '+title);
        system.debug('note: '+note);

        User currUser = [SELECT Id, Name, Societa__c FROM User WHERE Id =: user_id LIMIT 1];
        
        Task t = new Task();
        t.ActivityDate = Date.valueOf(dueDate);
        String[] dueTimeSplit = DueTime.split(':');
        Time taskTime = Time.newInstance( Integer.valueOf(dueTimeSplit[0]), //hour
                                            Integer.valueOf(dueTimeSplit[1]), //min
                                            0,                                //sec
                                            0);
        t.Ora__c = taskTime;
        t.Subject = title;
        t.Status = Status;
         t.Descrizione_Attivita__c = Descrizione_Attivita;
         t.Note_Attivita__c = Note_Attivita;
         t.Motivazione_chiamata__c = Motivazione_chiamata;
         t.Esito_Chiamata__c = Esito_Chiamata;
        t.Description = note;
        t.OwnerId = user_id;
        
        if( sObjectName == 'Lead' || sObjectName == 'Contact' ){
            t.whoId = what_id;  
        }
        else{
            t.whatId = what_id; 
        }   

        system.debug('t :'+ t);    
        INSERT t;
        return t.Id != null;
    }
    @AuraEnabled
    public static Boolean createNewEvent( Datetime start_time, Datetime end_time, String user_id, String what_id, String title, String note, String sObjectName){
        system.debug('start_time: '+start_time);
        system.debug('end_time: '+end_time);
        system.debug('user_id: '+user_id);
        system.debug('what_id: '+what_id);
        system.debug('sObjectName: '+sObjectName);
        system.debug('title: '+title);
        system.debug('note: '+note);
        
        User currUser = [SELECT Id, Name, Societa__c FROM User WHERE Id =: user_id LIMIT 1];
        
        Event e = new Event();
        e.StartDateTime = DateTime.valueOf(start_time);
        e.EndDateTime = DateTime.valueOf(end_time);

        e.Description = note;
        e.OwnerId = user_id;
        e.Subject=title;
        
        if( sobjectName == 'Lead' || sobjectName == 'Contact' ){
            e.whoId = what_id;  
        }
        else{
            e.whatId = what_id; 
        }       
        INSERT e;
        return e.Id != null;
    }
    
    public class WrapperRecords {


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