public with sharing class cpqVFController {
    
    public String UrlParameterJSON {set;get;}
    public String QLJSON {set;get;}
    public String quoteId {set;get;}
    public List<SBQQ__QuoteLine__c> quoteLines {set;get;}

    public cpqVFController() {
        this.UrlParameterJSON = JSON.serialize(ApexPages.currentPage().getParameters());
        quoteId = ApexPages.currentPage().getParameters().get('recordId');
        this.quoteLines = [SELECT Id, Name FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :quoteId];
        this.QLJSON = JSON.serialize(quoteLines);
    }
}