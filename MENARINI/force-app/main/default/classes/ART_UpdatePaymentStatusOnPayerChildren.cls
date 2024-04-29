//@TestClass ART_UpdatePaymentStatusOnPayerChild_Test
global without sharing class ART_UpdatePaymentStatusOnPayerChildren implements Database.Batchable<SObject>, Schedulable, Database.Stateful {
    global List<Account> modifiedPayers = new List<Account>();
    /** Metodi di interface Database.Batchable<SObject> */
    global List<Account> start(Database.BatchableContext BC) {
        modifiedPayers = [SELECT Id FROM Account WHERE ART_Updated_Payment_Status__c = TRUE];
        return [SELECT Id, THR_Payer__c, THR_Payer__r.ART_Payment_Status__c FROM Account WHERE THR_Payer__c IN :modifiedPayers];
    }

    global void execute(Database.BatchableContext BC, List<Account> scope) {
        
        for(Account child : scope){
            System.debug('********* AA => ' + child);
            child.ART_Payment_Status__c = child.THR_Payer__r.ART_Payment_Status__c;            
        }
        update scope;
    }
    global void finish(Database.BatchableContext BC) {
        System.debug('****** FINISHHHH!!!');
        System.debug('*********** PAYERS ' + modifiedPayers);
        for(Account payer : modifiedPayers){
            payer.ART_Updated_Payment_Status__c = FALSE;
        }
        if(!modifiedPayers.isEmpty()){
            update modifiedPayers;
        }
    }
    global void execute(System.SchedulableContext sc) {
        /*Database.executeBatch(new ART_UpdatePaymentStatusOnPayerChildren(), 1);*/
    }
}