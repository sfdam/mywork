public without sharing class ART_CustomerOrgUnitTriggerHandler {

    public static void setOrgUnitUser(List<cgcloud__Account_Org_Unit__c> newCustomerList) {
        Set<Id> unitSet = new Set<Id>();
        for(cgcloud__Account_Org_Unit__c newCustomer : newCustomerList){
            unitSet.add(newCustomer.cgcloud__Org_Unit__c);
        }

        List<cgcloud__Org_Unit_User__c> userList = [SELECT Id, cgcloud__Org_Unit__c
                                                    FROM cgcloud__Org_Unit_User__c
                                                    WHERE cgcloud__Org_Unit__c IN :unitSet
                                                    AND ART_RelationshipType__c = 'WORKPLACE_OWNER'
                                                    AND cgcloud__Valid_From__c <= TODAY
                                                    AND cgcloud__Valid_Thru__c >= TODAY
                                                    ORDER BY CreatedDate ASC];
        Map<Id, Id> unitUserMap = new Map<Id, Id>();
        for(cgcloud__Org_Unit_User__c user : userList){
            unitUserMap.put(user.cgcloud__Org_Unit__c, user.Id);
        }

        for(cgcloud__Account_Org_Unit__c newCustomer : newCustomerList){
            newCustomer.ART_Org_Unit_User__c = unitUserMap.get(newCustomer.cgcloud__Org_Unit__c);
        }
    }

}