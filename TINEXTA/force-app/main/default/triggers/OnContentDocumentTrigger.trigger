trigger OnContentDocumentTrigger on ContentDocument (after update) {

    Funzionalita__c f = Funzionalita__c.getInstance();
    if (f.Disabilita_tutti_i_trigger__c)return;

    if(trigger.isInsert){
        if(trigger.isAfter){
            System.debug('SV ContentDocument INSERT trigger.isAfter');
            // OnContentDocumentTriggerHandler.makeCallContentDocument(Trigger.New);
        }        
    }

    if(trigger.isUpdate){
        if(trigger.isAfter){
            System.debug('SV ContentDocument UPDATE trigger.isUpdate');
            OnContentDocumentTriggerHandler.makeCallContentDocument(Trigger.New);
        }        
    }
    
}