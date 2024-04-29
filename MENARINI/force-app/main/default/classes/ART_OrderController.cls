public without sharing class ART_OrderController {
    @AuraEnabled
    public static List<Order> getOrders(Id accountId) {
        System.debug('Account Id '+accountId);
        List<Order> orders = [
            SELECT Id, OrderNumber, tolabel(Status), EffectiveDate, ContractId, TotalAmount
            FROM Order
            WHERE AccountId = :accountId AND
            THR_OrderType__c = 'Standard Order' AND
            THR_Country__c = 'IT' AND
            THR_SalesOrganization__c = 'DST1' AND
                (THR_Division__c = 'FA' OR THR_Division__c = 'DE' 
                OR (THR_Division__c = 'OT' AND THR_PurchaseOrderType__c = 'SFDC')) // S240111_000230 15032024
            ORDER BY EffectiveDate DESC LIMIT 50000
        ];
        System.debug('ordini'+orders);
        return orders;
    }
}