trigger OnWalletTrigger on Wallet__c (before insert, after insert, before update, after update, before delete) {
    
    Funzionalita__c f = Funzionalita__c.getInstance();
    if (f.Disable_Trigger__c) return;
    if (f.Disable_WalletTrigger__c) return;
    //         System.debug('SV OnAssignmentTriggerHandler trafficLightTrigger: ' +OnAssignmentTriggerHandler.trafficLightTrigger);

     if (OnAssignmentTriggerHandler.trafficLightTrigger) {
        return;
    } 

    if(trigger.isInsert){
        
        if(trigger.isBefore){
            System.debug('SV Wallet INSERT trigger.isBefore');
            OnWalletTriggerHandler.setFields(Trigger.new, null);
            OnWalletTriggerHandler.handleBeforeInsert(Trigger.new);
        }
        
        if(trigger.isAfter){
            System.debug('SV Wallet INSERT trigger.isAfter');
            OnWalletTriggerHandler.handleAfterInsert(Trigger.new);
        }        
    }
    
    if(trigger.isUpdate){
        
        if(trigger.isBefore){
            System.debug('SV Wallet UPDATE trigger.isBefore');
            OnWalletTriggerHandler.setFields(Trigger.new, Trigger.oldMap);
            OnWalletTriggerHandler.handleMWBeforeUpdate(Trigger.newMap, Trigger.oldMap);
        }
        
        /*if(trigger.isAfter){
            System.debug('SV Wallet UPDATE trigger.isAfter');
            OnWalletTriggerHandler.buildMicroWalletName(Trigger.new);
        }*/
    }

    if(trigger.isDelete){

        if(trigger.isBefore){
            System.debug('SV Wallet UPDATE trigger.isBefore');
            OnWalletTriggerHandler.handleBeforeDelete(Trigger.old);
        }
    }
}