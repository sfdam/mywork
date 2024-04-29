/****
 * Name         :   syncUserGenesysController
 * Created Date :   2023-07-06
 * Author       :   Lorenzo Vento @TEN
 ****/
public with sharing class syncUserGenesysController {

    private static final String NOME_CLASSE = 'syncUserGenesysController';
    private static final Integer MAX_N_TRIALS = 3;
    private static final String MANAGE_ENDPOINT_NAME = 'ManagementBusinessUnitGenesys';
    public static List<SV_Log__c> logsToInsert = new List<SV_Log__c>();

    @AuraEnabled
    public static List<Map<String, Object>> getGestoriList(String profileName) {
        try {

            List<Map<String, Object>> userList = new List<Map<String, Object>>();

            for (User User : [SELECT Id, Name, FederationIdentifier, CRM_DataultimasyncGenesys__c, CRM_GenesysID__c, CRM_ManagementID__c, CRM_BusinessUnitID__c 
                                    FROM User 
                                    WHERE profile.Name LIKE :profileName AND FederationIdentifier != null AND IsActive = true]) {

                Map<String, Object> userObject = new Map<String, Object>();
                userObject.put('Id', user.Id);
                userObject.put('Name', user.Name);
                userObject.put('FederationIdentifier', user.FederationIdentifier);
                userObject.put('CRM_DataultimasyncGenesys__c', user.CRM_DataultimasyncGenesys__c);
                userObject.put('CRM_GenesysID__c', user.CRM_GenesysID__c);
                userObject.put('CRM_ManagementID__c', user.CRM_ManagementID__c);
                userObject.put('CRM_BusinessUnitID__c', user.CRM_BusinessUnitID__c);

                userList.add(userObject);
            }

            return userList;                            

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String syncNewUtenti(String recordId) {
        try {

            String result = 'success';
            List<User> userToSync = [SELECT Id, CRM_GenesysID__c, CRM_ManagementID__c, CRM_BusinessUnitID__c
                                        FROM User
                                        WHERE Id = :recordId];

            List<User> userToUpdate = new List<User>();
            Integer authCounter = 0;
            Integer manageCounter = 0;
            Cache.OrgPartition orgPart = Cache.Org.getPartition('local.Bper');

            if (!userToSync.isEmpty()) {
                authCounter = manageCounter = 0;
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
                        result = 'fail';
                    }
                }
                if (authCounter < MAX_N_TRIALS) {
                    while (manageCounter < MAX_N_TRIALS) {
                        String param = userToSync[0].CRM_GenesysID__c != null ? userToSync[0].CRM_GenesysID__c : 'null';
                        HttpResponse manageResp = manageVSGenesys(param);
                        System.debug('RC manageResp: ' + manageResp);
                        if (manageResp.getStatusCode() == 200) {
                            System.debug('DENTRO MANAGE');
                            Map<String, Object> deserialized = (Map <String, Object>) JSON.deserializeUntyped(manageResp.getBody());
                            Map<String, Object> mapResult = (Map<String, Object>)deserialized.get('managementUnit');
                            Map<String, Object> mapResult2 = (Map<String, Object>)deserialized.get('businessUnit');
                            String crmManagementId = (String) mapResult.get('id');
                            String crmBusinessId = (String) mapResult2.get('id');
                            User utente = new User(
                                Id = userToSync[0].Id,
                                CRM_ManagementID__c = crmManagementId,
                                CRM_BusinessUnitID__c = crmBusinessId
                            );
                            userToUpdate.add(utente);
                            break;
                        } else {
                            if (param.equalsIgnoreCase('null')) {
                                manageCounter = MAX_N_TRIALS;
                            }
                            else {
                                manageCounter++;
                            }
                        }
                    }
                    if (manageCounter == MAX_N_TRIALS) {
                        result = 'fail';
                    }
                }
            }                                  

            if (!userToUpdate.isEmpty()) {
                update userToUpdate;
            }

            return result;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '; at: ' + e.getStackTraceString());
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

    public static HttpResponse manageVSGenesys(String params){
        Endpoint__c apiRequest = Endpoint__c.getInstance(MANAGE_ENDPOINT_NAME);
        Map<String, String> headersReq = new Map<String, String>();
            
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String crmGenesysId = params;
        String endpoint = (apiRequest.Endpoint__c).replace('{agentId}', crmGenesysId);
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
        /*logsToInsert.add(writeLog(
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
        ));*/

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