public without sharing class ART_OrgUnitUserTriggerHandler {

    public static void updateCustomerWorkplaceOwner(List<cgcloud__Org_Unit_User__c> newUnitUserList) {
        List<cgcloud__Org_Unit_User__c> workplaceOwnerList = new List<cgcloud__Org_Unit_User__c>();
        for(cgcloud__Org_Unit_User__c newUnitUser : newUnitUserList){
            if ('WORKPLACE_OWNER'.equals(newUnitUser.ART_RelationshipType__c)) {
                workplaceOwnerList.add(newUnitUser);
            }
        }

        Map<Id, Id> unitUserMap = new Map<Id, Id>();
        for(cgcloud__Org_Unit_User__c workplaceOwner : workplaceOwnerList){
            unitUserMap.put(workplaceOwner.cgcloud__Org_Unit__c, workplaceOwner.Id);
        }

        List<cgcloud__Account_Org_Unit__c> customerList = [SELECT Id, cgcloud__Org_Unit__c FROM cgcloud__Account_Org_Unit__c WHERE cgcloud__Org_Unit__c IN :unitUserMap.keySet()];
        for(cgcloud__Account_Org_Unit__c customer : customerList) {
            customer.ART_Org_Unit_User__c = unitUserMap.get(customer.cgcloud__Org_Unit__c);
        }
        update customerList;
    }
    
}