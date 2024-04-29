trigger OnWorkOrderTrigger on WorkOrder (before update, after update, after insert, before insert) 
{
    Funzionalita__c f = Funzionalita__c.getInstance();
    String recordTypeIper = Schema.SObjectType.WorkOrder.getRecordTypeInfosbyDeveloperName().get('WRT_Iper').getRecordTypeId();
    if (f.Disabilita_Trigger_WorkOrder__c)return;
    Map<Id, WorkOrder> cleanMap = new map<Id, workOrder>();

    //controllo per la ripetizione del trigger, usare con solo metodi della classe OnWorkOrderTriggerHandler
    if(!OnWorkOrderTriggerHandler.disableWorkOrderTrigger)
    {
        if(trigger.isUpdate)
        {
            if(trigger.isBefore)
            {
                OnWorkOrderTriggerHandler.checkWorkOrderLineItems(Trigger.NewMap, Trigger.OldMap);
                //OnWorkOrderTriggerHandler.reopenWoli(Trigger.newMap, Trigger.oldMap);
                //OnWorkOrderTriggerHandler.updateProductOpp(Trigger.newMap);
                
            }
            if(trigger.isAfter)
            {
                //OnWorkOrderTriggerHandler.sendWorkOrderAndTask(trigger.newMap);
                //OnWorkOrderTriggerHandler.updateProductOpp(Trigger.newMap);
                for(WorkOrder workOrder : Trigger.newMap.values()) {
                    if(workOrder.RecordTypeId == recordTypeIper) {
                        cleanMap.put(workOrder.Id, workOrder);
                    }
                }
                if(cleanMap.size() > 0 && cleanMap != null) {
                    OnWorkOrderTriggerHandler.assignSupplier(cleanMap);
                }
            }
        }
        if(trigger.isInsert)
        {
            if(trigger.isAfter)
            {
                /*for(WorkOrder workOrder : Trigger.newMap.values()) {
                    if(workOrder.RecordTypeId == recordTypeIper) {
                        cleanMap.put(workOrder.Id, workOrder);
                    }
                }
                if(cleanMap.size() > 0 && cleanMap != null) {
                    OnWorkOrderTriggerHandler.assignSupplier(cleanMap);
                }*/
            }
            if(trigger.isBefore)
            {
                //OnWorkOrderTriggerHandler.updateProductOpp(Trigger.newMap);
                //system.debug('before insert '+trigger.newmap);
                OnWorkOrderTriggerHandler.checkClone(Trigger.new);
            }
        }
    }
}