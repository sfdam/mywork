public with sharing class AggiornaNDGSpecchioInvocaWS {

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
                        serviceImplClass__c, serviceClient__c, TermId__c, customerId__c, ServiceVersion__c, Matricola6CifreFormula__c, Name, Profile.Name
                        FROM User WHERE id =: userId];
            return currentUser;
        }set;
    }
    
    public static String makeResponse(String apiRequestName, String accountIdBCP,String accountIdBPER, String certificationName, Boolean disableLog, String ruAsUserId, String ndgBcp, String ndgBper, String cedFil){
        System.debug(LoggingLevel.DEBUG,'*** START -- makeRequest Method ***');
        System.debug(LoggingLevel.DEBUG,'### apiRequestName: '+apiRequestName);
        System.debug(LoggingLevel.DEBUG,'### certificationName: '+certificationName);
        System.debug(LoggingLevel.DEBUG,'### disableLog: '+disableLog);
        System.debug(LoggingLevel.DEBUG,'### ruAsUserId: '+ruAsUserId);
        System.debug(LoggingLevel.DEBUG,'### disableLog: '+disableLog);
        System.debug(LoggingLevel.DEBUG,'### ruAsUserId: '+ndgBcp);
        System.debug(LoggingLevel.DEBUG,'### disableLog: '+ndgBper);
        System.debug(LoggingLevel.DEBUG,'### ruAsUserId: '+cedFil);

        Boolean esito = false;
        Map<String,String> headersReq= new Map<String,String>();

        userId = !String.isBlank(ruAsUserId) ? ruAsUserId : UserInfo.getUserId();

        WsRestInput restInput =  new WsRestInput(currentUser, null);
        Map<String, String> testataMap = (Map<String, String>)JSON.deserialize(JSON.serialize(restInput.headers.testata), Map<String, String>.class);
		
        //Recuperare dati da custom setting Endpoint List
        Endpoint__c apiRequest = Endpoint__c.getInstance(apiRequestName);
        String endpoint; 
        if(!Test.isRunningTest())
        	endpoint= apiRequestName+'/banche/03084/filiali/'+cedFil.leftPad(4, '0')+'/clienti/'+ndgBcp+'/gestioneSpecchio';
        else
            endpoint='TestNDGSpecchio';
        
        String method = apiRequest.Method__c;
        Decimal timeout = apiRequest.Timeout__c;

        HttpRequest req = new HttpRequest();        
        headersReq = setHeader(req);
        
		System.debug(LoggingLevel.DEBUG,'### testata: '+testataMap);
        headersReq.put('Content-Type', 'application/json');
        req.setEndpoint(endpoint);
        req.setMethod(method);
        req.setTimeout(timeout.intValue());
        System.debug('headersReq: '+headersReq);
        
        if(certificationName != null) req.setClientCertificateName(certificationName);
        String body = getRequestBody();
        req.setBody(body);

        Http http = new Http();               
        HTTPResponse res = http.send(req);
        String response = res.toString(); 
		String ndgListResponse;
        System.debug(LoggingLevel.DEBUG,'### response: '+res);
        System.debug(LoggingLevel.DEBUG,'### response: '+res.getBody());
        System.debug(LoggingLevel.DEBUG,'### responseStatusCode: '+res.getStatusCode());
        String jsonStr;
        if(res.getStatusCode() == 200){
            
            if(res.getBody()!=null){
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                jsonStr = JSON.serialize(results.get('listaNdg'));
                jsonStr = jsonStr.replace('["', '');
                jsonStr = jsonStr.replace('"]', '');
                System.debug('msg: '+jsonStr);
                ndgListResponse = jsonStr;
                esito = true;
            }
                
            
        }

        string[] headerkeysRes = res.getHeaderKeys();

        //create an object to store your header key-value pairs
        Map<string, string> headersRes = new map<string, string>();

        //iterate through they keys, and populate your map
        for(string s : headerkeysRes){
            headersRes.put(s,res.getHeader(s));
        }

        if(disableLog == null){
            
            disableLog = false;
        }
        if(!disableLog){
            WsRestUtils.writeLog(
                apiRequest.Name,
                method,
                res.getBody(),
                res.getStatusCode(),
                'res.getBody()',
                JSON.serialize(response).length() >= 131071 ? JSON.serialize(response).substring(0, 131071) : JSON.serialize(response),
                headersReq,
                headersRes,
                endpoint,
                'res.getBody()'
                // responseObj.isCorrect() ? null : responseObj.getErrors()
            );
        }
        System.debug(LoggingLevel.DEBUG,'*** END -- makeRequest Method ***');
        return jsonStr;
    }

    /**
    * @description metodo di costruione del body request
    * @author simone.viglianti@tengroup.it | 10-27-2021 
    * @param stato 
    * @param note 
    * @param recordList 
    * @return String 
    **/
    private static String getRequestBody(){
        
        String tipoCliente = 'NON COI';
        ListaNdg ndgList = new ListaNdg();
        ndgList.ndgList = new List<String>();        
        Request reqBody = new Request();
        reqBody.tipoCliente ='NON COI';
        String body = JSON.serialize(reqBody);
        System.debug(LoggingLevel.DEBUG,'### body: '+body);
        return body;
       
    }

    public class Request {
        String tipoCliente;
        List<String> listaNdg;
    }
    

    public class ListaNdg {
        List<String> ndgList;
    }
 
    public static Map<String,String> setHeader(HttpRequest req){
        String user = UserInfo.getUserId();
        Map<String,String> headersReq= new Map<String,String>();
        req.setHeader('Content-Type', 'application/json');
        /*
        if(String.isNotBlank(currentUser.cab__c)){
            req.setHeader('cab', currentUser.cab__c);
            headersReq.put('cab', currentUser.cab__c);
        }
        
        req.setHeader('abi', '05387');
		req.setHeader('channel', 'IBPR');
        String correlationId=MakeRequestV2Controller.generateCorrelationId();
        req.setHeader('correlationid', '5ac95544845cc0e45480016c6b298d07');
        req.setHeader('applicazione', 'salesforce');
        req.setHeader('terminale', 'XXX');
        req.setHeader('utente', '82744');
        req.setHeader('idced', '27847');
        req.setHeader('ip', '10.58.85.62');
        req.setHeader('Content-Type', 'application/json');
        headersReq.put('Content-Type', 'application/json');
        headersReq.put('Content-Type', 'application/json');
        headersReq.put('abi', '05387');
        headersReq.put('channel', 'IBPR');
        headersReq.put('correlationid', '5ac95544845cc0e45480016c6b298d07');
        headersReq.put('applicazione', 'salesforce');
        headersReq.put('terminale', 'XXX' );
        headersReq.put('utente', '82744');
        headersReq.put('idced', '27847');
        headersReq.put('ip', '10.58.85.62');*/
        
        req.setHeader('abi', currentUser.abi__c);
        if(String.isNotBlank(currentUser.cab__c)){
            req.setHeader('cab', currentUser.cab__c);
            headersReq.put('cab', currentUser.cab__c);
        }
        req.setHeader('channel', 'IBPR');
        String correlationId=MakeRequestV2Controller.generateCorrelationId();
        req.setHeader('correlationid', correlationId);
        req.setHeader('applicazione', currentUser.applicazione__c);
        req.setHeader('terminale', currentUser.terminale__c);
        req.setHeader('utente', currentUser.FederationIdentifier);
        req.setHeader('idced', currentUser.idced__c);
        req.setHeader('ip', currentUser.ip__c);
        req.setHeader('Content-Type', 'application/json');
        headersReq.put('Content-Type', 'application/json');
        headersReq.put('Content-Type', 'application/json');
        headersReq.put('abi', currentUser.abi__c);
        headersReq.put('channel', 'IBPR');
        headersReq.put('correlationid', correlationId);
        headersReq.put('applicazione', currentUser.applicazione__c);
        headersReq.put('terminale', currentUser.terminale__c);
        headersReq.put('utente', currentUser.FederationIdentifier);
        headersReq.put('idced', currentUser.idced__c);
        headersReq.put('ip', currentUser.ip__c);

        return headersReq;
    }

}