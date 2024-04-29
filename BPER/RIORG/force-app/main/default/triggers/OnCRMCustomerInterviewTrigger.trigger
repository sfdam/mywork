trigger OnCRMCustomerInterviewTrigger on CRM_CustomerInterview__c (after insert, after update) {
    if(trigger.isInsert){
        if(trigger.isBefore){
            System.debug('SV CRM_Claims__c INSERT trigger.isBefore');

        }
        
        if(trigger.isAfter){
            System.debug('SV CRM_Claims__c INSERT trigger.isAfter');
            OnCRMCustomerInterviewTriggerHandler.trackHistory(Trigger.oldMap, Trigger.newMap);

        }        
    }
    
    if(trigger.isUpdate){
        if(trigger.isBefore){
            System.debug('SV CRM_Claims__c UPDATE trigger.isBefore');

        }
        
        if(trigger.isAfter){
            System.debug('SV CRM_Claims__c UPDATE trigger.isAfter');
            OnCRMCustomerInterviewTriggerHandler.trackHistory(Trigger.oldMap, Trigger.newMap);

        }
    }

}