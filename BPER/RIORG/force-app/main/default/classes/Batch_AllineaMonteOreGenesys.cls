/****
 * Name         :   Batch_AllineaMonteOreGenesys
 * Created Date :   2023-07-06
 * Author       :   Lorenzo Vento @TEN
 ****/

public with sharing class Batch_AllineaMonteOreGenesys implements Database.Batchable<sObject>,Database.stateful,IRunner, Database.AllowsCallouts, Schedulable {

    public void execute(SchedulableContext sc) {
        Batch_AllineaMonteOreGenesys batch = new Batch_AllineaMonteOreGenesys();
        Database.executeBatch(batch, 20);
    }

    public List<ScheduledJob__c> sj = new List<ScheduledJob__c>();
    private static final String NOME_CLASSE = 'Batch_AllineaMonteOreGenesys';
    private static final Integer MAX_N_TRIALS = 3;
    private static final String ESTRAZIONE_ENDPOINT_NAME = 'EstrazioneUtenteGenesys';
    private static final String UPDATE_ENDPOINT_NAME = 'UpdateMonteOreGenesys';   
    private static final String MANAGE_ENDPOINT_NAME = 'ManagementBusinessUnitGenesys';
    public static List<SV_Log__c> logsToInsert = new List<SV_Log__c>();

    public void initRunner(List<ScheduledJob__c> schedules) {
        sj.addAll(schedules);
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT id, CRM_DataultimasyncGenesys__c, CRM_GenesysID__c, Email, FederationIdentifier FROM User WHERE (CRM_DataultimasyncGenesys__c = null OR CRM_Daelaborare__c = true) AND Profile.Name LIKE \'%Contact Center\' AND IsActive = true AND (NOT Email like \'%invalid%\') ';

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<User> scope) {
        try {
            System.debug('DENTRO EXECUTE');
            Cache.OrgPartition orgPart = Cache.Org.getPartition('local.Bper');
            Integer authCounter;
            Integer saveCounter;
            Integer updateCounter;
            Integer manageCounter;

            Set<String> uToEstract = new Set<String>();
            Set<String> uToSave = new Set<String>();
            Set<String> uToManage = new Set<String>();
            Map<String, Integer> mapGenesysIdVersion = new Map<String, Integer>(); 
            Map<String, User> mapUserToUpdate = new Map<String, User>();

            for (User u : scope) {
                if (u.CRM_GenesysID__c == null) {
                    System.debug('DENTRO CRM GENESIS');
                    uToEstract.add('AND' + '_' + u.Email + '_' + 'email' + '_' + 'EXACT');
                    mapUserToUpdate.put(u.Email, u);
                }
            }

            System.debug('ESTRACT STRING: ' + uToEstract);
            for (String u : uToEstract) {
                authCounter = saveCounter = 0;
                System.debug('RC token: ' + orgPart.get('genesysToken'));
                if(!orgPart.contains('genesysToken') || orgPart.get('genesysToken') == null){
                    System.debug('DENTRO AUTENTICAZIONE');
                    while(authCounter < MAX_N_TRIALS){
                        HttpResponse authResp = authVsGenesys();
                        if(authResp.getStatusCode() == 200){
                            break;
                        } else {
                            authCounter++;
                        }
                    }
                    if(authCounter == MAX_N_TRIALS){
                        System.debug('Autenticazione Genesys fallita');
                        
                    }
                }
                if (authCounter < MAX_N_TRIALS) {
                    while (saveCounter < MAX_N_TRIALS) {
                        HttpResponse estrazioneResp = estrazioneVSGenesys(u.split('_'));
                        System.debug('RC estrazioneResp: ' + estrazioneResp);
                        if (estrazioneResp.getStatusCode() == 200) {
                            System.debug('DENTRO ESTRAZIONE');
                            Map<String, Object> deserialized = (Map <String, Object>) JSON.deserializeUntyped(estrazioneResp.getBody());
                            List<Map<String, Object>> data = new List<Map<String, Object>>();
                            Object results = deserialized.get('results');
                            if (results != null) {
                                List<Object> resultList = (List<Object>) results;
                                for (Object instance : resultList) {
                                    data.add((Map<String, Object>) instance);
                                    System.debug('data LV: ' + instance);
                                }
                            Map<String, Object> mapResult = (Map<String, Object>)data[0];
                            String crmGenesysId = (String) mapResult.get('id');
                            Integer versionNumber = Integer.valueOf(mapResult.get('version'));
                            User utente = mapUserToUpdate.get(u.substringBetween('_'));
                            utente.CRM_GenesysID__c = crmGenesysId;
                            mapGenesysIdVersion.put(crmGenesysId, versionNumber);
                            mapUserToUpdate.put(u.substringBetween('_'), utente);
                            System.debug('mapUserToUpdate -> ' + mapUserToUpdate);
                        }
                            break;
                        } else {
                            saveCounter++;
                        }
                    }
                }
                if (saveCounter == MAX_N_TRIALS) {
                    System.debug('Estrazione Genesys fallita');
                }
            }
            if (saveCounter < MAX_N_TRIALS && authCounter < MAX_N_TRIALS) {
                for (String email : mapUserToUpdate.keySet()) {
                    User ut = mapUserToUpdate.get(email);
                    uToSave.add(ut.CRM_GenesysID__c + '_' + ut.FederationIdentifier + '_' + String.valueOf(mapGenesysIdVersion.get(ut.CRM_GenesysID__c)));
                    uToManage.add(ut.CRM_GenesysID__c);

                }

                
                System.debug('SAVE STRING: ' + uToSave);
                for (String u : uToSave) {
                    updateCounter = 0;
                    while (updateCounter < MAX_N_TRIALS) {
                        HttpResponse updateResp = updateVSGenesys(u.split('_'));
                        System.debug('RC updateResp: ' + updateResp);
                        if (updateResp.getStatusCode() == 200) {
                            System.debug('DENTRO UPDATE');
                            for (String email : mapUserToUpdate.keySet()) {
                                User utente = mapUserToUpdate.get(email);
                                utente.CRM_DataultimasyncGenesys__c = Datetime.now();
                                mapUserToUpdate.put(email, utente);
                            }
                            break;
                        } else {
                            updateCounter++;
                        }
                    }
                    if (updateCounter == MAX_N_TRIALS) {
                        System.debug('Salvataggio Genesys fallito');
                    }
                }
                System.debug('MANAGE STRING: ' + uToManage);
                for (String u : uToManage) {
                    manageCounter = 0;
                    if (updateCounter < MAX_N_TRIALS) {
                        while (manageCounter < MAX_N_TRIALS) {
                            HttpResponse manageResp = manageVSGenesys(u);
                            System.debug('RC manageResp: ' + manageResp);
                            if (manageResp.getStatusCode() == 200) {
                                System.debug('DENTRO MANAGE');
                                Map<String, Object> deserialized = (Map <String, Object>) JSON.deserializeUntyped(manageResp.getBody());
                                Map<String, Object> mapResult = (Map<String, Object>)deserialized.get('managementUnit');
                                Map<String, Object> mapResult2 = (Map<String, Object>)deserialized.get('businessUnit');
                                String crmManagementId = (String) mapResult.get('id');
                                String crmBusinessId = (String) mapResult2.get('id');
                                for (String email : mapUserToUpdate.keySet()) {
                                    User utente = mapUserToUpdate.get(email);
                                    if(utente.CRM_GenesysID__c!= null) {
                                        if (utente.CRM_GenesysID__c.equalsIgnoreCase(u)) {
                                            utente.CRM_ManagementID__c = crmManagementId;
                                            utente.CRM_BusinessUnitID__c = crmBusinessId;
                                            break;
                                        }
                                    }
                                    
                                    mapUserToUpdate.put(email, utente);
                                }
                                break;
                            } else {
                                manageCounter++;
                            }
                        }
                        if (manageCounter == MAX_N_TRIALS) {
                            System.debug('Manage Genesys fallito');
                        }
                    }
                }
            }
            
            List<User> listUserToUpdate = new List<User>();
        
            if(!mapUserToUpdate.isEmpty()) {
                listUserToUpdate = mapUserToUpdate.values();
            }

            if (!listUserToUpdate.isEmpty()) {
                FollowUp.invokeFutureGruppi = false;
                update listUserToUpdate;
            }

            if (!logsToInsert.isEmpty()) {
                insert logsToInsert;
            }

        } catch (Exception e) {
            System.debug(NOME_CLASSE + ' - An exception occurred during execute : ' + e.getMessage());
        }
    }

    public void finish(Database.BatchableContext bc) {

        if (sj!=null && sj.size()>0) {
            JobRunner.executeNext(sj);
        }
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

    public static HttpResponse estrazioneVSGenesys(List<String> params){
        Endpoint__c apiRequest = Endpoint__c.getInstance(ESTRAZIONE_ENDPOINT_NAME);
        Map<String, String> headersReq = new Map<String, String>();
            
        System.debug('PARAMS ESTRAZIONE: ' + params);
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String endpoint = apiRequest.Endpoint__c;
        request.setEndpoint(endpoint);
        System.debug('ENDPOINT ESTRAZIONE: ' + endpoint);
        request.setMethod(apiRequest.Method__c);
        Cache.OrgPartition orgPart = Cache.Org.getPartition('local.Bper');
        String token = (String) orgPart.get('genesysToken');
        request.setHeader('Authorization', 'Bearer '+token);
        headersReq.put('Authorization', 'Bearer '+token);
        request.setHeader('Content-Type', 'application/json');
        headersReq.put('Content-Type', 'application/json');
        Map<String,List<Map<String,Object>>> body = new Map<String,List<Map<String,Object>>>();
        Map<String,Object> mapListBody = new Map<String,Object>();
        mapListBody.put('type', params[3]);
        mapListBody.put('fields', new List<String>{params[2]});
        mapListBody.put('value', params[1]);
        mapListBody.put('operator',params[0]);
        body.put('query', new List<Map<String,Object>>{mapListBody});
        request.setBody(JSON.serialize(body));
        system.debug('JSON.serialize(body): ' + JSON.serialize(body));

        System.debug('REQUEST ESTRAZIONE: ' + request);

        HttpResponse response = http.send(request);

        string[] headerkeysRes = response.getHeaderKeys();

        //create an object to store your header key-value pairs
        Map<string, string> headersRes = new map<string, string>();

        //iterate through they keys, and populate your map
        for(string s : headerkeysRes){
            headersRes.put(s,response.getHeader(s));
        }

        System.debug('@@@@@estrazioneResponse'+response.getBody());
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

        //System.enqueueJob(new QueueableJobs(logsToInsert, '1'));

        return response;
    }

    public static HttpResponse updateVSGenesys(List<String> params){
        Endpoint__c apiRequest = Endpoint__c.getInstance(UPDATE_ENDPOINT_NAME);
        Map<String, String> headersReq = new Map<String, String>();
            
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String crmGenesysId = params[0];
        String version = params[params.size()-1];
        String realEndpoint = (apiRequest.Endpoint__c).replace('{userId}', crmGenesysId);
        params.remove(0);
        System.debug('PARAMS UPDATE: ' + params);
        String endpoint = String.format(realEndpoint, params);
        request.setEndpoint(endpoint);
        System.debug('ENDPOINT UPDATE: ' + endpoint);
        request.setMethod(apiRequest.Method__c);
        Cache.OrgPartition orgPart = Cache.Org.getPartition('local.Bper');
        String token = (String) orgPart.get('genesysToken');
        request.setHeader('Authorization', 'Bearer '+token);
        headersReq.put('Authorization', 'Bearer '+token);
        request.setHeader('Content-Type', 'application/json');
        headersReq.put('Content-Type', 'application/json');
        Map<String,Object> body= new Map<String,Object>();
        body.put('version',version);
        request.setBody(JSON.serialize(body));

        System.debug('REQUEST UPDATE: ' + request);

        HttpResponse response = http.send(request);

        string[] headerkeysRes = response.getHeaderKeys();

        //create an object to store your header key-value pairs
        Map<string, string> headersRes = new map<string, string>();

        //iterate through they keys, and populate your map
        for(string s : headerkeysRes){
            headersRes.put(s,response.getHeader(s));
        }

        System.debug('@@@@@updateResponse'+response.getBody());
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

        //System.enqueueJob(new QueueableJobs(logsToInsert, '1'));

        return response;
    }

    public static HttpResponse manageVSGenesys(String params){
        Endpoint__c apiRequest = Endpoint__c.getInstance(MANAGE_ENDPOINT_NAME);
        Map<String, String> headersReq = new Map<String, String>();
            
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String crmGenesysId = params;
        String endpoint = apiRequest.Endpoint__c;
        if (crmGenesysId != null) {
            endpoint = (apiRequest.Endpoint__c).replace('{agentId}', crmGenesysId);
        }
        System.debug('PARAMS MANAGE: ' + params);
        request.setEndpoint(endpoint);
        System.debug('ENDPOINT MANAGE: ' + endpoint);
        request.setMethod(apiRequest.Method__c);
        Cache.OrgPartition orgPart = Cache.Org.getPartition('local.Bper');
        String token = (String) orgPart.get('genesysToken');
        request.setHeader('Authorization', 'Bearer '+token);
        headersReq.put('Authorization', 'Bearer '+token);
        request.setHeader('Content-Type', 'application/json');
        headersReq.put('Content-Type', 'application/json');
        /*Map<String,Object> body= new Map<String,Object>();
        body.put('callable',false);
        request.setBody(JSON.serialize(body));*/

        System.debug('REQUEST MANAGE: ' + request);

        HttpResponse response = http.send(request);

        string[] headerkeysRes = response.getHeaderKeys();

        //create an object to store your header key-value pairs
        Map<string, string> headersRes = new map<string, string>();

        //iterate through they keys, and populate your map
        for(string s : headerkeysRes){
            headersRes.put(s,response.getHeader(s));
        }

        System.debug('@@@@@manageResponse'+response.getBody());
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

        //System.enqueueJob(new QueueableJobs(logsToInsert, '1'));

        return response;
    }

    public static SV_Log__c writeLog(String apiRequestName, String method, String input, Integer code, String status, String output,  Map<String,String> reqHeader, Map<String,String> resHeader, String endpoint, String errorMessage) {

        String inputPretty = input;
        String outputPretty = output;

        String reqHeaderPretty ;
        String resHeaderPretty ;

        List<String> path = endpoint.split('\\?');

        try {
            inputPretty = JSON.serializePretty(JSON.deserializeUntyped(input));
        } catch (Exception e) {}
    
        try {
            outputPretty = JSON.serializePretty(JSON.deserializeUntyped(output));
        } catch (Exception e) {}

        try {
            reqHeaderPretty = JSON.serializePretty(reqHeader);
        } catch (Exception e) {}

        try {
            resHeaderPretty = JSON.serializePretty(resHeader);
        } catch (Exception e) {}

        system.debug('@@@@@@@@ resHeader: '+resHeader);
        SV_Log__c log = new SV_Log__c(
            Source__c = apiRequestName,
            Method__c = method,
            Code__c = string.valueof(code),
            Status__c = status,
            Input_Payload__c = inputPretty != null && inputPretty.length() >= 131071 ? inputPretty.substring(0, 131071) : inputPretty,
            Output_Payload__c = outputPretty != null && outputPretty.length() >= 131071 ? outputPretty.substring(0, 131071) : outputPretty,
            Success__c = string.valueof(code).startsWith('2') ? true : false,
            ResponseHeader__c=resHeaderPretty,
            RequestHeader__c=reqHeaderPretty,
            Endpoint__c = path[0],
            Parameters__c = path.size() > 1 ? path[1] : ''
            // ErorrMessage__c = errorMessage

        );
        return log;

    }
}