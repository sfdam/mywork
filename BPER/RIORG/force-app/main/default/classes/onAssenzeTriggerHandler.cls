/****
 * Name         :   onFerieTrigger
 * Created Date :   2023-13-06
 * Author       :   Lorenzo Vento @TEN
 ****/

 public with sharing class onAssenzeTriggerHandler {

    private static final String NOME_CLASSE = 'onAssenzeTriggerHandler';
    private static final Integer MAX_N_TRIALS = 3;
    private static final String MANAGEMENT_ENDPOINT_NAME = 'EstrazioneCodiceTimeoff';
    private static final String ESTRAZIONE_ENDPOINT_NAME = 'Inserimento richiesta timeoff';
    public static Boolean isFirstTime = true;
    public static List<SV_Log__c> logsToInsert = new List<SV_Log__c>();

    public static void genesysQueueCallout(Map<Id, CRM_Assenze__c> newCRMAssenzeMap) {

        Set<Id> setIdsCRMAssenze = newCRMAssenzeMap.keySet();
        handleAfterInsert(setIdsCRMAssenze);
    }

    /* FIE 19/07/2023
    @future(callout=true) 
    */
    public static void handleAfterInsert(Set <Id> setIdsCRMAssenze) {
        try {
            
            Cache.OrgPartition orgPart = Cache.Org.getPartition('local.Bper');
            Integer authCounter;
            Integer managementCounter;
            Integer estrazioneCounter;

            List <CRM_Assenze__c> newCRMAssenzeList = [SELECT Id, Name, CRM_SyncGenesys__c, STG_X_Update_TS__c, CRM_Matricola__c, NDW_ExternalId__c, CRM_Inizioassenza__c, CRM_FineAssenza__c,
                                                        CRM_User__c, CRM_User__r.CRM_BusinessUnitID__c, CRM_User__r.CRM_ManagementID__c, CRM_User__r.CRM_GenesysID__c, CRM_Giornataintera__c
                                                        FROM CRM_Assenze__c
                                                        WHERE Id IN :setIdsCRMAssenze];

            Map<Id, CRM_Assenze__c> newCRMAssenzeMap = new Map<Id, CRM_Assenze__c>();
            
            for (CRM_Assenze__c aass : newCRMAssenzeList) {
                newCRMAssenzeMap.put(aass.Id, aass);
            }


            Map<String, String> mapIdAssenzeBusiness = new Map<String, String>();
            List<CRM_Assenze__c> newCRMAssenzeListToUpdate = new List<CRM_Assenze__c>();

            for (CRM_Assenze__c a : newCRMAssenzeList) {
                authCounter = managementCounter = 0;
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
                    while (managementCounter < MAX_N_TRIALS) {
                        String param = newCRMAssenzeMap.get(a.Id).CRM_User__r.CRM_BusinessUnitID__c != null? newCRMAssenzeMap.get(a.Id).CRM_User__r.CRM_BusinessUnitID__c : 'null';
                        HttpResponse managementResp = managementVSGenesys(param);
                        System.debug('RC managementResp: ' + managementResp);
                        if (managementResp.getStatusCode() == 200) {
                            System.debug('DENTRO MANAGEMENT');
                            Map<String, Object> deserialized = (Map <String, Object>) JSON.deserializeUntyped(managementResp.getBody());
                            List<Map<String, Object>> data = new List<Map<String, Object>>();
                            for (Object instance : (List<Object>)deserialized.get('entities')) {
                                data.add((Map<String, Object>)instance); 
                            }
                            String businessId;
                            for (Map<String, Object> mapResult : data) {
                                if (String.valueOf(mapResult.get('category')).equalsIgnoreCase('TimeOff')) {
                                    businessId = (String) mapResult.get('id');
                                    break;
                                }
                            }
                            mapIdAssenzeBusiness.put(a.Id, businessId);
                            System.debug('mapIdAssenzeBusiness -> ' + mapIdAssenzeBusiness);
                            break;
                        } else {
                            managementCounter++;
                        }
                    }
                    if (managementCounter == MAX_N_TRIALS) {
                        System.debug('Management Genesys fallito');
                    }
                
                    if (managementCounter < MAX_N_TRIALS) {
                        estrazioneCounter = 0;
                        while (estrazioneCounter < MAX_N_TRIALS) {
                            String crmManagementId;
                            String crmGenesysId;
                            String activityCodeId;
                            Date fullDayManagementUnitDates;
                            Long dailyDurationMinutes;

                            if (mapIdAssenzeBusiness.containsKey(a.Id)) {
                                crmManagementId = newCRMAssenzeMap.get(a.Id).CRM_User__r.CRM_ManagementID__c;
                                crmGenesysId = newCRMAssenzeMap.get(a.Id).CRM_User__r.CRM_GenesysID__c;
                                activityCodeId = mapIdAssenzeBusiness.get(a.Id);
                                DateTime inizioAssenzaDt = newCRMAssenzeMap.get(a.Id).CRM_Inizioassenza__c;
                                fullDayManagementUnitDates = date.newinstance(inizioAssenzaDt.year(), inizioAssenzaDt.month(), inizioAssenzaDt.day());
                                DateTime fineAssenzaDt = newCRMAssenzeMap.get(a.Id).CRM_FineAssenza__c;
                                Long inizioAssenzaMs = inizioAssenzaDt.getTime();
                                Long fineAssenzaMs =  fineAssenzaDt.getTime();
                                Long msDifference = fineAssenzaMs - inizioAssenzaMs;
                                dailyDurationMinutes = msDifference / (Long) 60000;
                                string giornataInter = '';
                                
                                // Imposto il fuso orario a quello italiano
                                /*TimeZone tz = TimeZone.getTimeZone('Europe/Rome');
                                inizioAssenzaDt = inizioAssenzaDt.addMinutes(tz.getOffset(inizioAssenzaDt) / 1000 / 60);*/
                                
                                // Converto la data nel formato desiderato con 'Z' alla fine
                                String dataInizioAssenzaFormattata = inizioAssenzaDt.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
                                System.debug(dataInizioAssenzaFormattata );  // Stampa: 2023-10-31T13:35:00Z
                                

                                //String params = crmManagementId +'_' + crmGenesysId + '_' + activityCodeId + '_' + String.valueOf(fullDayManagementUnitDates) + '_' + String.valueOf(dailyDurationMinutes);
                                String params = crmManagementId +'_' + crmGenesysId + '_' + activityCodeId + '_' + String.valueOf(dataInizioAssenzaFormattata ) + '_' + String.valueOf(dailyDurationMinutes);
                                System.debug('LV params: ' + params);
                                
                                HttpResponse estrazioneResp = new HttpResponse();
                                // FIE 07/08/2023 
                                if (a.CRM_Giornataintera__c == 'G'){
            
                                    Date inizioAssenzaD = Date.newInstance(inizioAssenzaDT.Year(),inizioAssenzaDt.Month(),inizioAssenzaDt.day());
                                    Date fineAssenzaD = Date.newInstance(fineAssenzaDt.year(), fineAssenzaDt.month(), fineAssenzaDt.day());
                                    Integer DayDifference = inizioAssenzaD.daysBetween(fineAssenzaD);
                                    boolean paid = True;
                                    giornataInter = 'G';

                                    String paramsG = crmManagementId + '_' + crmGenesysId + '_' + activityCodeId + '_' + string.valueOf(inizioAssenzaD) + '_' + String.valueOf(dailyDurationMinutes);
                                    estrazioneResp = estrazioneVSGenesys(paramsG.split('_'), giornataInter);
                                } else if (a.CRM_Giornataintera__c == null || a.CRM_Giornataintera__c == '') {
                                    estrazioneResp = estrazioneVSGenesys(params.split('_'), giornataInter);
                                }
                                // END
                                System.debug('RC estrazioneResp: ' + estrazioneResp);
                                if (estrazioneResp.getStatusCode() == 200) {
                                    System.debug('DENTRO ESTRAZIONE');
                                    CRM_Assenze__c assenza = newCRMAssenzeMap.get(a.Id);
                                    assenza.CRM_SyncGenesys__c = true;
                                    newCRMAssenzeMap.put(a.Id, assenza);
                                    break;
                                } else {
                                    estrazioneCounter++;
                                }
                            }   
                        }

                        if (estrazioneCounter == MAX_N_TRIALS) {
                            System.debug('Estrazione Genesys fallita');
                        }
                    }
                }
            }

            newCRMAssenzeListToUpdate = newCRMAssenzeMap.values();

            //update newCRMAssenzeListToUpdate;
            isFirstTime = false;

            if (!logsToInsert.isEmpty()) {
                insert logsToInsert;
            }

        } catch (Exception e) {
            System.debug(NOME_CLASSE + ' - An exception occurred during handleAfterInsert : ' + e.getMessage());
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

    public static HttpResponse managementVSGenesys(String params){
        Endpoint__c apiRequest = Endpoint__c.getInstance(MANAGEMENT_ENDPOINT_NAME);
        Map<String, String> headersReq = new Map<String, String>();
            
        System.debug('MANAGEMENT ESTRAZIONE: ' + params);
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String businessId = params;
        String endpoint = (apiRequest.Endpoint__c).replace('{businessUnitId}', businessId);
        request.setEndpoint(endpoint);
        System.debug('ENDPOINT MANAGEMENT: ' + endpoint);
        request.setMethod(apiRequest.Method__c);
        Cache.OrgPartition orgPart = Cache.Org.getPartition('local.Bper');
        String token = (String) orgPart.get('genesysToken');
        request.setHeader('Authorization', 'Bearer '+token);
        headersReq.put('Authorization', 'Bearer '+token);
        request.setHeader('Content-Type', 'application/json');
        headersReq.put('Content-Type', 'application/json');

        System.debug('REQUEST MANAGEMENT: ' + request);

        HttpResponse response = http.send(request);

        string[] headerkeysRes = response.getHeaderKeys();

        //create an object to store your header key-value pairs
        Map<string, string> headersRes = new map<string, string>();

        //iterate through they keys, and populate your map
        for(string s : headerkeysRes){
            headersRes.put(s,response.getHeader(s));
        }

        System.debug('@@@@@managementResponse'+response.getBody());
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

        return response;
    }

    public static HttpResponse estrazioneVSGenesys(List<String> params, String giornataInter) {
        Endpoint__c apiRequest = Endpoint__c.getInstance(ESTRAZIONE_ENDPOINT_NAME);
        Map<String, String> headersReq = new Map<String, String>();
                
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String crmManagementId = params[0];
        String crmGenesysId = params[1];
        String activityCodeId = params[2];
        String fullDayManagementUnitDates = params[3];
        String partialDayStartDateTimes = params[3];
        String dailyDurationMinutes = params[4];
    
        String endpoint = (apiRequest.Endpoint__c).replace('{managementUnitId}', crmManagementId);
        params.remove(0);
        System.debug('PARAMS ESTRAZIONE: ' + params);
        request.setEndpoint(endpoint);
        System.debug('ENDPOINT ESTRAZIONE: ' + endpoint);
        request.setMethod(apiRequest.Method__c);
        Cache.OrgPartition orgPart = Cache.Org.getPartition('local.Bper');
        String token = (String) orgPart.get('genesysToken');
        request.setHeader('Authorization', 'Bearer '+token);
        headersReq.put('Authorization', 'Bearer '+token);
        request.setHeader('Content-Type', 'application/json');
        headersReq.put('Content-Type', 'application/json');
        
        Map<String, Object> body = new Map<String,Object>();
        Map<String, Object> bodyIdGenesys = new Map<String, Object>();
        bodyIdGenesys.put('id', crmGenesysId);
        body.put('status', 'APPROVED');
        body.put('users', new List<Map<String, Object>>{bodyIdGenesys});
        body.put('activityCodeId', activityCodeId);
    
        if (giornataInter == 'G') {
            body.put('fullDayManagementUnitDates', new List<String>{fullDayManagementUnitDates});
        } else {
            System.debug('GB partialDayStartDateTimes: '+partialDayStartDateTimes);
            body.put('partialDayStartDateTimes', new List<String>{partialDayStartDateTimes});
        }
    
        body.put('dailyDurationMinutes', dailyDurationMinutes);
        System.debug('GB dailyDurationMinutes: '+dailyDurationMinutes);
        body.put('paid', 'true');
    
        request.setBody(JSON.serialize(body));
    
        System.debug('REQUEST ESTRAZIONE: ' + request);
        System.debug('REQUEST BODY: ' + JSON.serialize(body));
    
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