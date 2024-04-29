/*********************************************
 * Name             :   OnIdentityDocumentTrigger
 * Creation Date    :   2023-04-13
 * Author           :   Alessandro Di Nardo @TEN
 * Description      :   trigger OnIdentityDocumentTrigger on IdentityDocument call method "handleAfterInsert" in trigger Handler "OnIdentityDocumentTriggerHandler"
 **********************************************/

trigger OnIdentityDocumentTrigger on IdentityDocument (after insert) {

     
    Funzionalita__c f = Funzionalita__c.getInstance();
    if (f.Disable_Trigger__c) return;

    if(trigger.isInsert){
        
        if(trigger.isAfter){

            System.debug('IdentityDocument INSERT TRIGGER AFTER');
            OnIdentityDocumentTriggerHandler.handleAfterInsert(Trigger.new);
        
        }

    }
   

}