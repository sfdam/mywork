trigger QuoteTrigger on SBQQ__Quote__c (before insert, before update, after insert, after update, before delete, after delete, after undelete) {
    
    if(!QuoteTriggerHandler.skipTrigger){

        if(Trigger.isInsert && Trigger.isBefore){
            System.debug('DK START QuoteTrigger_BeforeInsert');
            QuoteTriggerHandler.setPrintLabelDefaults_BeforeInsert(Trigger.new);
            QuoteTriggerHandler.manageLanguageChange(Trigger.new, Trigger.oldMap);
            //DK NEW
            QuoteTriggerHandler.handleBeforeInsert(Trigger.new);
            //DK NEW
            QuoteTriggerHandler.manageLegalInfo(Trigger.new, Trigger.oldMap);

        }
        if(Trigger.isInsert && Trigger.isAfter){
            System.debug('DK START QuoteTrigger_AfterInsert');
            SharepointHandler.sendQuotestoSharepoint(Trigger.newMap);
            QuoteTriggerHandler.skipTrigger = true;
        }
        if(Trigger.isUpdate && Trigger.isBefore){
            System.debug('DK START QuoteTrigger_BeforeUpdate');
            QuoteTriggerHandler.manageStatusChange(Trigger.new, Trigger.oldMap);
            QuoteTriggerHandler.lockRecordWhilePendingApproval(Trigger.new, Trigger.oldMap);
            QuoteTriggerHandler.manageLanguageChange(Trigger.new, Trigger.oldMap);
            QuoteTriggerHandler.manageOrderOCSignature(Trigger.new, Trigger.oldMap);
            //DK NEW
            QuoteTriggerHandler.handleBeforeUpdate(Trigger.newMap, Trigger.oldMap);
            QuoteTriggerHandler.manageLegalInfo(Trigger.new, Trigger.oldMap);

            //DK NEW
        }
    
        if(Trigger.isUpdate && Trigger.isAfter){
    
            System.debug('DK START QuoteTrigger_AfterUpdate');
            QuoteTriggerHandler.autoStartApprovalProcess(Trigger.new);
            QuoteTriggerHandler.skipTrigger = true;
        }
    }
}