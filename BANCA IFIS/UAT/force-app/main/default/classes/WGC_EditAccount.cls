public class WGC_EditAccount {

    @AuraEnabled
    public static String loadLayout(String recordId) {
        //Named Credential 1
        HTTP h = new HTTP();
        HTTPRequest req = new HTTPRequest();
        HttpResponse resp = new HttpResponse();
        String sessionId = UserInfo.getSessionId();
        System.debug('@@@@ sessionId: ' + sessionId );
        req.setMethod('GET');
        req.setEndpoint('callout:TestNamedCredential/services/data/v42.0/ui-api/record-ui/' + recordId + '?format=json');
        req.setHeader('Authorization','Bearer ' + sessionId);
        resp = h.send(req);
        System.debug('@@@@ response ' + resp.getBody());
        String responseValue = resp.getBody();

        return responseValue;
    }

    @AuraEnabled
    public static WrapperResponse saveAccount(Account account) {
        
        WrapperResponse result = new WrapperResponse();

        System.debug('SV account: ' + account);
        try {
            // account.Fatturato__c = account.Fatturato__c / 100;
            account.NumberOfEmployees = Integer.valueOf(account.NumberOfEmployees);
            account.WGC_Numero_dipendenti__c = Integer.valueOf(account.WGC_Numero_dipendenti__c);

            // SCHIFO DA RIVEDERE
            account.BillingCity = account.BillingCity__c;
            account.BillingCountry = account.BillingCountry__c;
            account.BillingPostalCode = account.BillingPostalCode__c;
            account.BillingState = account.BillingState__c;

            account.BillingStreet = UtilAnagrafiche.getIndirizzoCompleto(
                account.BillingStreetType__c,
                account.BillingStreetName__c,
                account.BillingStreetNumber__c
            );

            account.ShippingCity = account.ShippingCity__c;
            account.ShippingCountry = account.ShippingCountry__c;
            account.ShippingPostalCode = account.ShippingPostalCode__c;
            account.ShippingState = account.ShippingState__c;

            account.ShippingStreet = UtilAnagrafiche.getIndirizzoCompleto(
                account.ShippingStreetType__c,
                account.ShippingStreetName__c,
                account.ShippingStreetNumber__c
            );

            //adione SDHDFNZ-94034
            account.CF__c = account.CF__c.toUpperCase().trim();
            System.debug('SV account AFTER: ' + account);

            Contact diContact;
            Contact compliteContact;
            System.debug('SV account Natura Giuridica: ' + account.NaturaGiuridica__c);
			
            Account rtAccount = [SELECT Id, RecordTypeId  FROM Account WHERE Id = :account.Id LIMIT 1];
			RecordType rtTribunale = [SELECT Id FROM RecordType WHERE DeveloperName = 'WGC_Tribunale' LIMIT 1];
			Boolean isTribunale = (rtAccount.RecordTypeId == rtTribunale.Id);
			//adione
			//clienti Polonia non vengono aggiornati su Cedacri, il master è KNET
			//tribunali: fast finance modifica tribunali ma solo su CRM
            if (!CtrlWizardAccount.isPolandSearch() && !isTribunale) {
                String accountNdg = WsAnagrafeUtils.WGC_variazione(account, null);
            }
            
            upsert account;
            result.data.add(account);
        } catch(Exception e){
            result.success = false;
            result.msg = e.getMessage();
            return result;
        }
        
        return result;
    }

    /*..........................................*/
    /* Wrapper class to display Response       */
    /*.........................................*/
    
    public class WrapperResponse {
        
        @AuraEnabled public Boolean success;
        @AuraEnabled public String msg;
        @AuraEnabled public List<sObject> data;
        
        public WrapperResponse(){
            success = true;
            msg = '';
            data = new List<sObject>();
        }
    }

}