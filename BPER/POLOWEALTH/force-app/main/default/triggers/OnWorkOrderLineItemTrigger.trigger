trigger OnWorkOrderLineItemTrigger on WorkOrderLineItem (after insert, before update, after update, before delete) {
    
    Funzionalita__c f = Funzionalita__c.getInstance();
    if (f.Disable_Trigger__c) return;
    if (f.Disable_WorkOrderTrigger__c) return;

    if(trigger.isInsert){

        if(trigger.isAfter){

            System.debug('DK WorkOrder UPDATE trigger.isBefore');
            System.debug('DK trigger.New: ' + JSON.serialize(Trigger.new));
            OnWorkOrderLineItemTriggerHandler.handleAfterInsert(Trigger.new);
        }
    }

    if(trigger.isUpdate){

        if(trigger.isBefore){
            System.debug('DK WorkOrder UPDATE trigger.isBefore');
            System.debug('DK trigger.New: ' + JSON.serialize(Trigger.new));
            System.debug('DK trigger.oldMap: ' + JSON.serialize(Trigger.oldMap));
            OnWorkOrderLineItemTriggerHandler.handleBeforeUpdate(Trigger.new, Trigger.oldMap);
        }

        if(trigger.isAfter){
            System.debug('DK WorkOrder UPDATE trigger.isAfter');
            System.debug('DK trigger.New: ' + JSON.serialize(Trigger.new));
            System.debug('DK trigger.oldMap: ' + JSON.serialize(Trigger.oldMap));
            OnWorkOrderLineItemTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
            OnWorkOrderLineItemTriggerHandler.closeWorkOrder(Trigger.new, Trigger.oldMap);
        }
    }

    if(trigger.isDelete){

        if(trigger.isBefore){
            System.debug('SV Wallet UPDATE trigger.isBefore');
            OnWorkOrderLineItemTriggerHandler.handleBeforeDelete(Trigger.old);
        }
    }
}