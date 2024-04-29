/*
 * @author: @Lutech
 * @Created Date: 18/05/2022
 * @uses:
    *onWorkOrderTriggerHandler
 * @history:
    * Lutech - 18/05/2022: Task reopening management v1.0 
*/

trigger OnWorkOrderLineItemTrigger on WorkOrderLineItem (before update, after update) {
    Funzionalita__c f = Funzionalita__c.getInstance();
    if (f.Disabilita_Trigger_WorkOrderLineItems__c)
        return;

    if(trigger.isUpdate) {
        if(trigger.isAfter) {
            if(!OnWorkOrderLineItemTriggerHandler.disableWorkOrderLineItemTrigger) OnWorkOrderLineItemTriggerHandler.checkForStatusUpdating(Trigger.NewMap, Trigger.OldMap);
        }
    }
}