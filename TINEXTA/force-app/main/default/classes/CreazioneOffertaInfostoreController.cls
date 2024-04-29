public without sharing class CreazioneOffertaInfostoreController {

    @AuraEnabled
    public static string CreazioneOffertaInfostore(Id recordId){
        String response;

        try {
            if(recordId == null)
                throw new CalloutException('RecordId mancante');
                
            SBQQ__Quote__c quote = [SELECT Id, SBQQ__Opportunity2__c FROM SBQQ__Quote__c WHERE Id =: recordId LIMIT 1];
            // List<Opportunity> oppList = new List<Opportunity>([SELECT Id FROM Opportunity WHERE Id =: quote.SBQQ__Opportunity2__c]);
            response = WRT_IntegrazioneController.opportunityIntegration_InfoStore_CPQ(quote.Id);
        } catch (Exception e) {
            // throw new AuraHandledException(e.getMessage());
            response = e.getMessage() + ' - ' + e.getLineNumber();
        }
        
        return response;
    }
}