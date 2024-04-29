public class handleAlternativesBatchable implements Database.Batchable<sObject>,Database.AllowsCallouts{

        
    Map<Id,SBQQ__QuoteLine__c> triggerOldMap;
    public final String QuoteId;
 
    public handleAlternativesBatchable(String triggerOldMapString, String QuoteId){
        this.triggerOldMap = triggerOldMapString != null ? (Map<Id,SBQQ__QuoteLine__c>)JSON.deserialize(triggerOldMapString, Map<Id,SBQQ__QuoteLine__c>.Class) : new Map<Id,SBQQ__QuoteLine__c>();
        this.QuoteId = quoteId;
    }
 
    public Database.QueryLocator start(Database.BatchableContext BC){
       return Database.getQueryLocator([SELECT Id,Alternative__c,Name, (SELECT Id,SBQQ__Product__c, SBQQ__Source__c,SBQQ__Source__r.SBQQ__Group__c, Alternative__c, Is_Deleted__c, SBQQ__Group__c FROM SBQQ__LineItems__r WHERE Id Not IN :triggerOldMap.keyset()) FROM SBQQ__QuoteLineGroup__c WHERE SBQQ__Quote__c = :QuoteId]);
    }
 
    public void execute(Database.BatchableContext BC, List<SBQQ__QuoteLineGroup__c> scope){

        QuoteLineTriggerHandler.handleAlternatives(scope, triggerOldMap,QuoteId);
        
    }
 
    public void finish(Database.BatchableContext BC){
    }
 }