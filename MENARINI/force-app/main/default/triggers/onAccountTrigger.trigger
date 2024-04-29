/* 

Created by: Lorenzo Vento 05-12-2022

Last modified by: Lorenzo Vento 05-12-2022

*/

trigger onAccountTrigger on Account (after insert, before update) {

    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            onAccountTriggerHandler.afterInsert(Trigger.NewMap);
        }
    }
    if (Trigger.isBefore) {
        if (Trigger.isUpdate) {
            onAccountTriggerHandler.beforeUpdate(Trigger.OldMap, Trigger.NewMap);
        }
    }
}