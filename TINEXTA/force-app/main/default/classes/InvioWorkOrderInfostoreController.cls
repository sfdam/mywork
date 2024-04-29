public without sharing class InvioWorkOrderInfostoreController {

    @AuraEnabled
    public static string InvioWorkOrderInfostore(Id recordId){
        String response;
        Log__c logList;
		System.debug('*************InvioWorkOrderInfostore****************');
        Boolean disabilitaIntegrazione = Funzionalita__c.getInstance().Disabilita_Integrazione__c;
        if(disabilitaIntegrazione){
            System.debug('SV DISABILITA INTEGRAZIONE TRUE');
            return response = 'Disabilita';
        }

        try {
            System.debug('*************try****************');
            if(recordId == null) throw new CalloutException('RecordId mancante');

                User currUser = [ SELECT Id, Societa__c, UserRole.Name FROM User WHERE Id =: UserInfo.getUserId()];
                //List<workorder> wokList = [SELECT Id FROM workorder WHERE id IN: objIdList];
                System.debug('*************currUser****************'+currUser);
                String idNotAuthorizzed = EndpointServizi__c.getInstance().WRN_Id_IntegrazioneInfoStore__c;
                if(currUser.Id != idNotAuthorizzed){
                     System.debug('*************if(currUser.Id != idNotAuthorizzed)****************'+currUser.Id != idNotAuthorizzed);
                    logList = WRT_IntegrazioneController.workOrderIntegration_HDR(new list<id>{recordId});
                } else {
                    System.debug('SV NON ESEGUO LA CHIAMATA UTENTE NON AUTORIZZATO');
                }

                if(logList != null){
                    System.debug('*************if(logList != null)****************'+logList != null);
                    insert logList;
                    /*Boolean success = true;
                    if(!logList.Success__c) success = false;*/
                }
                response =(logList.ErrorMessage__c != null)? logList.ErrorMessage__c.toUpperCase():logList.Status__c;
        } catch (Exception e) {
            System.debug('*************Exception****************');
            // throw new AuraHandledException(e.getMessage());
            response = e.getMessage() + ' - ' + e.getLineNumber();
        }
        
        return response;
    }
}