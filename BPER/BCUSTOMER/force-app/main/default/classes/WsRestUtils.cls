public class WsRestUtils {
    public class WsCalloutException extends Exception {}
    public class WsException extends Exception {}
    public static final Decimal DEFAULT_TIMEOUT = 120000;

    public static final Set<String> outOfObjectParams = new Set<String>{'username', 'applicationName'};
    public static Set<String> removeheaderNameSet = new Set<String>{'sbloccoCarta', 'ristampaPin', 'dettaglioPianoRateale', 'listaPiani', 'listaRapporti', 'getOperativita', 'risoluzioneIndirizzi','bperTelephony', 'calculateSimulazione', 'loadAmmortamentoLinea'};
    public static Set<String> secondHeaderSet = new Set<String>{'searchSmartAccountExtended'};
    /*public static Set<String> needsCustomerId = new Set<String>{'unlockAcsK6', 'getAcsKey6Status', 'getTipiBlocco', 'bloccoDebito', 'unlockPoker', 'getInfoCarte', 'getProfiloCarteNDG'};
    public static Set<String> needsChannel = new Set<String>{'dettaglioPianoRateale', 'listaPiani', 'listaRapporti'};
    public static Set<String> needsCorrelationId = new Set<String>{'dettaglioPianoRateale', 'listaPiani', 'listaRapporti'};
    public static Set<String> needsAgenzia = new Set<String>{'sbloccoCarta', 'ristampaPin'};
    public static Set<String> needsLivello = new Set<String>{'sbloccoCarta', 'ristampaPin'};
    public static Set<String> needsUserId = new Set<String>{'ricercaSmartAccountEstesa'};
    public static Set<String> needsBranchCode = new Set<String>{'ricercaSmartAccountEstesa'};*/

    public static Map<String, Set<String>> paramaterNeedMap = new Map<String, Set<String>>{
        'customerId' => new Set<String>{'unlockAcsK6', 'getAcsKey6Status', 'getTipiBlocco', 'bloccoDebito', 'unlockPoker', 'getInfoCarte', 'getProfiloCarteNDG'},
        'channel' => new Set<String>{'dettaglioPianoRateale', 'listaPiani', 'listaRapporti','sbloccoCarta', 'ristampaPin', 'getOperativita', 'risoluzioneIndirizzi', 'bperTelephony', 'calculateSimulazione', 'loadAmmortamentoLinea'},
        'correlationId' => new Set<String>{'dettaglioPianoRateale', 'listaPiani', 'listaRapporti', 'calculateSimulazione', 'loadAmmortamentoLinea'},
        'agenzia' => new Set<String>{'sbloccoCarta', 'ristampaPin'},
        'livello' => new Set<String>{'sbloccoCarta', 'ristampaPin'},
        'userId' => new Set<String>{'ricercaSmartAccountEstesa'},
        'branchCode' => new Set<String>{'ricercaSmartAccountEstesa'}
    };
    // BEGIN NEW: Utilizza nuovo custom setting "Endpoint List"
    public static WsRestInput.CommonResponse callService(Endpoint__c apiRequest, Map<String,String> firstHeaderObject, Map<String,String> secondHeaderObject, Map<String,String> urlParams, Map<String, String> endpointParamsMap, String body, String certificateName, Boolean disableLog) {
        WsRestInput.CommonResponse responseObj = new WsRestInput.CommonResponse();

        HTTPResponse response;
        try {
            response = WsRestUtils.makeRequest(apiRequest, firstHeaderObject, secondHeaderObject, urlParams, endpointParamsMap, body, certificateName, disableLog);
            responseObj.statusCode = String.valueOf(response.getStatusCode());
            responseObj.data = response.getBody();
        }
        catch(Exception exc) {
            responseObj.exceptionError = exc.getMessage();
        }

        return responseObj;
    }

    private static HTTPResponse makeRequest(Endpoint__c apiRequest, Map<String,String> firstHeaderObject, Map<String,String> secondHeaderObject, Map<String,String> urlParams, Map<String,String> endpointParamsMap, String body, String certificateName, Boolean disableLog) {
        
        String endpoint = apiRequest.Endpoint__c;
        String method = apiRequest.Method__c;
        Decimal timeout = apiRequest.Timeout__c;
        System.debug('SV makeRequest endpoint: ' + endpoint);
        System.debug('SV makeRequest method: ' + method);
        System.debug('SV makeRequest urlParams: ' + urlParams);
        System.debug('SV makeRequest FirstHeaderObject: ' + FirstHeaderObject);
        System.debug('SV makeRequest secondHeaderObject: ' + secondHeaderObject);
        System.debug('SV makeRequest body: ' + body);
        System.debug('SV makeRequest certificateName: ' + certificateName);
        System.debug('SV makeRequest disableLog: ' + disableLog);
        System.debug('SV makeRequest timeout: ' + timeout);

        HttpRequest req = new HttpRequest();
        // Map<String, String> testataMap = (Map<String,String>)JSON.deserialize(JSON.serialize(testata), Map<String,String>.class);
        // Map<String, String> securityMap = (Map<String,String>)JSON.deserialize(JSON.serialize(security), Map<String,String>.class);
        for(String key : urlParams.keySet()){
            System.debug(key);
            endpoint = endpoint.replace(key, urlParams.get(key));
        }
        
        if(!endpointParamsMap.isEmpty()){
            List<String> paramsList = new List<String>();
            endpoint += '?';
            for(String paramName : endpointParamsMap.keySet()){

                paramsList.add(paramName + '=' + endpointParamsMap.get(paramName));
            }
            endpoint += String.join(paramsList, '&');
        }
        Map<String,String> headersReq= new Map<String,String>();
        System.debug('SV final endpoint: ' + endpoint);
        
        String firstHeaderObjectName = secondHeaderSet.contains(apiRequest.Name) ? 'userProfile' : 'testata';
        String secondHeaderObjectName = secondHeaderSet.contains(apiRequest.Name) ? 'bindingInfo' : 'security';
        firstHeaderObject = getFinalHeader(apiRequest.Name, firstHeaderObjectName, firstHeaderObject, urlParams, endpointParamsMap);
        secondHeaderObject = getFinalHeader(apiRequest.Name, secondHeaderObjectName, secondHeaderObject, urlParams, endpointParamsMap);

        String firstHeaderNameToSet = removeheaderNameSet.contains(apiRequest.Name) ? '' : firstHeaderObjectName + '_';
        String secondHeaderNameToSet = removeheaderNameSet.contains(apiRequest.Name) ? '' : secondHeaderObjectName + '_';
        for(String key: firstHeaderObject.keySet()){

            if(firstHeaderObject.get(key) != null){
                System.debug('DK firstHeaderObject_key: ' + key);
                System.debug('DK firstHeaderObject_value: ' + firstHeaderObject.get(key));
                headersReq.put(!outOfObjectParams.contains(key) ? firstHeaderNameToSet + key : key, firstHeaderObject.get(key));
                req.setHeader(!outOfObjectParams.contains(key) ? firstHeaderNameToSet + key : key, firstHeaderObject.get(key));
            }else if(firstHeaderObjectName == 'userProfile' || key == 'token'){
               
                headersReq.put(!outOfObjectParams.contains(key) ? firstHeaderNameToSet + key : key, '');
                req.setHeader(!outOfObjectParams.contains(key) ? firstHeaderNameToSet + key : key, '');
            }
        }

        if(apiRequest.Name != 'unlockAcsK6'){

            for(String key: secondHeaderObject.keySet()){
    
                if(secondHeaderObject.get(key) != null){
                    headersReq.put(!outOfObjectParams.contains(key) ? secondHeaderNameToSet + key : key, secondHeaderObject.get(key));
                    req.setHeader(!outOfObjectParams.contains(key) ? secondHeaderNameToSet + key : key, secondHeaderObject.get(key));
                }else if(secondHeaderObjectName == 'bindingInfo' || key == 'token'){
                   
                    headersReq.put(!outOfObjectParams.contains(key) ? secondHeaderNameToSet + key : key, '');
                    req.setHeader(!outOfObjectParams.contains(key) ? secondHeaderNameToSet + key : key, '');
                }
            }
        }

        if(apiRequest.Name == 'searchSmartAccountExtended'){

            req.setHeader('ltpaToken2', 'EXTENDED');
            headersReq.put('ltpaToken2', 'EXTENDED');
        }
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        headersReq.put('Content-Type', 'application/json');
        headersReq.put('Accept', 'application/json');
        if(apiRequest.Name == 'aggiornaFilialeDiRelazione'){

            req.setHeader('Content-Length', '0');
            headersReq.put('Content-Length', '0');
        }
        req.setEndpoint(endpoint);
        req.setMethod(method);
        req.setTimeout(timeout.intValue());
        if(certificateName != null) req.setClientCertificateName(certificateName);

        if(body != null) req.setBody(body);
        //Execute web service call here 
        Http http = new Http();               
        HTTPResponse res = http.send(req);
    
        //Helpful debug messages 
        System.debug(res.toString()); 
        System.debug('SV STATUS: ' + res.getStatus()); 
        System.debug('SV STATUS_CODE: ' + res.getStatusCode()); 
        System.debug('SV RESPONSE_BODY: ' + res.getBody());
        string[] headerkeysRes = res.getHeaderKeys();

        //create an object to store your header key-value pairs
        Map<string, string> headersRes = new map<string, string>();

        //iterate through they keys, and populate your map
        for(string s : headerkeysRes){
        headersRes.put(s,res.getHeader(s));
        }

        

        // Map<String, Object> resBody = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        // System.debug('resBody: ' + resBody);
        System.debug('@@@@@@headersReq: '+JSON.serializePretty(headersReq));
        System.debug('@@@@@@headersRes: '+JSON.serializePretty(headersRes));
        if(disableLog == null){
            
            disableLog = false;
        }
        if(!disableLog){
            writeLog(
                apiRequest.Name,
                method,
                body,
                res.getStatusCode(),
                res.getStatus(),
                res.getBody(),
                headersReq,
                headersRes,
                endpoint,
                ''
                // responseObj.isCorrect() ? null : responseObj.getErrors()
            );
        }
        return res;
    }
    // END NEW: Utilizza nuovo custom setting "Endpoint List"

    // // ES: POST CON PARAMETRI
    // public static WsRestInput.CommonResponse callService(String urlField, String method, String certificateName, WsRestInput.Testata testata, WsRestInput.Security security, Decimal timeout, Map<String,String> urlParams, String body) {
    //     WsRestInput.CommonResponse responseObj = new WsRestInput.CommonResponse();

    //     String response;
    //     try {
    //         response = WsRestUtils.makeRequest(urlField, method, urlParams, testata, security, body, certificateName, timeout);
    //         responseObj.data = response;
    //     }
    //     catch(Exception exc) {
    //         responseObj.exceptionError = exc.getMessage();
    //     }

    //     return responseObj;
    // }

    // // ES: GET CON PARAMETRI NO BODY
    // public static WsRestInput.CommonResponse callService(String urlField, String method, String certificateName,  WsRestInput.Testata testata, WsRestInput.Security security, Decimal timeout, Map<String,String> urlParams) {
    //     WsRestInput.CommonResponse responseObj = new WsRestInput.CommonResponse();

    //     String response;
    //     try {
    //         response = WsRestUtils.makeRequest(urlField, method, urlParams, testata, security, null, certificateName, timeout);
    //     }
    //     catch(Exception exc) {
    //         responseObj.exceptionError = exc.getMessage();
    //     }

    //     return responseObj;
    // }

    // // ES: GET NO PARAMETRI NO BODY
    // public static WsRestInput.CommonResponse callService(String urlField, String method, String certificateName,  WsRestInput.Testata testata, WsRestInput.Security security, Decimal timeout) {
    //     WsRestInput.CommonResponse responseObj = new WsRestInput.CommonResponse();

    //     String response;
    //     try {
    //         response = WsRestUtils.makeRequest(urlField, method, null, testata, security, null, certificateName, timeout);
    //     }
    //     catch(Exception exc) {
    //         responseObj.exceptionError = exc.getMessage();
    //     }

    //     return responseObj;
    // }

    // private static String makeRequest(String urlField, String method, Map<String,String> urlParams,  WsRestInput.Testata testata, WsRestInput.Security security, String body, String certificateName, Decimal timeout) {
    //     System.debug('SV makeRequest urlField: ' + urlField);
    //     System.debug('SV makeRequest method: ' + method);
    //     System.debug('SV makeRequest urlParams: ' + urlParams);
    //     System.debug('SV makeRequest testata: ' + testata);
    //     System.debug('SV makeRequest security: ' + security);
    //     System.debug('SV makeRequest body: ' + body);
    //     System.debug('SV makeRequest certificateName: ' + certificateName);
    //     System.debug('SV makeRequest timeout: ' + timeout);

    //     HttpRequest req = new HttpRequest();
    //     String endpoint = getEndpoint(urlField);
        
    //     for(String key : urlParams.keySet()){
    //         System.debug(key);
    //         endpoint = endpoint.replace(key, urlParams.get(key));
    //     }
        
    //     System.debug('endpoint: ' + endpoint);
    //     System.debug(WsRestInput.toJSONString(testata));
    //     System.debug(WsRestInput.toJSONString(security));

    //     req.setHeader('Content-Type', 'application/json');
    //     req.setHeader('Accept', 'application/json');
    //     if(testata != null) req.setHeader('Testata', WsRestInput.toJSONString(testata));
    //     if(security != null) req.setHeader('Security', WsRestInput.toJSONString(security));
    //     req.setEndpoint(endpoint);
    //     // req.setEndpoint('https://apigw-test.bper.it:443/gateway/BperApi/v1/conti-correnti/abi/05387/codiceFiliale/abc/numeroConto/123');
    //     // req.setEndpoint('https://putsreq.com/wYqdH8dSlNQZKw0DaBda');
    //     req.setMethod(method);
    //     req.setTimeout(timeout.intValue());
    //     if(certificateName != null) req.setClientCertificateName(certificateName);

    //     if(body != null) req.setBody(body);
    //     //Execute web service call here 
    //     Http http = new Http();               
    //     HTTPResponse res = http.send(req);
    
    //     //Helpful debug messages 
    //     System.debug(res.toString()); 
    //     System.debug('STATUS: '+res.getStatus()); 
    //     System.debug('STATUS_CODE: '+res.getStatusCode()); 
    //     System.debug ('HTTPResponse Body: '+ res.getBody());

    //     // Map<String, Object> resBody = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
    //     // System.debug('resBody: ' + resBody);

    //     writeLog(
    //         urlField,
    //         method,
    //         body,
    //         res.getStatusCode(),
    //         res.getStatus(),
    //         res.getBody(),
    //         ''
    //         // responseObj.isCorrect() ? null : responseObj.getErrors()
    //     );
    //     return res.getBody();
    // }

    public static Map<String,String> getFinalHeader(String apiRequestName, String headerObjectName, Map<String,String> headerObject, Map<String,String> urlParams, Map<String,String> endpointParamsMap){

        if(urlParams.containsKey('{abi}')){
            if(headerObjectName == 'userProfile'){
                headerObject.put('ABI', urlParams.get('{abi}'));
                headerObject.put('banca', urlParams.get('{abi}'));
            } else {
                headerObject.put('abi', urlParams.get('{abi}'));
            }
            if(headerObjectName == 'security'){
                headerObject.put('banca', urlParams.get('{abi}'));
            }
        } else if (endpointParamsMap.containsKey('abi')) {
            if(headerObjectName == 'userProfile'){
                headerObject.put('ABI', endpointParamsMap.get('abi'));
                headerObject.put('banca', endpointParamsMap.get('abi'));
            } else {
                headerObject.put('abi', endpointParamsMap.get('abi'));
            }
            if(headerObjectName == 'security'){
                headerObject.put('banca', endpointParamsMap.get('abi'));
            }
        }

        for(String key : paramaterNeedMap.keySet()){
            if(!paramaterNeedMap.get(key).contains(apiRequestName)){
                if(headerObject.containsKey(key))headerObject.remove(key);
            }     
        }

        return headerObject;
    }




    public WsRestUtils() {

    }

    // public static WsRestInput.CommonResponse callServiceIntranet() {
    //     Map<String,String> testata = new Map<String,String>{
    //         'channel'=>'?',
    //         'userid'=>'?',
    //         'customerid'=>'?',
    //         'abi'=>'05387',
    //         'cab'=>'66670',
    //         'branchcode'=>'0036',
    //         'channel'=>'IBPR',
    //         'userId'=>'HBPR',
    //         'terminal'=>'FN*Z',
    //         'customerid'=>'48129729',
    //         'operationid'=>'048129729001486555420292',
    //         'syscaller'=>'IBPR',
    //         'fncaller'=>'listMovements',
    //         'reqtype'=>'I',
    //         'serviceName'=>'',
    //         'fnmame'=>'',
    //         'serviceversion'=>'',
    //         'timestamp'=>'00000000000001486555420334'
    //     };
    //     Map<String,String> security = new Map<String,String>{
    //         'banca'=>'05387',
    //         'utente'=>'2374',
    //         'terminale'=>'49E*',
    //         'applicazione'=>'WEBGEN',
    //         'token'=>'',
    //         'idced'=>'6262',
    //         'ip'=>'192.168.103.16'
    //     };
    //     return callService('urlField',testata,security,DEFAULT_TIMEOUT);
    // }
    
    /* Generic classes */

    // public static WsRestInput.CommonResponse callService(String urlField, Map<String,String> testata, Map<String,String> security, Decimal timeout) {
    //     WsRestInput wsRestInputRequest = new WsRestInput(testata,security,null);
    //     WsRestInput.CommonResponse responseObj = new WsRestInput.CommonResponse();
    //     String response;
    //     try {

    //         response = WsRestUtils.makeRequest(urlField,timeout,wsRestInputRequest);
    //         // Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response);
    //         // System.debug('response: ' + JSON.serializePretty(response));
    //     }
    //     catch(Exception exc) {
    //         responseObj.exceptionError = exc.getMessage();
    //     }

    //     // writeLog(
    //     //     urlField,
    //     //     '',
    //     //     response,
    //     //     responseObj.isCorrect() ? null : responseObj.getErrors()
    //     // );
    //     // System.debug('AAA responseObj : '+JSON.serialize(responseObj));
    //     // if (!responseObj.isCorrect()) {
    //     //     throw new WsCalloutException(responseObj.getErrors());
    //     // }

    //     return responseObj;
    // }

    // private static String makeRequest(String urlField, Decimal timeout, WsRestInput wsRestInputRequest) {

    //     HttpRequest req = new HttpRequest();
    //     String endpoint = getEndpoint('Url_Test__c').replace('{abi}', '05387').replace('{codiceFiliale}', 'abc').replace('{numeroConto}', '123');
    //     req.setHeader('Content-Type', 'application/json');
    //     req.setHeader('Testata', WsRestInput.toJSONString(wsRestInputRequest.headers.testata));
    //     req.setHeader('Security',WsRestInput.toJSONString(wsRestInputRequest.headers.security));
    //     req.setEndpoint(endpoint);
    //     // req.setEndpoint('https://apigw-test.bper.it:443/gateway/BperApi/v1/conti-correnti/abi/05387/codiceFiliale/abc/numeroConto/123');
    //     // req.setEndpoint('https://putsreq.com/wYqdH8dSlNQZKw0DaBda');
    //     req.setMethod('GET');
    //     if(req.getMethod() == 'POST'){

    //         req.setBody(WsRestInput.toJSONString(wsRestInputRequest.payload));
    //     }
        // req.setTimeout(timeout.intValue());
        // req.setClientCertificateName('salesforcetestclient2022');
        // //Execute web service call here 
        // Http http = new Http();               
        // HTTPResponse res = http.send(req);
    
        // //System.debug(urlField + ' - body: ' + body);
        // //Helpful debug messages 
        // System.debug(res.toString()); 
        // System.debug('STATUS: '+res.getStatus()); 
        // System.debug('STATUS_CODE: '+res.getStatusCode()); 
        // System.debug ('HTTPResponse Body: '+ res.getBody());

        // // Map<String, Object> resBody = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        // // System.debug('resBody: ' + resBody);
        // return res.getBody();
    //   }

    public static void writeLog(String apiRequestName, String method, String input, Integer code, String status, String output,  Map<String,String> reqHeader, Map<String,String> resHeader, String endpoint, String errorMessage) {

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
        insert new SV_Log__c(
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

    }

    public static void writeLog(String apiRequestName, String method, String input, String code, String status, String output,  Map<String,String> reqHeader, Map<String,String> resHeader, String endpoint, String errorMessage) {

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
        insert new SV_Log__c(
            Source__c = apiRequestName,
            Method__c = method,
            Code__c = code,
            Status__c = status,
            Input_Payload__c = inputPretty != null && inputPretty.length() >= 131071 ? inputPretty.substring(0, 131071) : inputPretty,
            Output_Payload__c = outputPretty != null && outputPretty.length() >= 131071 ? outputPretty.substring(0, 131071) : outputPretty,
            Success__c = code == '000' ? true : false,
            ResponseHeader__c=resHeaderPretty,
            RequestHeader__c=reqHeaderPretty,
            Endpoint__c = path[0],
            Parameters__c = path.size() > 1 ? path[1] : ''
            // ErorrMessage__c = errorMessage

        );

    }

    // private static String getEndpoint(String urlField) {
    //     // EndpointServizi__c endpoint = EndpointServizi__c.getInstance('settings');
    //     // EndpointServizi__c endpoint = EndpointServizi__c.getOrgDefaults();
    //     String url = (String) EndpointServizi__c.getInstance().get(urlField);
    //     if (url == null) throw new WsException('custom settings non impostato per l\'URL :' + urlField);
    //     return url;
    // }
}