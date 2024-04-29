public with sharing class CRM_IngaggioAgentiNdgNonAttivi {
    
    public static Map<String, String> devNameMap = new Map<String, String>{
        'ndg' => 'CRM_NDG__c',
        'abi' => 'FinServ__BankNumber__c'
    };
    
    public class FlowInputs {
        @InvocableVariable public String abi;
        @InvocableVariable public String ndg;
    }

    public class FlowOutputs{
        @InvocableVariable public Integer codice;
        @InvocableVariable public String  messaggio; 
        @InvocableVariable public String  idNewAccount; 
    }

    /**
    * @description 
    * @author simone.viglianti@tengroup.it | 12-06-2021 
    * @param inputs 
    * @return FlowOuputs[] 
    **/
    @InvocableMethod
    public static FlowOutputs[] makeRequest(List<FlowInputs> inputs){
        System.debug(LoggingLevel.DEBUG,'*** START -- makeRequest Method ***');
        /*System.debug(LoggingLevel.DEBUG,'### recordId: '+inputs[0].recordId);
        System.debug(LoggingLevel.DEBUG,'### certficationName: '+inputs[0].certificationName);
        System.debug(LoggingLevel.DEBUG,'### disableLog: '+inputs[0].disableLog);
        System.debug(LoggingLevel.DEBUG,'### apiRequestName: '+inputs[0].apiRequestName);*/

        Map<String, Object> response = new Map<String, Object>();
        List<FlowOutputs> outputs = new List<FlowOutputs>();
        try {
            // List<SObject> records = [SELECT Id FROM SObject WHERE Id =: inputs[0].recordId];
            response = invokeWS(new List<SObject>(), (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(inputs[0])), '');
            System.debug('DK makeRequest.response: ' + JSON.serialize(response));
            FlowOutputs output = new FlowOutputs();
            output.codice = (Integer)response.get('codice');
            output.messaggio = (String)response.get('messaggio');
            output.idNewAccount = (String)response.get('idNewAccount');
            outputs.add(output);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR,'### Exception aggiornamentoEsitazioneOpportunità: '+e.getMessage()+' at line: '+e.getLineNumber());
        }
        System.debug(LoggingLevel.DEBUG,'### result: '+response);
        System.debug(LoggingLevel.DEBUG,'*** END -- makeRequest Method ***');
        return outputs;
    }

    /**
    * @description 
    * @author simone.viglianti@tengroup.it | 12-06-2021 
    * @param certificationName 
    * @param SObjectList 
    * @param disableLog 
    * @param runAsUserId 
    * @return Boolean 
    **/
    public static Map<String, Object> invokeWS(List<SObject> SObjectList, Map<String, Object> inputs, String runAsUserId){
        String apiRequestName = 'getDettaglioAnagrafica';
        String certificationName = 'salesforceprodclient2024';
        System.debug(LoggingLevel.DEBUG,'*** START -- makeRequest Method ***');
        System.debug(LoggingLevel.DEBUG,'### apiRequestName: ' + apiRequestName);
        System.debug(LoggingLevel.DEBUG,'### certificationName: ' + certificationName);
        System.debug(LoggingLevel.DEBUG,'### SObjectList: ' + SObjectList);
        System.debug(LoggingLevel.DEBUG,'### runAsUserId: ' + runAsUserId);
        StaticResource staticResource = [select id,body from StaticResource Where Name = 'jsonWrapper'];
        String jsonWrapper = staticResource.body.toString();
        Map<String,Object> parsedJsonWrapper = (Map<String,Object>)JSON.deserializeUntyped(jsonWrapper);
        Map<String,Object> parsedJsonElement = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(parsedJsonWrapper.get('getDettaglioAnagrafica')));
        Map<String, Object> parsedJsonElementFields = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(parsedJsonElement.get('fields')));
        Map<String, Map<String, Object>> fieldsMap = new Map<String, Map<String, Object>>();
        Map<String, Map<String, String>> conditionMap = new Map<String, Map<String, String>>();
        Map<String, String> flowInputs = new Map<String, String>();
        Map<String, Object> responseMapToReturn = new Map<String, Object>();
        Account account = new Account();
        for(String key : inputs.keySet()){
            account.put(devNameMap.get(key), (String)inputs.get(key));
        }
        for(String fieldName : parsedJsonElementFields.keySet()){

            fieldsMap.put(fieldName, (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(parsedJsonElementFields.get(fieldName))));
        }

        if(parsedJsonElement.containsKey('conditionList')){
            
            Map<String, Object> parsedJsonElementCondiions = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(parsedJsonElement.get('conditionList')));
            for(String conditionName : parsedJsonElementCondiions.keySet()){
    
                conditionMap.put(conditionName, (Map<String, String>)JSON.deserializeUntyped(JSON.serialize(parsedJsonElementCondiions.get(conditionName))));
            }
        }
        
        String response = MakeRequestController.makeRequest(apiRequestName, null, account, fieldsMap, conditionMap, null, certificationName, null, false, false);
        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response);
        System.debug('DK responseMap' + JSON.serialize(responseMap));
        try {
            
            if((String)responseMap.get('error') == 'Response is blank'){
                responseMapToReturn.put('codice', 400);
                responseMapToReturn.put('messaggio', 'Non è stato trovato su Anagrafe l’NDG richiesto'); 
            }else{
    
                if(String.valueOf(responseMap.get('statusCode')).startsWith('2')){
                    Map<String, Object> requestResponse = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(responseMap.get('response')));
                    Map<String, Object> responseBodyMap = (Map<String, Object>) JSON.deserializeUntyped((String)requestResponse.get('data'));
                    Map<String, Object> dettaglioAnagrafica = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(responseBodyMap.get('dettaglioAnagrafica')));
                    Map<String, Object> residenzaSedeLegale = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(dettaglioAnagrafica.get('residenzaSedeLegale')));
                    Map<String, Object> contatti = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(dettaglioAnagrafica.get('contatti')));
                    Map<String, Object> provincia = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(residenzaSedeLegale.get('provincia')));
                    
                    account = (Account)JSON.deserialize(JSON.serialize(responseMap.get('record')), Account.class);
                    //account.NDW_ExternalId__c  = (String)inputs.get('ndg') + '_' + (String)inputs.get('abi');
                    account.NDW_ExternalId__c  = (String)inputs.get('abi') + '_' + (String)inputs.get('ndg');

                    account.FinServ__BranchCode__c = (String)responseBodyMap.get('filialePrincipale');
                    account.PersonEmail = contatti != null && contatti.containsKey('emailOTP') && !String.isBlank((String)contatti.get('emailOTP')) && validateEmail((String)contatti.get('emailOTP')) ?
                    (String)contatti.get('emailOTP') : contatti != null && contatti.containsKey('email1') && !String.isBlank((String)contatti.get('email1')) && validateEmail((String)contatti.get('email1')) ?
                    (String)contatti.get('email1') : '';
                    account.CRM_ResidentialAddress__c = (String)residenzaSedeLegale.get('indirizzo') + ', ' + 
                    (String)residenzaSedeLegale.get('cap') + ', ' + 
                    (String)residenzaSedeLegale.get('localita') + ', ' + 
                    (provincia != null ? (String)provincia.get('codice') : '');
    
                    Map<String, Object> requestBody = new Map<String, Object>{
                        'recordList' => new List<Account>{account},
                        'operation' => 'insert'
                    };
                    Http req = new Http();
                    HttpRequest request = new HttpRequest();
                    request.setEndpoint('callout:CallMeBackUnecapi/services/apexrest/executeasunecapi');
                    request.setHeader('Content-Type', 'Application/JSON');
                    request.setMethod('POST');
                    request.setTimeout(120000);
                    System.debug('DK requestBody: ' + JSON.serialize(requestBody));
                    request.setBody(JSON.serialize(requestBody));
    
                    HttpResponse resp = new HttpResponse();
                    String responseBody = req.send(request).getBody();
                    System.debug('Dk responseBody: ' + responseBody);
                    // Map<String, Object> dmlResponse = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
                    Map<String, Object> dmlResponse = (Map<String, Object>)JSON.deserializeUntyped((String)JSON.deserializeUntyped(responseBody));
                    if(!dmlResponse.containsKey('errorMessage')){
                        account = ((List<Account>)JSON.deserialize(JSON.serialize(dmlResponse.get('recordList')), List<Account>.class))[0];
                        responseMapToReturn.put('codice', 200);
                        responseMapToReturn.put('messaggio', 'La richiesta è andata buon fine');
                        responseMapToReturn.put('idNewAccount', account.id);
                    }else{
                        responseMapToReturn.put('codice', 500);
                        responseMapToReturn.put('messaggio', 'Errore durante l\'inserimento. Contattare Amministratore di sistema.'); 
                    }
                }else{
                    responseMapToReturn.put('codice', 500);
                    responseMapToReturn.put('messaggio', 'Errore invocazione Servizio. Riprovare più tardi.'); 
                }
            }
            System.debug('DK responseMapToReturn: ' + JSON.serialize(responseMapToReturn));
        } catch (Exception ex) {
            System.debug('DK Execption: ' + ex.getMessage() + '; at: ' + ex.getStackTraceString());
            responseMapToReturn.put('codice', 500);
            responseMapToReturn.put('messaggio', 'Errore inaspetatto. Contattare Amministratore di sistema.'); 
        }
        return responseMapToReturn;
    }

    public static Boolean validateEmail(String email) {
        Boolean res = true;
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$'; // source: http://www.regular-expressions.info/email.html
        Pattern MyPattern = Pattern.compile(emailRegex);
        Matcher MyMatcher = MyPattern.matcher(email);
        if (!MyMatcher.matches()) 
            res = false;
        return res; 
    }
}