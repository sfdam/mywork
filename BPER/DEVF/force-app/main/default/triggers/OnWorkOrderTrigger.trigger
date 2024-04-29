trigger OnWorkOrderTrigger on WorkOrder (after insert, before update, after update, before delete) {

    Funzionalita__c f = Funzionalita__c.getInstance();
    if (f.Disable_Trigger__c) return;
    if (f.Disable_WorkOrderTrigger__c) return;
    
    if(trigger.isInsert){

        if(trigger.isAfter){

            System.debug('DK WorkOrder UPDATE trigger.isBefore');
            System.debug('DK trigger.New: ' + JSON.serialize(Trigger.new));
            OnWorkOrderTriggerHandler.handleAfterInsert(Trigger.new);
        }
    }

    if(trigger.isUpdate){

        if(trigger.isBefore){
            System.debug('DK WorkOrder UPDATE trigger.isBefore');
            System.debug('DK trigger.New: ' + JSON.serialize(Trigger.new));
            System.debug('DK trigger.oldMap: ' + JSON.serialize(Trigger.oldMap));
            OnWorkOrderTriggerHandler.handleBeforeUpdate(Trigger.new, Trigger.oldMap);
        }

        if(trigger.isAfter){
            System.debug('DK WorkOrder UPDATE trigger.isAfter');
            System.debug('DK trigger.New: ' + JSON.serialize(Trigger.new));
            System.debug('DK trigger.oldMap: ' + JSON.serialize(Trigger.oldMap));
            OnWorkOrderTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
            OnWorkOrderTriggerHandler.closeWorkOrder(Trigger.new, Trigger.oldMap);
        }
    }

    if(trigger.isDelete){

        if(trigger.isBefore){
            System.debug('SV Wallet UPDATE trigger.isBefore');
            OnWorkOrderTriggerHandler.handleBeforeDelete(Trigger.old);
        }
    }
}