public with sharing class QuoteExtController{
    private id quoteId;
    public QuoteExtController(ApexPages.StandardController stdController) {
        quoteId = stdController.getId();
    }
    public PageReference onSubmit() {
     if(quoteId != null) {
     SBAA.ApprovalAPI.submit(quoteId, SBAA__Approval__c.Quote__c);
     }
     return new PageReference('/' + quoteId);
     }
     public PageReference onRecall() {
     if(quoteId != null) {
     SBAA.ApprovalAPI.submit(quoteId, SBAA__Approval__c.Quote__c);
     }
     return new PageReference('/' + quoteId);
     }
}