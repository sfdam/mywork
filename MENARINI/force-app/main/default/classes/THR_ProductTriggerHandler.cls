public class THR_ProductTriggerHandler {

    public static void discontinuedProductSpain(Map<Id, Product2> newProductMap, Map<Id, Product2> oldProductMap) {
        System.debug('@@@ ProductTriggerHandler START');
        Set<Id> newProductIdSet = newProductMap.keySet();
        Set<Id> caseIds = new Set<Id>();
        List<Case> caseList = new List<Case>();
        List<THR_Related_Object__c> caseItemList = [
                SELECT Id, THR_Marketing_End_Date__c, THR_Product__c, THR_Case_Related__c,
                        THR_Case_Related__r.ContactId, THR_Case_Related__r.THR_Locked__c, THR_Case_Related__r.THR_Locked_Date__c, THR_Case_Related__r.THR_Contact__c
                FROM THR_Related_Object__c
                WHERE THR_Product__c IN :newProductIdSet
                AND THR_Marketing_End_Date__c = FALSE
                AND THR_Case_Related__r.Contact.Account.Name = 'PACIENTE GENERICO'
                AND THR_Case_Related__r.RecordType_Developer_Name__c = 'THR_Pharmacovigilance'];
        System.debug(caseItemList);

        if(!caseItemList.isEmpty()) {
            System.debug('@@@ CaseItemList is not empty');
            if(Test.isRunningTest()) {
                for (THR_Related_Object__c ci : caseItemList) {
                    if(oldProductMap.get(ci.THR_Product__c).IsActive == true && newProductMap.get(ci.THR_Product__c).IsActive == false) {
                        System.debug('@@@ Product WAS active, now is not');
                        ci.THR_Marketing_End_Date__c = true;
                        caseList.add(ci.THR_Case_Related__r);
                    }
                }
            } else {
                for (THR_Related_Object__c ci : caseItemList) {
                    if (oldProductMap.get(ci.THR_Product__c).IsActive == true && newProductMap.get(ci.THR_Product__c).IsActive == false && newProductMap.get(ci.THR_Product__c).THR_Country__c == 'ES') {
                        System.debug('@@@ Product WAS active, now is not');
                        ci.THR_Marketing_End_Date__c = true;
                        caseList.add(ci.THR_Case_Related__r);
                    }
                }
            }
            update caseItemList;
            THR_Spain_Utils.THR_LockCaseDiscProdSpain(caseList);
        }
        System.debug('@@@ ProductTriggerHandler END');
    }
}