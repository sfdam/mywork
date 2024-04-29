public without sharing class ART_WholesalerController {
    public ART_WholesalerController() {
        
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getAccountRelationshipList(String orderId) {
        system.debug('cgcloud__Account_Relationship__c');
        List<cgcloud__Order__c> order = [SELECT Id, cgcloud__Order_Account__c, cgcloud__Wholesaler__c, cgcloud__Phase__c FROM cgcloud__Order__c WHERE id = :orderId];
		
        List<Account> accList = new List<Account>();
        if(order.size() > 0 && order[0].cgcloud__Order_Account__c != null){
            
        
            List<cgcloud__Account_Relationship__c> accRList = [SELECT  id,cgcloud__Related_Account__c,cgcloud__Related_Account__r.Id,cgcloud__Related_Account__r.Name,cgcloud__Related_Account__r.BillingStreet,cgcloud__Related_Account__r.BillingPostalCode,cgcloud__Related_Account__r.BillingCity,cgcloud__Related_Account__r.BillingState,cgcloud__Related_Account__r.BillingCountry
                                                               FROM cgcloud__Account_Relationship__c
                                                               WHERE  cgcloud__Relationship_Type__c = 'Wholesaler'
                                                               AND  cgcloud__Account__c = :order[0].cgcloud__Order_Account__c
                                                               AND cgcloud__Start_Date__c <= TODAY
                                                               AND cgcloud__End_Date__c >= TODAY
                                                               AND cgcloud__Related_Account__r.Name != '--- Empty Wholesaler ---'];                                               
            for(cgcloud__Account_Relationship__c caR : accRList){
                Account acc = new Account();
                acc.Id = caR.cgcloud__Related_Account__r.Id;
                acc.Name =  caR.cgcloud__Related_Account__r.Name;
                acc.BillingStreet =  caR.cgcloud__Related_Account__r.BillingStreet;
                acc.BillingPostalCode =  caR.cgcloud__Related_Account__r.BillingPostalCode;
                acc.BillingCity =  caR.cgcloud__Related_Account__r.BillingCity;
                acc.BillingState =  caR.cgcloud__Related_Account__r.BillingState;
                acc.BillingCountry =  caR.cgcloud__Related_Account__r.BillingCountry;
                accList.add(acc);
            }
        }
        system.debug('cgcloud__Account_Relationship__c size ' + accList );
        return new Map<String, Object>{
            'accList' => accList,
            'wholesaler' => order[0].cgcloud__Wholesaler__c,
            'phase' => order[0].cgcloud__Phase__c
        };
    }

    @AuraEnabled
    public static void updateOrder(String orderId, String accountId){
        system.debug('updateOrder');
        try{
            List<cgcloud__Order__c> order = [SELECT Id, cgcloud__Wholesaler__c FROM cgcloud__Order__c WHERE id = :orderId];
            order[0].cgcloud__Wholesaler__c = accountId;
            update order;
        } catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
    }
}