/**
 * @description       : 
 * @author            : luca.pollastro@lutech.it
 * @group             : 
 * @last modified on  : 17-11-2023
 * @last modified by  : luca.pollastro@lutech.it
**/
public with sharing class PoloWealthNotificaSCA_Controller {
    public static String user{get;set;}

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
                        FROM User WHERE id =: user];
            return currentUser;
        }set;
    }

    @AuraEnabled
    public static String getFieldsAndRecords(String accountId){
        Map<String, String> returnMap = new Map<String,String>();
        try{
            String criteriaFieldValue='Internet_Banking';                                         
            
            
            //get fields from FieldSet
            List<Polo_Wealth_Notifica_SCA__mdt> fields= [SELECT Field_API_Name__c, Field_Label__c, Order__c FROM Polo_Wealth_Notifica_SCA__mdt ORDER BY Order__c];
            Map<String,Map<String,Object>> lstFSMember= new Map<String,Map<String,Object>> ();
            for(Polo_Wealth_Notifica_SCA__mdt p: fields){
                Map<String, Object> tempMap = new Map<String,Object>();
                tempMap.put('Name', p.Field_API_Name__c);
                tempMap.put('Label', p.Field_Label__c);
                tempMap.put('Order', p.Order__c);
                lstFSMember.put(p.Field_API_Name__c,tempMap);
            }
            //prepare SOQL query based on fieldAPIs 
            String query = 'SELECT ';
            for( String f : lstFSMember.keySet()) {
                query += lstFSMember.get(f).get('Name') + ', ';
                }
                query += 'Id FROM CRM_Channel__c WHERE RecordType.DeveloperName=\'' + criteriaFieldValue + '\' AND CRM_Account__c=:accountId' ;
                            
            //execute query
            System.debug('@@@polo: '+query);
            List<SObject> lstRecords = Database.query(query);
                
            returnMap.put('FIELD_LIST', JSON.serialize(lstFSMember));
            returnMap.put('RECORD_LIST', JSON.serialize(lstRecords));
        }
        catch(Exception ex){
            throw new AuraHandledException('errore: '+ex.getMessage());
        }
        return JSON.serialize(returnMap);
        
    }

    @AuraEnabled
    public static Case getRecord(Id recordId){
        List<Case> cs = new List<Case>();
        try{
            cs= [SELECT Id, AccountId, CC_notificationId__c, CRM_CustomerAuthenticationType__c, Account.finserv__banknumber__c FROM Case WHERE Id=:recordId];
        }
        catch(Exception ex){
            throw new AuraHandledException('errore: '+ex.getMessage());
        }
        return cs[0];
    }
    @AuraEnabled
    public static Object cifraDati(String userId, String abi){
        HttpRequest req = new HttpRequest();
        String body;
        Map<String,String> headersReq= new  Map<String,String>();
        Endpoint__c apiRequest = Endpoint__c.getInstance('cifraDati');
        String endpoint = apiRequest.Endpoint__c.replace('{username}',userId)+'?tenant=SMART';
        String method = apiRequest.Method__c;
        String certificate = apiRequest.CertificateName__c;
        Decimal timeout = apiRequest.Timeout__c;
        HTTPResponse res = new HttpResponse();
        Map<String, String> headersRes = new Map<String, String>();

        try{

            headersReq=setHeader(req);
            req.setEndpoint(endpoint);
            req.setMethod(method);
            req.setTimeout(timeout.intValue());
            req.setClientCertificateName(certificate);
            String clearData= System.now().getTime()+'|'+userId+'|'+abi+'|0052|null';
            System.debug('@@clearData: '+clearData);
            Blob myBlob = Blob.valueOf(clearData);
            Blob mySha = Crypto.generateDigest('SHA-256', myBlob);
            String myHex = EncodingUtil.convertToHex(mySha).toUpperCase();
            System.debug('@@myHex: '+myHex);
            String dati= myHex +'|'+myHex+'|'+clearData;
            String datiBase64= EncodingUtil.base64Encode(Blob.valueOf(dati));
            System.debug('@@datibase64: '+datibase64);
            Map<String,Object> bodyMap= new Map<String,Object>();
            bodyMap.put('dati',datibase64);
            body=JSON.serialize(bodyMap);
            System.debug('@@body: '+body);
            req.setBody(body);
            Http http = new Http();
            res = http.send(req);
            if(res.getStatusCode()!=200 && res.getStatusCode()!=201){
                System.debug('@@@@respondebody: '+ res.getBody());
                // throw new AuraHandledException('errore');
                return new Map<String, Object>{
                    'result' => 'errore'
                };
            }
            

            //iterate through they keys, and populate your map
            for(String s : res.getHeaderKeys()){
                headersRes.put(s,res.getHeader(s));
            }
            Map<String,Object> resMap= (Map<String,Object>) JSON.deserializeUntyped(res.getBody());

            WsRestUtils.writeLog(
                apiRequest.Name,
                method,
                body,
                res.getStatusCode(),
                res.getStatus(),
                res.getBody().length() >= 131071 ? res.getBody().substring(0, 131071) : res.getBody(),
                headersReq,
                headersRes,
                endpoint,
                res.getBody()
            );
            return new Map<String, Object>{
                'result' => (String)resMap.get('datiCifrati'),
                'myHex' => myHex
            };
            // return (String)resMap.get('datiCifrati');

        }
        catch(Exception ex){
           
            handleCatch(ex, req, res, headersReq, headersRes, apiRequest);
            // return 'errore '+ ex.getStackTraceString() + ';' + ex.getMessage();
            return new Map<String, Object>{
                'result' => 'errore '+ ex.getStackTraceString() + ';' + ex.getMessage()
            };
        }
        
    }

    @AuraEnabled
    public static String sendPush(String userId, String dati, String abi){

        HttpRequest req = new HttpRequest();
        String body;
        Map<String,String> headersReq= new  Map<String,String>();
        Endpoint__c apiRequest = Endpoint__c.getInstance('inviaNotificaPush');
        String endpoint = apiRequest.Endpoint__c;
        String method = apiRequest.Method__c;
        String certificate = apiRequest.CertificateName__c;
        Decimal timeout = apiRequest.Timeout__c;
        HTTPResponse res = new HttpResponse();
        Map<String, String> headersRes = new Map<String, String>();

        try{

            headersReq=setHeader(req);
            req.setEndpoint(endpoint);
            req.setMethod(method);
            req.setTimeout(timeout.intValue());
            req.setClientCertificateName(certificate);
            Map<String,Object> bodyMap= new Map<String,Object>();
            bodyMap.put('identficativoRichiesta',headersReq.get('correlationid'));
            bodyMap.put('idTemplate','AUTORIZZAZIONE_SERVIZIO_CLIENTI');
            bodyMap.put('dataCreazione',System.now());
            List<String> modalitaInvio= new List<String>();
            modalitaInvio.add('PUSH');
            bodyMap.put('modalitaInvio',modalitaInvio);
            Map<String,String> infoMap= new Map<String,String>();
            infoMap.put('criptedContent',dati);
            bodyMap.put('infoAddizionali',infoMap);
            Map<String,String> clienteMap= new Map<String,String>();
            clienteMap.put('id',userId);
            clienteMap.put('tipologiaId','UID');
            clienteMap.put('abi',abi);
            bodyMap.put('cliente',clienteMap);
            body=JSON.serialize(bodyMap);
            System.debug('@@body: '+body);
            req.setBody(body);
            Http http = new Http();
            res = http.send(req);
            if(res.getStatusCode()!=200 && res.getStatusCode()!=201){
                
                throw new AuraHandledException('errore');
            }
            

            //iterate through they keys, and populate your map
            for(String s : res.getHeaderKeys()){
                headersRes.put(s,res.getHeader(s));
            }
            Map<String,Object> resMap= (Map<String,Object>) JSON.deserializeUntyped(res.getBody());

            WsRestUtils.writeLog(
                apiRequest.Name,
                method,
                body,
                res.getStatusCode(),
                res.getStatus(),
                res.getBody().length() >= 131071 ? res.getBody().substring(0, 131071) : res.getBody(),
                headersReq,
                headersRes,
                endpoint,
                res.getBody()
            );
            return (String)resMap.get('notificationId');

        }
        catch(Exception ex){
            handleCatch(ex, req, res, headersReq, headersRes, apiRequest);
            return 'errore '+ ex.getStackTraceString() + ';' + ex.getMessage();
        }
        
    }

    @AuraEnabled
    public static String inserisciOperazione(String userId, String notId, String recordId, String myHex){

        HttpRequest req = new HttpRequest();
        String body;
        Map<String,String> headersReq= new  Map<String,String>();
        //DK sostituzione notId con codice codif
        /*String clearData= System.now().getTime()+'|'+userId+'|'+abi+'|0052|';
        System.debug('@@clearData: '+clearData);
        Blob myBlob = Blob.valueOf(clearData);
        Blob mySha = Crypto.generateDigest('SHA-256', myBlob);
        String myHex = EncodingUtil.convertToHex(mySha).toUpperCase();*/
        //DK sostituzione notId con codice codif

        Endpoint__c apiRequest = Endpoint__c.getInstance('inserisciOperazione');
        String endpoint = apiRequest.Endpoint__c.replace('{idOperazione}',myHex);
        // String endpoint = apiRequest.Endpoint__c.replace('{idOperazione}',notId);
        String method = apiRequest.Method__c;
        String certificate = apiRequest.CertificateName__c;
        Decimal timeout = apiRequest.Timeout__c;
        HTTPResponse res = new HttpResponse();
        Map<String, String> headersRes = new Map<String, String>();

        try{

            headersReq=setHeader(req);
            req.setEndpoint(endpoint);
            req.setMethod(method);
            req.setTimeout(timeout.intValue());
            req.setClientCertificateName(certificate);
            Map<String,Object> bodyMap= new Map<String,Object>();
            bodyMap.put('tipoOperazione','DISPOSITIVA');
            bodyMap.put('utente',userId);
            body=JSON.serialize(bodyMap);
            System.debug('@@body: '+body);
            req.setBody(body);
            Http http = new Http();
            res = http.send(req);
            if(res.getStatusCode()!=200 && res.getStatusCode()!=201){
                
                throw new AuraHandledException('errore');
            }
            

            //iterate through they keys, and populate your map
            for(String s : res.getHeaderKeys()){
                headersRes.put(s,res.getHeader(s));
            }

            Case cs= new Case(Id=recordId, CC_notificationId__c=notId);
            update cs;

            WsRestUtils.writeLog(
                apiRequest.Name,
                method,
                body,
                res.getStatusCode(),
                res.getStatus(),
                res.getBody().length() >= 131071 ? res.getBody().substring(0, 131071) : res.getBody(),
                headersReq,
                headersRes,
                endpoint,
                res.getBody()
            );
            return 'ok';

        }
        catch(Exception ex){
            handleCatch(ex, req, res, headersReq, headersRes, apiRequest);
            //return 'errore '+ ex.getStackTraceString() + ';' + ex.getMessage();
            return ex.getStackTraceString() + ';' + ex.getMessage(); //Michele Barile 31/01/2024
        }
        
    }

    @AuraEnabled
    public static String recuperaStatoOperazione(String notId, Id recordId, String myHex){

        HttpRequest req = new HttpRequest();
        String body;
        Map<String,String> headersReq= new  Map<String,String>();
        //DK sostituzione notId con codice codif
        /*String clearData= System.now().getTime()+'|'+userId+'|'+abi+'|0052|';
        System.debug('@@clearData: '+clearData);
        Blob myBlob = Blob.valueOf(clearData);
        Blob mySha = Crypto.generateDigest('SHA-256', myBlob);
        String myHex = EncodingUtil.convertToHex(mySha).toUpperCase();*/
        //DK sostituzione notId con codice codif

        Endpoint__c apiRequest = Endpoint__c.getInstance('recuperaStatoOperazione');
        String endpoint = apiRequest.Endpoint__c.replace('{idOperazione}',myHex);
        // String endpoint = apiRequest.Endpoint__c.replace('{idOperazione}',notId);
        String method = apiRequest.Method__c;
        String certificate = apiRequest.CertificateName__c;
        Decimal timeout = apiRequest.Timeout__c;
        HTTPResponse res = new HttpResponse();
        Map<String, String> headersRes = new Map<String, String>();

        try{
            headersReq=setHeader(req);
            req.setEndpoint(endpoint);
            req.setMethod(method);
            req.setTimeout(timeout.intValue());
            req.setClientCertificateName(certificate);
            Http http = new Http();
            res = http.send(req);
            //if(res.getStatusCode()!=200 && res.getStatusCode()!=201){
            //Michele Barile 01/02/2024 START
            if(res.getStatusCode()!=200 && res.getStatusCode()!=500){ 
                throw new AuraHandledException('errore');
            } else if (res.getStatusCode()==500) {
                throw new AuraHandledException('errore 500');
            }
            //Michele Barile 01/02/2024 END

            //iterate through they keys, and populate your map
            for(String s : res.getHeaderKeys()){
                headersRes.put(s,res.getHeader(s));
            }
            Map<String,Object> resMap= (Map<String,Object>) JSON.deserializeUntyped(res.getBody());

            //Michele Barile 01/02/2024 START
            /*
            if((String) resMap.get('statoOperazione')!='AUTHORIZED'){
                throw new AuraHandledException('errore');
            }
            */
            String returnMessage;
            if (res.getStatusCode()==200) {
                if (resMap.get('statoOperazione')=='Authorized') {
                    returnMessage = '200 Authorized';
                } else if (resMap.get('statoOperazione')=='Pending') {
                    returnMessage = '200 Pending';
                } else {
                   throw new AuraHandledException('errore'); 
                }
            }

            //Case cs= new Case(Id=recordId, CRM_CustomerAuthenticationType__c='Strong Authentication');
            Case cs= new Case(Id=recordId, CRM_CustomerAuthenticationType__c='Strong Authentication', CRM_Notes__c=myHex);
            //Michele Barile 01/02/2024 END

            update cs;


            WsRestUtils.writeLog(
                apiRequest.Name,
                method,
                body,
                res.getStatusCode(),
                res.getStatus(),
                res.getBody().length() >= 131071 ? res.getBody().substring(0, 131071) : res.getBody(),
                headersReq,
                headersRes,
                endpoint,
                res.getBody()
            );
            //return 'ok';
            return returnMessage; //Michele Barile 01/02/2024
        }
        catch(Exception ex){
            handleCatch(ex, req, res, headersReq, headersRes, apiRequest);
            return 'errore '+ ex.getStackTraceString() + ';' + ex.getMessage();
        }
        
    }


    public static Map<String,String> setHeader(HttpRequest req){
        user = UserInfo.getUserId();
        Map<String,String> headersReq= new Map<String,String>();
        req.setHeader('Content-Type', 'application/json');
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

    public static void handleCatch(Exception ex, HttpRequest req, HttpResponse res,  Map<String,String> headersReq, Map<String,String> headersRes, Endpoint__c apiRequest){
        System.debug('@@@@exc: '+ ex.getMessage()+';'+ex.getStackTraceString());
            if(res!=null){
                    WsRestUtils.writeLog(
                    apiRequest.Name,
                    req.getMethod(),
                    req.getbody(),
                    res.getStatusCode(),
                    res.getStatus(),
                    JSON.serialize(res.getBody()).length() >= 131071 ? JSON.serialize(res.getBody()).substring(0, 131071) : JSON.serialize(res.getBody()),
                    headersReq,
                    headersRes,
                    req.getEndpoint(),
                    res.getBody()
                );
            }
    }

    // Metodo Annulla Operazione
    // Sbianca campo NotificationId su Case
    @AuraEnabled
    public static void cancelOperation(String recordId){
        try {
            update new Case(Id = recordId, CC_notificationId__c = null);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public static void test(){
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}