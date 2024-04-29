public with sharing class REST_KopernicoAPI {

    public class FlowInputs {
        @InvocableVariable
        public String codiceSegnalatore;
    }

    public class FlowOutputs {
        @InvocableVariable
        public Boolean response;
    }

    public class ResponseRecuperaAgenzie{
        public Map<String, List<Agenzie>> listaAgenzie;
    }
    
    public static ResponseRecuperaAgenzie parseResponseRecuperaAgenzie(String json){
        return (ResponseRecuperaAgenzie) System.JSON.deserialize(json, ResponseRecuperaAgenzie.class);
    }
    public class Agenzie{
        public String tipologia{get;set;}
        public String codice{get;set;}
        public String denominazione{get;set;}
        public String indirizzo{get;set;}
        public String comune{get;set;}
        public String provincia{get;set;}
        public String regione{get;set;}
        public String cap{get;set;}
        public String telefono{get;set;}
        public String compagnia{get;set;}
        public String dataInizio{get;set;}
        public String codiceSegnalatore{get;set;}
    }

    @InvocableMethod
    public static List<FlowOutputs> makeRequest(List<FlowInputs> inputs){

        Map<String, Object> mapInput = new Map<String, Object>{'codiceSegnalatore' => inputs[0].codiceSegnalatore};

        Map<String, Object> response = new Map<String, Object>();

        List<FlowOutputs> outputs = new List<FlowOutputs>();
        try {
            response = invokeWS(null, mapInput, '');

            FlowOutputs output = new FlowOutputs();
            output.response = (Boolean)response.get('esito');
            outputs.add(output);

        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR,'### Exception KopernicoAPI: '+e.getMessage()+' at line: '+e.getLineNumber());
        }
        System.debug(LoggingLevel.DEBUG,'### result: '+response);
        System.debug(LoggingLevel.DEBUG,'*** END -- makeRequest Method ***');

        return outputs;
    }

    public static Map<String, Object> invokeWS(List<SObject> SObjectList, Map<String, Object> inputs, String runAsUserId){
        String codice = ((String)inputs.get('codiceSegnalatore')).substring(0,10);
        System.debug('inputs: ' + JSOn.serialize(inputs));
        userId = !String.isBlank(runAsUserId) ? runAsUserId : UserInfo.getUserId();

        WsRestInput restInput = new WsRestInput(currentUser, null);
        Map<String,String> testataMap = (Map<String,String>)JSON.deserialize(JSON.serialize(restInput.headers.testata), Map<String,String>.class);
        String certificationName = 'salesforcetestclient2024';
        Endpoint__c apiRequest = Endpoint__c.getInstance('KopernicoAPI');
        String endpoint = apiRequest.Endpoint__c;
        Map<String,String> endpointParams = !String.isBlank(apiRequest.EndpointParams__c) ? (Map<String,String>)JSON.deserialize(apiRequest.EndpointParams__c, Map<String,String>.class) : null;
        String method = apiRequest.Method__c;
        Decimal timeout = apiRequest.Timeout__c;
        Map<String, String> headersReq = new Map<String, String>();
        HttpRequest req = new HttpRequest();

        for(String key: testataMap.keySet()){

            if(testataMap.get(key) != null){
                req.setHeader(!WsRestUtils.outOfObjectParams.contains(key) ? 'testata' + '_' + key : key, testataMap.get(key));
                headersReq.put(!WsRestUtils.outOfObjectParams.contains(key) ? 'testata' + '_' + key : key, testataMap.get(key));
            }
            else{
               /*
                req.setHeader(!WsRestUtils.outOfObjectParams.contains(key) ? 'testata' + '_' + key : key, '');
                headersReq.put(!WsRestUtils.outOfObjectParams.contains(key) ? 'testata' + '_' + key : key, '');*/
            }
        }
        
        List<String> params = new List<String>();
        System.debug('DK endpointParams: ' + JSON.serialize(endpointParams));
        if(endpointParams != null){
            for(String key : endpointParams.keySet()){
                if(inputs.containsKey(key)){
                    params.add(key + '=' + inputs.get(key));
                }else{
                    params.add(key + '=' + endpointParams.get(key));
                }
            }
            if(!params.isEmpty()){
                endpoint += '?';
                endpoint += String.join(params, '&');
            }
        }
        
        req.setHeader('Content-Type', 'application/json');
        headersReq.put('Content-Type', 'application/json');
        req.setEndpoint(endpoint);
        req.setMethod(method);
        req.setTimeout(timeout.intValue());
        if(certificationName != null && !Test.isRunningTest()){
            req.setClientCertificateName(certificationName);
        }

        Http http = new Http();               
        HTTPResponse res = http.send(req);
        String response = res.getBody();
        System.debug('DK response: ' +  response);
        Boolean result = false;
        if(String.valueOf(res.getStatusCode()).startsWith('2')){

            ResponseRecuperaAgenzie resObj = parseResponseRecuperaAgenzie(response);
    
            //List<FlowOutputs> responseList = new List<FlowOutputs>();
            for(String key : resObj.listaAgenzie.keySet()){
                //FlowOutputs out = new FlowOutputs();
                for(Agenzie a : resObj.listaAgenzie.get(key)){
                    
                    if(a.codiceSegnalatore==codice){
                        result=true;
                        break;
                    }
                }
            }
        }

        string[] headerkeysRes = res.getHeaderKeys();

        //create an object to store your header key-value pairs
        Map<string, string> headersRes = new map<string, string>();

        //iterate through they keys, and populate your map
        for(string s : headerkeysRes){
            headersRes.put(s,res.getHeader(s));
        }
            
        /*WsRestUtils.writeLog(
            apiRequest.Name,
            method,
            null,
            res.getStatusCode(),
            res.getStatus(),
            JSON.serialize(response).length() >= 131071 ? JSON.serialize(response).substring(0, 131071) : JSON.serialize(response),
            headersReq,
            headersRes,
            endpoint,
            ''
            // responseObj.isCorrect() ? null : responseObj.getErrors()
        );*/

        Map<String, Object> mapOutput = new Map<String, Object>{'esito' => result};

        return mapOutput;
    }

    public static String userId{get;set;}

    public static User currentUser {
        get{

            if(currentUser != null){
                return currentUser;
            }

            currentUser = [SELECT FederationIdentifier, FirstName, LastName, abi__c,applicazione__c, ndgsettoriale__c,
                        banca__c, terminale__c, idced__c, ip__c, cab__c, branchcode__c, userid__c,
                        sessionId__c, operationId__c, sysCaller__c, fnCaller__c, serviceName__c, fnName__c,
                        Token__c, idApplicazione__c, esb_idCed__c, esb_operatore__c, esb_IP__c,
                        serviceImplClass__c, serviceClient__c, TermId__c, customerId__c, ServiceVersion__c, Matricola6CifreFormula__c, Name
                        FROM User WHERE id =: userId];
            return currentUser;
        }set;
    }
}