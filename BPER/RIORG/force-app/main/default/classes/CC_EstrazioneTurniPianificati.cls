/**
 * Name         :   CC_EstrazioneTurniPianificati
 * Created Date :   2023-06-14
 * Author       :   Francesco Ivan Esposito @TEN
 **/

 public without sharing class CC_EstrazioneTurniPianificati implements Database.Batchable<sObject>, Database.stateful, Database.AllowsCallouts, Schedulable {

    private static final Integer BATCH_SIZE = 20;

    private Set<String> processedManagementIds = new Set<String>();

    private List<String> responseBodies = new List<String>();


    public void execute(SchedulableContext sc) {
        CC_EstrazioneTurniPianificati batch = new CC_EstrazioneTurniPianificati();
        Database.executeBatch(batch, BATCH_SIZE);
    }

    public static List<SV_Log__c> logsToInsert = new List<SV_Log__c>();

    String query = '';

    public class SendRequestException extends Exception {
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        query = 'SELECT Id, CRM_GenesysID__c, CRM_ManagementID__c FROM User WHERE Profile.Name LIKE \'%Contact Center\' AND CRM_ManagementID__c != null AND CRM_ManagementID__c NOT IN :processedManagementIds';
        return Database.getquerylocator(query);
    }

    public void execute(Database.BatchableContext BC, List<User> scope) {
        try {
            Cache.OrgPartition orgPart = Cache.Org.getPartition('local.Bper');
            Integer authCounter = 0;
            Integer saveCounter = 0;
            Set<String> uToEstract = new Set<String>();
            Map<String, List<String>> managementIdToUsersMap = new Map<String, List<String>>();

            for (User u : scope) {
                if (u.CRM_GenesysID__c != null) {
                    uToEstract.add(u.CRM_ManagementID__c + '_' + u.CRM_GenesysID__c);
                }
            }

            for (User u : scope) {
                processedManagementIds.add(u.CRM_ManagementID__c);
            }

            for (User user : scope) {
                if (managementIdToUsersMap.containsKey(user.CRM_ManagementID__c)) {
                    managementIdToUsersMap.get(user.CRM_ManagementID__c).add(user.CRM_GenesysID__c);
                } else {
                    managementIdToUsersMap.put(user.CRM_ManagementID__c, new List<String>{user.CRM_GenesysID__c});
                }
            }

            Integer uniqueKeysCount = managementIdToUsersMap.keySet().size();

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

            for (String u : managementIdToUsersMap.keySet()) {
                saveCounter = 0;
                while (saveCounter < 3) {
                    HttpResponse estrazioneResp = estrazioneVSGenesys(managementIdToUsersMap.get(u), managementIdToUsersMap.keySet());
                    if (estrazioneResp.getStatusCode() == 200) {
                        responseBodies.add(estrazioneResp.getBody());
                        break;
                    } else {
                        saveCounter++;
                    }
                }
                if (saveCounter == 3) {
                    throw new SendRequestException('Estrazione Genesys fallita');
                }
            }

            
        } catch (Exception e) {
            String errorMessage = e.getMessage();
            System.debug('Error: ' + errorMessage + '; at: ' + e.getStackTraceString());
        }
    }

    public void finish(Database.BatchableContext bc) {

        for (String responseBody : responseBodies) {
            processResponseAndUpsert(responseBody);
        }
        
        if (!logsToInsert.isEmpty()) {
            insert logsToInsert;
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

    private void processResponseAndUpsert(String responseBody) {
        try {
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(responseBody);

            Map<String, Object> result = (Map<String, Object>) jsonResponse.get('result');
            List<Object> agentSchedules = (List<Object>) result.get('agentSchedules');

            List<CRM_TurniPianificati__c> turniPianificatiList = new List<CRM_TurniPianificati__c>();

            Set<String> activityCodeIds = new Set<String>();

            Set<String> userids = new Set<String>();

            for (Object agentSchedule : agentSchedules) {
                Map<String, Object> schedule = (Map<String, Object>) agentSchedule;
                Map<String, Object> user = (Map<String, Object>) schedule.get('user');
                string userid = (string) user.get('id');
                userids.add(userid);
                List<Object> shifts = (List<Object>) schedule.get('shifts');
                for (Object shift : shifts) {
                    Map<String, Object> shiftData = (Map<String, Object>) shift;
                    List<Object> activities = (List<Object>) shiftData.get('activities');
                    for (Object activity : activities) {
                        Map<String, Object> activityData = (Map<String, Object>) activity;
                        String activityCodeId = (String) activityData.get('activityCodeId');
                        activityCodeIds.add(activityCodeId);
                    }
                }
            }

            Map<string, Sobject> useridMap = new Map<String, SObject>();
            useridMap = SV_Utilities.keyby([SELECT Id, CRM_GenesysID__c FROM User WHERE CRM_GenesysID__c in: userids], 'CRM_GenesysID__c');
            
            Map<String, SObject> activityCodeToDominioTurnoMap = new Map<String, SObject>();
            activityCodeToDominioTurnoMap = SV_Utilities.keyby([SELECT Id, Name, CRM_ActivityCodeID__c FROM CRM_DominioTurni__c WHERE CRM_ActivityCodeID__c in: activityCodeIds], 'CRM_ActivityCodeID__c');
            
            /*for (String activityCodeId : activityCodeIds) {
                List<CRM_DominioTurni__c> dominioTurnoList = ];
                if (!dominioTurnoList.isEmpty()) {
                    activityCodeToDominioTurnoMap.put(activityCodeId, dominioTurnoList[0]);
                }
            }*/

            for (Object agentSchedule : agentSchedules) {
                Map<String, Object> schedule = (Map<String, Object>) agentSchedule;
                Map<String, Object> user = (Map<String, Object>) schedule.get('user');                
                List<Object> shifts = (List<Object>) schedule.get('shifts');
                for (Object shift : shifts) {
                    Map<String, Object> shiftData = (Map<String, Object>) shift;
                    List<Object> activities = (List<Object>) shiftData.get('activities');
                    for (Object activity : activities) {
                        Map<String, Object> activityData = (Map<String, Object>) activity;
                        String activityCodeId = (String) activityData.get('activityCodeId');

                        CRM_DominioTurni__c dominioTurno = (CRM_DominioTurni__c) activityCodeToDominioTurnoMap.get(activityCodeId);

                        if (dominioTurno != null) {
                            String idProfiloGiornaliero = dominioTurno.Name;
                            String userId = (String) user.get('id');
                            String startDate = (String) activityData.get('startDate');

                            CRM_TurniPianificati__c turnoPianificato = new CRM_TurniPianificati__c();
                            turnoPianificato.CRM_User__c = (string) useridMap.get(userId).get('Id');
                            turnoPianificato.CRM_Data__c = Date.valueOf(startDate);
                            turnoPianificato.CRM_IDProfiloGiornaliero__c = idProfiloGiornaliero;
                            turnoPianificato.NDW_ExternalId__c = userId + '_' + turnoPianificato.CRM_Data__c.format('yyyy-MM-dd');

                            turniPianificatiList.add(turnoPianificato);
                        }
                    }
                }
            }

            if (!turniPianificatiList.isEmpty()) {
                upsert turniPianificatiList NDW_ExternalId__c;
            }
        } catch (Exception e) {
            String errorMessage = e.getMessage();
            System.debug('Error during response processing: ' + errorMessage);
        }
    }


    public static HttpResponse estrazioneVSGenesys( List<String> params, Set<String> managementIds){
        Endpoint__c apiRequest = Endpoint__c.getInstance('EstrazioneTurniPianificati');
        Map<String, String> headersReq = new Map<String, String>();
        System.debug('PARAMS RETRIVE: ' + params);

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        for (String mng : managementIds) {
            String endpoint = apiRequest.Endpoint__c.replace('{managementUnitId}', mng);
            request.setEndpoint(endpoint);
            System.debug('ENDPOINT RETRIVE: ' + endpoint);
    
            request.setMethod(apiRequest.Method__c);
            Cache.OrgPartition orgPart = Cache.Org.getPartition('local.Bper');
            String token= (String) orgPart.get('genesysToken');
            request.setHeader('Authorization', 'Bearer '+token);
            headersReq.put('Authorization', 'Bearer '+token);
            request.setHeader('Content-Type', 'application/json');
            headersReq.put('Content-Type', 'application/json');
    
            DateTime startDate = DateTime.newInstance(Date.today().addDays(-8), Time.newInstance(0, 0, 0, 0));
            DateTime endDate = DateTime.newInstance(Date.today().addDays(-1), Time.newInstance(23, 59, 59, 999));
    
            String requestBody = '{"startDate":"' + startDate.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'') + '",' +
                             '"endDate":"' + endDate.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'') + '",' +
                             '"userIds": ["' + String.join(params, '","') + '"]}';
            request.setBody(requestBody);
    
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
    
            logsToInsert.add(writeLog(
                apiRequest.Name,
                apiRequest.Method__c,
                requestBody,
                response.getStatusCode(),
                response.getStatus(),
                response.getBody().length() >= 131071 ? response.getBody().substring(0, 131071) : response.getBody(),
                headersReq,
                headersRes,
                endpoint,
                ''
            ));

            return response;
        }
        return null;
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
        );
        return log;
    }
}