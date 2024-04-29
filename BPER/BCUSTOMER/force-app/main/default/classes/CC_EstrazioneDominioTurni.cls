/****
 * Name         :   CC_EstrazioneDominioTurni
 * Created Date :   2023-30-06
 * Author       :   Francesco Ivan Esposito @TEN
 ****/
    
 public without sharing class CC_EstrazioneDominioTurni implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable {

    public void execute(SchedulableContext sc) {
        CC_EstrazioneDominioTurni batch = new CC_EstrazioneDominioTurni();
        Database.executeBatch(batch, 20);
    }

    public static List<SV_Log__c> logsToInsert = new List<SV_Log__c>();

    String query= '';
    public class SendRequestException extends Exception {
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        query = 'SELECT Id, CRM_GenesysID__c, CRM_BusinessUnitID__c FROM User WHERE Profile.Name LIKE \'%Contact Center\' AND CRM_BusinessUnitID__c != \'\'';
        return Database.getquerylocator(query);
    }

    public void execute(Database.BatchableContext BC, List<User> scope) {
        try {
            System.debug('DENTRO EXECUTE');
            Cache.OrgPartition orgPart = Cache.Org.getPartition('local.Bper');
            Integer authCounter;
            Integer saveCounter;

            Set<String> uToEstract = new Set<String>();
            Map<String, Integer> mapDominioTurni = new Map<String, Integer>();

            Map<String, List<Id>> BuisnessUnitIdToUsersMap = new Map<String, List<Id>>();

            for (User u : scope) {
                if (u.CRM_GenesysID__c != null) {
                    System.debug('DENTRO CRM GENESIS');
                    uToEstract.add(u.CRM_BusinessUnitID__c + '_' + u.CRM_GenesysID__c);
                }
            }

            for (User user : scope) {
                if (BuisnessUnitIdToUsersMap.containsKey(user.CRM_BusinessUnitID__c)) {
                    BuisnessUnitIdToUsersMap.get(user.CRM_BusinessUnitID__c).add(user.Id);
                } else {
                    BuisnessUnitIdToUsersMap.put(user.CRM_BusinessUnitID__c, new List<Id>{user.Id});
                }
            }
            System.debug('Mappa Gruppo - User ID: ----> ' + BuisnessUnitIdToUsersMap);

            Integer uniqueKeysCount = BuisnessUnitIdToUsersMap.keySet().size();
            System.debug('Count chiavi univoche: ----> ' + uniqueKeysCount);


            System.debug('ESTRACT STRING: ' + uToEstract);
            for (String u : uToEstract) {
                authCounter = saveCounter = 0;
                System.debug('RC token: ' + orgPart.get('genesysToken'));
                if(!orgPart.contains('genesysToken') || orgPart.get('genesysToken') == null){
                    System.debug('DENTRO AUTENTICAZIONE');
                    while(authCounter < 3){
                        HttpResponse authResp = authVsGenesys();
                        if(authResp.getStatusCode() == 200){
                            break;
                        } else {
                            authCounter++;
                        }
                    }
                    if(authCounter == 3){
                        throw new SendRequestException('Autenticazione Genesys fallita');
                    }
                }
                while (saveCounter < 3) {
                    HttpResponse estrazioneResp = estrazioneVSGenesys(u.split('_'));
                    System.debug('RC estrazioneResp: ' + estrazioneResp);
                    if (estrazioneResp.getStatusCode() == 200) {
                        System.debug('DENTRO ESTRAZIONE');
                        break;
                        
                    break;
                    } else {
                        saveCounter++;
                    }
                }
                if (saveCounter == 3) {
                    throw new SendRequestException('Estrazione Genesys fallita');
                }

                if (!logsToInsert.isEmpty()) {
                    insert logsToInsert;
                }
            }
        }
        catch (Exception e ){
            string errorMessage = e.getMessage();
            system.debug('l errore è' + errorMessage);
        }
    }

    public void finish(Database.BatchableContext bc) {
    }

    public static HttpResponse authVsGenesys() {

        Endpoint__c apiRequest = Endpoint__c.getInstance('GenesysToken');
        String orgId = UserInfo.getOrganizationId().left(15);
        softphone_it__Connector_Settings__c cs = softphone_it__Connector_Settings__c.getInstance(orgId);
        String aut = EncodingUtil.base64Encode(Blob.valueof(cs.softphone_it__GC_CLIENT_ID__c + ':' + cs.softphone_it__GC_CLIENT_SECRET__c));

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(apiRequest.Endpoint__c);
        request.setMethod(apiRequest.Method__c);
        request.setHeader('Authorization', 'Basic ' + aut);
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setBody('grant_type=client_credentials');

        HttpResponse response = http.send(request);
        if(!Test.isRunningTest()){
            System.debug('@@@@@tokenResponse'+response.getBody());
            Map<String,Object> deserializedResponse= (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
            String token=(String) deserializedResponse.get('access_token');
            Cache.OrgPartition orgPart = Cache.Org.getPartition('local.Bper');
            orgPart.put('genesysToken', token, 86400);
        }

        System.debug('@@@MC response ' + response);

        return response;
    }
    
    public static HttpResponse estrazioneVSGenesys( List<String> params){
        Endpoint__c apiRequest = Endpoint__c.getInstance('EstrazioneCodiceTimeoff');
        Map<String, String> headersReq = new Map<String, String>();
        System.debug('PARAMS RETRIVE: ' + params);

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String endpoint = apiRequest.Endpoint__c.replace('{businessUnitId}', params[0]);
        request.setEndpoint(endpoint);
        System.debug('ENDPOINT RETRIVE: ' + endpoint);

        request.setMethod(apiRequest.Method__c);
        Cache.OrgPartition orgPart = Cache.Org.getPartition('local.Bper');
        String token= (String) orgPart.get('genesysToken');
        request.setHeader('Authorization', 'Bearer '+token);
        headersReq.put('Authorization', 'Bearer '+token);
        request.setHeader('Content-Type', 'application/json');
        headersReq.put('Content-Type', 'application/json');

        System.debug('REQUEST RETRIVE: ' + request);

        HttpResponse response = http.send(request);

        string[] headerkeysRes = response.getHeaderKeys();

        //create an object to store your header key-value pairs
        Map<string, string> headersRes = new map<string, string>();

        //iterate through they keys, and populate your map
        for(string s : headerkeysRes){
            headersRes.put(s,response.getHeader(s));
        }

        System.debug('RETRIVE RESPONSE'+response.getBody());

        String responseBody = response.getBody();
        
        logsToInsert.add(writeLog(
            apiRequest.Name,
            apiRequest.Method__c,
            null,
            response.getStatusCode(),
            response.getStatus(),
            response.getBody().length() >= 131071 ? response.getBody().substring(0, 131071) : response.getBody(),
            headersReq,
            headersRes,
            endpoint,
            ''
            // responseObj.isCorrect() ? null : responseObj.getErrors()
        ));

        Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(responseBody);

        processResponse(jsonResponse);

        return response;
    }

    public static void processResponse(Map<String, Object> jsonResponse) {
        if (jsonResponse.containsKey('entities')) {
            List<Object> entities = (List<Object>) jsonResponse.get('entities');
            Map<String, String> activityCodeMap = new Map<String, String>();

            for (Object entity : entities) {
                Map<String, Object> entityMap = (Map<String, Object>) entity;
                String name = String.valueOf(entityMap.get('name'));
                if (!String.isBlank(name)) {
                    if (name.endsWith(')')) {
                        String extractedValue = name.substring(name.lastIndexOf('(') + 1, name.length() - 1);
                        String activityCodeId = String.valueOf(entityMap.get('id'));
                        activityCodeMap.put(activityCodeId, extractedValue);
                    }
                }
            }

            List<CRM_DominioTurni__c> records = new List<CRM_DominioTurni__c>();
            for (String activityCodeId : activityCodeMap.keySet()) {
                CRM_DominioTurni__c record = new CRM_DominioTurni__c();
                record.CRM_ActivityCodeID__c = activityCodeId;
                record.Name = activityCodeMap.get(activityCodeId);
                records.add(record);
            }

            if (!records.isEmpty()) {
                Database.UpsertResult[] upsertResults = Database.upsert(records, CRM_DominioTurni__c.Fields.CRM_ActivityCodeID__c, false);
                for (Database.UpsertResult result : upsertResults) {
                    if (!result.isSuccess()) {
                        System.debug('Upsert Error: ' + result.getErrors());
                    }
                }
            }
        } else {
            System.debug('API Response does not contain entities');
            System.debug('API Response: ' + jsonResponse);
        }
    }

    public static SV_Log__c writeLog(String apiRequestName, String method, String input, Integer code, String status, String output, Map<String, String> reqHeader, Map<String, String> resHeader, String endpoint, String errorMessage) {

        String inputPretty = input;
        String outputPretty = output;

        String reqHeaderPretty;
        String resHeaderPretty;

        List<String> path = endpoint.split('\\?');

        try {
            inputPretty = JSON.serializePretty(JSON.deserializeUntyped(input));
        } catch (Exception e) {
        }

        try {
            outputPretty = JSON.serializePretty(JSON.deserializeUntyped(output));
        } catch (Exception e) {
        }

        try {
            reqHeaderPretty = JSON.serializePretty(reqHeader);
        } catch (Exception e) {
        }

        try {
            resHeaderPretty = JSON.serializePretty(resHeader);
        } catch (Exception e) {
        }

        System.debug('@@@@@@@@ resHeader: ' + resHeader);
        SV_Log__c log = new SV_Log__c(
            Source__c = apiRequestName,
            Method__c = method,
            Code__c = String.valueOf(code),
            Status__c = status,
            Input_Payload__c = inputPretty != null && inputPretty.length() >= 131071 ? inputPretty.substring(0, 131071) : inputPretty,
            Output_Payload__c = outputPretty != null && outputPretty.length() >= 131071 ? outputPretty.substring(0, 131071) : outputPretty,
            Success__c = String.valueOf(code).startsWith('2') ? true : false,
            ResponseHeader__c = resHeaderPretty,
            RequestHeader__c = reqHeaderPretty,
            Endpoint__c = path[0],
            Parameters__c = path.size() > 1 ? path[1] : ''
        );
        return log;
    }

}