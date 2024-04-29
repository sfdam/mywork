global class ART_BatchAdvancedOrdersCanceled implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('ART_BatchAdvancedOrdersCanceled - start');

        Date day_1 = Date.today().addDays(-30);
        return Database.getQueryLocator('SELECT Id FROM cgcloud__Order__c WHERE cgcloud__Phase__c = \'Initial\' AND cgcloud__Delivery_Date__c <= :day_1');
    }

    global void execute(Database.BatchableContext BC, List<cgcloud__Order__c> scope) {
        System.debug('ART_BatchAdvancedOrdersCanceled - execute - scope size: ' + scope.size());
        for (cgcloud__Order__c order : scope) {
            System.debug('execute - order: ' + order);
            order.cgcloud__Phase__c = 'Canceled';
        }
        update scope;
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('ART_BatchAdvancedOrdersCanceled - finish');
    }

}