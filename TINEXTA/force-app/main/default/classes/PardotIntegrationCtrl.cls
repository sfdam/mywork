public without sharing class PardotIntegrationCtrl {

    public static String createContact(Map<String,String> parametri){

        String msg = '';
        String body = '';
        String responseBody = '';
        Boolean success = true;

        String pardotId = '';

        try {

            System.debug('@@@ parametri ' + parametri);
            
            HttpRequest request = new HttpRequest();
            request.setTimeout(90000);
            request.setMethod('POST');
            // request.setEndpoint(EndpointServizi__c.getOrgDefaults().WRT_Create_Prospect_Pardot_Ecobonus__c);
            request.setEndpoint('https://pi.pardot.com/api/prospect/version/4/do/upsert' + (String.isNotBlank(parametri.get('id')) ? '/id=' + parametri.get('id') : '') + '?format=json');

            request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            request.setHeader('Authorization', 'Bearer ' + getSessionId());
            request.setHeader('Pardot-Business-Unit-Id', UtenzeDefault__c.getOrgDefaults().WRT_Pardot_Business_Unit_ID__c); //'0Uv5I0000000048SAA'

            for(String key : parametri.keySet()){
                body += key + '=' + parametri.get(key) + '&'; 
            }

            body = body.removeEnd('&');

            request.setBody(body);

            System.debug('@@@ body ' + body);
            HttpResponse response = new Http().send(request);
            System.debug('@@@ response ' + response.getBody());
            responseBody = response.getBody();

            Map<String,Object> prospect = (Map<String,Object>) JSON.deserializeUntyped(responseBody);
            Object prospectObj = prospect.get('prospect');
            Map<String,Object> prospectMap = (Map<String,Object>) prospectObj;
            pardotId = String.valueOf(prospectMap.get('id'));

        } catch(Exception e){
            System.debug('@@@ error ' + e.getMessage() + ' - ' + e.getLineNumber());
            msg = e.getMessage() + ' - ' + e.getLineNumber();
            success = false;
        }

        insert new Log__c(
            Source__c = 'EcobonusCreateContattoPardot',
            ErrorMessage__c = msg,
            Success__c = success,
            InputPayload__c = body,
            OutputPayload__c = responseBody
        );

        return pardotId;
    }

    public static String deleteContact(Map<String,String> parametri){

        String msg = '';
        String body = '';
        String responseBody = '';
        Boolean success = true;

        try {
            HttpRequest request = new HttpRequest();
            request.setTimeout(90000);
            request.setMethod('POST');
            request.setEndpoint(EndpointServizi__c.getOrgDefaults().WRT_Delete_Prospect_Pardot_Ecobonus__c);

            request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            request.setHeader('Authorization', 'Bearer ' + getSessionId());
            request.setHeader('Pardot-Business-Unit-Id', UtenzeDefault__c.getOrgDefaults().WRT_Pardot_Business_Unit_ID__c); //'0Uv5I0000000048SAA'

            Map<String,String> fields = new Map<String,String>{'id' => parametri.get('id')};

            for(String key : fields.keySet()){
                body += key + '=' + fields.get(key) + '&';
            }

            body = body.removeEnd('&');

            request.setBody(body);

            HttpResponse response = new Http().send(request);
            System.debug('@@@ response ' + response.getBody());
            responseBody = response.getBody();

            msg = response.getBody();

        } catch(Exception e){
            System.debug('@@@ error ' + e.getMessage() + ' - ' + e.getLineNumber());
            msg = e.getMessage() + ' - ' + e.getLineNumber();
            success = false;
        }

        insert new Log__c(
            Source__c = 'EcobonusDeleteContattoPardot',
            ErrorMessage__c = msg,
            Success__c = success,
            InputPayload__c = body,
            OutputPayload__c = responseBody
        );

        return msg;
    }

    @AuraEnabled
    public static void deleteContactFlow(Map<String,String> parametri){
        try {
            PardotIntegrationCtrl.deleteContactAsync(parametri);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @future(callout=true)
    public static void deleteContactAsync(Map<String,String> parametri){
        PardotIntegrationCtrl.deleteContact(parametri);
    }

    //Use sessionId to authenticate to pardot
    //Punta alla org di produzione anche in test
    public static String getSessionId(){
        String token = '';


        HttpRequest request = new HttpRequest();
        request.setTimeout(90000);
        request.setMethod('POST');
        request.setEndpoint(EndpointServizi__c.getOrgDefaults().WRT_Token_SF_Pardot__c);
        request.setBody('grant_type=password&client_id='+UtenzeDefault__c.getOrgDefaults().WRT_Client_Id_Pardot__c+'&client_secret='+UtenzeDefault__c.getOrgDefaults().WRT_Client_Secret_Pardot__c+'&username='+UtenzeDefault__c.getOrgDefaults().WRT_Username_Pardot__c+'&password='+UtenzeDefault__c.getOrgDefaults().WRT_Password_Pardot__c);
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');

        HttpResponse response = new Http().send(request);
        System.debug('@@@ response ' + response.getBody());
        Map<String,String> resp = (Map<String,String>)JSON.deserializeStrict(response.getBody(), Map<String,String>.Class);

        token = resp.get('access_token');
        return token;
    }
}