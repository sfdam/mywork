trigger OnFinServAlertTrigger on FinServ__Alert__c (after insert, after update) {
    if(trigger.isInsert){
        if(trigger.isBefore){
            System.debug('SV FinServ__Alert__c INSERT trigger.isBefore');

        }
        
        if(trigger.isAfter){
            System.debug('SV FinServ__Alert__c INSERT trigger.isAfter');
            OnFinServAlertTriggerHandler.trackHistory(Trigger.oldMap, Trigger.newMap);

        }        
    }
    
    if(trigger.isUpdate){
        if(trigger.isBefore){
            System.debug('SV FinServ__Alert__c UPDATE trigger.isBefore');

        }
        
        if(trigger.isAfter){
            System.debug('SV FinServ__Alert__c UPDATE trigger.isAfter');
            OnFinServAlertTriggerHandler.trackHistory(Trigger.oldMap, Trigger.newMap);

        }
    }

}