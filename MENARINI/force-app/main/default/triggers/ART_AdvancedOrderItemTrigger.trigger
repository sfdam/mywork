trigger ART_AdvancedOrderItemTrigger on cgcloud__Order_Item__c (before insert, before update, after insert, after update, after delete) {
    
    System.debug('***** SONO NEL TRIGGER DEGLI ORDER ITEM Trigger');
    
    if(Trigger.IsBefore && Trigger.isInsert){
        ART_AdvancedOrderItemTriggerHandler.setRowIndex(Trigger.New);
    }
    if(Trigger.isAfter && Trigger.isDelete){
        ART_AdvancedOrderItemTriggerHandler.resetRowsIndexAfterDelete(Trigger.Old);
    }
}