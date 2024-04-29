trigger OnSerTrigger on SER__c (before update, after update, after insert) {
    /* if(trigger.isInsert){
         SharepointHandler.sendSERtoSharepoint(trigger.newMap,trigger.oldMap);
     } */
     if(trigger.isUpdate){
         if(trigger.isBefore){
             OnSerTriggerHandler.manageSerBeforeUpdate(trigger.oldMap,trigger.newMap);
             //SharepointHandler.UpdateSharepointLink(trigger.newMap,trigger.oldMap);
         }  
         if(trigger.isAfter){
             system.debug('sono in after update');
             OnSerTriggerHandler.manageSerAfterUpdate(trigger.oldMap,trigger.newMap);
             SharepointHandler.sendSERtoSharepoint(trigger.newMap,trigger.oldMap);
         }  
     }
     
 
 }