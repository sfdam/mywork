public class WGC_EditContact {

    @AuraEnabled
    public static String loadLayout(String recordId) {
        //Named Credential 1
       HTTP h = new HTTP();
       HTTPRequest req = new HTTPRequest();
       HttpResponse resp = new HttpResponse();

       req.setMethod('GET');
       req.setEndpoint('callout:TestNamedCredential/services/data/v44.0/ui-api/record-ui/' + recordId + '?format=json');
       resp = h.send(req);
       System.debug('@@@@ response ' + resp.getBody());
       String responseValue = resp.getBody();

       return responseValue;
    }

    @AuraEnabled
    public static WrapperResponse saveContact(Contact contact) {
        
        WrapperResponse result = new WrapperResponse();
        List<AccountContactRelation> accContactRelationList = new List<AccountContactRelation>();

        System.debug('@@@@@ contact: ' + contact);
        try {
            //adione SDHDFNZ-94034
            if (String.isNotBlank(contact.MailingCity))
                contact.MailingCity = contact.MailingCity.toUpperCase().trim();
            if (String.isNotBlank(contact.MailingStreetName__c))
                contact.MailingStreetName__c = contact.MailingStreetName__c.toUpperCase().trim();
            if (String.isNotBlank(contact.CF__c))
                contact.CF__c = contact.CF__c.toUpperCase().trim();
            
            
            // SCHIFO DA RIVEDERE
            contact.MailingCity = contact.MailingCity__c;
            contact.MailingCountry = contact.MailingCountry__c;
            contact.MailingPostalCode = contact.MailingPostalCode__c;
            contact.MailingState = contact.MailingState__c;
            contact.MailingStreet = contact.MailingStreetType__c + ' ' + contact.MailingStreetName__c + ' ' + contact.MailingStreetNumber__c;           
            
            if(String.isNotBlank(contact.LuogoNascita__c)){
                Map<String, SObject> comuniMap = U.keyBy([SELECT
                                Id,
                                Name,
                                CodiceCatastale__c,
                                Cab__c
                                FROM Comune__c
                                WHERE Name =: contact.LuogoNascita__c
                                ORDER BY FlagStorico__c
                            ], 'Name');

                contact.CodCatastaleLocNascita__c = String.isNotBlank(contact.LuogoNascita__c) && comuniMap.containsKey(contact.LuogoNascita__c) ? (String) comuniMap.get(contact.LuogoNascita__c).get('CodiceCatastale__c') : null;
                contact.CABLocNascita__c = String.isNotBlank(contact.LuogoNascita__c) && comuniMap.containsKey(contact.LuogoNascita__c) ? (String) comuniMap.get(contact.LuogoNascita__c).get('Cab__c') : null;
            }

            contact.CodiceIstituto3N__c = '881';
            contact.NaturaGiuridica__c = 'PF';
            contact.TAECode__c = '984';
            
            System.debug('SV accContactRelationList: ' + accContactRelationList);
            // rimossa condizione contact.EnteEmitettenteDocumento__c != null &&
            if(!CtrlWizardAccount.isPolandSearch()){
                if (String.isBlank(contact.NDGGruppo__c)){
                    if(contact.Birthdate != null && contact.CF__c != null && contact.DataEmissioneDoc__c != null && contact.DataScadenzaDoc__c != null &&
                        contact.FirstName != null && contact.LastName != null && contact.LuogoEmissioneDoc__c != null &&
                        contact.LuogoNascita__c != null && contact.MailingCity != null && contact.MailingCountry != null && contact.MailingPostalCode != null &&
                        contact.MailingState != null && contact.MailingStreetName__c != null && contact.MailingStreetNumber__c != null && contact.MailingStreetType__c != null &&
                        contact.NumeroDoc__c != null && contact.ProvinciaNascita__c != null && contact.SAE__c != null && contact.Sesso__c != null && contact.TipoDocumentoId__c != null){
                        
                        System.debug('CENSIMENTO FULL');
                        contact.NDGGruppo__c = WsAnagrafeUtils.WGC_censimentoFull(NULL, contact);
                    } else {
                        System.debug('CENSIMENTO LIGHT');
                        contact.NDGGruppo__c = WsAnagrafeUtils.censimentoLight(NULL, contact);
                    }
                } else {
                    contact.NDGGruppo__c = WsAnagrafeUtils.WGC_variazione(NULL, contact);
                }
            }

            contact.CI3N_NDGGruppo__c = contact.CodiceIstituto3N__c + '-' + contact.NDGGruppo__c;
            contact.CI3N_CF__c = contact.CodiceIstituto3N__c + '-' + contact.CF__c;

            System.debug('contact.Id: ' + contact.Id);
            System.debug('contact.CI3N_NDGGruppo__c: ' + contact.CI3N_NDGGruppo__c);
            System.debug('contact.CI3N_CF__c: ' + contact.CI3N_CF__c);

            TrgContact.skipCheckCodiceFiscale = true;
            upsert contact;
            result.data.add(contact);
        } catch(Exception e){
            result.success = false;
            result.msg = e.getMessage();
            return result;
        }
        
        return result;
    }


    @AuraEnabled
    public static WrapperResponse saveContactOnlyCRM(Contact contact) {
        
        WrapperResponse result = new WrapperResponse();

        System.debug('SV contact: ' + contact);
        try {

            TrgContact.skipCheckCodiceFiscale = true;
            //adione SDHDFNZ-94034
            if (String.isNotBlank(contact.CF__c)) 
				contact.CF__c = contact.CF__c.toUpperCase().trim();
            upsert contact;
            result.data.add(contact);
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