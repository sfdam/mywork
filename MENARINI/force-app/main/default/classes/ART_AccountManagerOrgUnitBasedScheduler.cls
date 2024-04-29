//@TestClass: ART_AccountManagerOrgUnitBasedSched_Test
global without sharing class ART_AccountManagerOrgUnitBasedScheduler implements Schedulable{
    global void execute(System.SchedulableContext sc) {
        Database.executeBatch(new cgcloud.AccountManagerOrgUnitBased(), 1);
    }
}