public with sharing class cartVisualizerController {

    @AuraEnabled
    public static List<SBQQ__QuoteLine__c> getData (string baseURL){
        string base64 = baseURL.substringAfterLast('one.app#');
        string urlString = String.valueOf(EncodingUtil.base64Decode(baseURL));
        string quoteId = UrlString.substringBetween('?id=', '"},');
        return [SELECT Id FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :QuoteId];
    }

    @AuraEnabled
    public static void createGroup (string recordId){

        integer count = [SELECT Count() FROM SBQQ__QuoteLineGroup__c WHERE SBQQ__Quote__c = :recordId ]+1;

        SBQQ__QuoteLineGroup__c newGroup = new SBQQ__QuoteLineGroup__c();
        
        newGroup.Name = 'TEST '+count;
        newGroup.SBQQ__Quote__c = recordid;

        insert newGroup;
    }

}