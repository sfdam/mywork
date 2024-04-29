/*
 * @description       : Avoid to delete caseItem if Related Case Status is 'In Approval' OR 'Authorized' OR  'Cancelled' OR 'Closed' 
  						Showing The same "THR_CaseItemUpdateCreatePermission" validation rule error message


 * @author            : eleonora.caravello@accenture.com
 * TestClass		  : THR_CreateCaseItemsControlle_Test
 * @group             : 
 * @last modified on  : 10-30-2020
 * @last modified by  : eleonora.caravello@accenture.com
 * Modifications Log 
 * Ver   Date         Author                           Modification
 * 1.0   2020-10-30   eleonora.caravello@accenture.com   Initial Version

*/

trigger BeforeDeleteCaseItemTrigger on THR_Related_Object__c (before delete) {

    public static final String ERRORSTRING = System.Label.CaseItemDeleteError;

    if(Trigger.isBefore && Trigger.isDelete){

        /* set<Id> cItemToDeleteIdSet = new Set<Id>();
         for(THR_Related_Object__c eachCaseItem : Trigger.old) {
             cItemToDeleteIdSet.add(eachCaseItem.id);
         } */

        User runningUser = [SELECT Id, Alias FROM User WHERE Id = :UserInfo.getUserId()];

        for(THR_Related_Object__c eachCaseItem :  [
                SELECT Id, Name, THR_Case_Related__c, THR_Case_Related__r.Status
                FROM THR_Related_Object__c
                WHERE Id IN :Trigger.old] ){

                if('In Approval'.equalsIgnoreCase(eachCaseItem.THR_Case_Related__r.Status) || 'Authorized'.equalsIgnoreCase(eachCaseItem.THR_Case_Related__r.Status) || 'Cancelled'.equalsIgnoreCase(eachCaseItem.THR_Case_Related__r.Status) || 'Closed'.equalsIgnoreCase(eachCaseItem.THR_Case_Related__r.Status)) {
                    if(runningUser.Alias != 'mcocc' && runningUser.Alias != 'mcove') {
                        Trigger.oldMap.get(eachCaseItem.Id).addError(ERRORSTRING);
                    }
                }
        }
    }
}