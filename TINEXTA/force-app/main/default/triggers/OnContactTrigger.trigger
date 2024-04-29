trigger OnContactTrigger on Contact (after insert, after update/*, after delete*/) {

    if(Trigger.isAfter && Trigger.isInsert){
        OnContactTriggerHandler.checkContitolaritaDatiAccount(Trigger.newMap, null ,false);
    }

    if(Trigger.isAfter && Trigger.isUpdate){
        OnContactTriggerHandler.checkContitolaritaDatiAccount(Trigger.newMap, trigger.oldmap, true);
    }

    // if(Trigger.isAfter && Trigger.isDelete){
    //     OnContactTriggerHandler.checkContitolaritaDatiAccount(Trigger.oldMap);
    // }
}