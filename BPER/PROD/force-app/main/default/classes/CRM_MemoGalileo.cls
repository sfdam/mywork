public with sharing class CRM_MemoGalileo {

    public virtual class BaseException extends Exception {}
    
    public static String userId{get;set;}
    public static Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    public static String certificationName = isSandbox ? 'salesforcetestclient2024' : 'salesforceprodclient2024';

    public static User currentUser {
        get{

            if(currentUser != null){
                return currentUser;
            }

            currentUser = [SELECT FederationIdentifier, Name, FirstName, LastName, abi__c,applicazione__c, ndgsettoriale__c,
                banca__c, terminale__c, idced__c, ip__c, cab__c, branchcode__c, userid__c,
                sessionId__c, operationId__c, sysCaller__c, fnCaller__c, serviceName__c, fnName__c,
                Token__c, idApplicazione__c, esb_idCed__c, esb_operatore__c, esb_IP__c,
                serviceImplClass__c, serviceClient__c, TermId__c, customerId__c, ServiceVersion__c, Matricola6CifreFormula__c
                FROM User WHERE id =: userId];
            return currentUser;
        }set;
    }
    
    public class FlowInputs {
      
        @InvocableVariable public SObject memoInput;
        @InvocableVariable public String methodInput;
        @InvocableVariable public String abi;
        @InvocableVariable public String ndg;
        @InvocableVariable public String matricolaAutore;
        @InvocableVariable public String titolo;
        @InvocableVariable public Date fineValidita;
        @InvocableVariable public Boolean popUpCassa;
        @InvocableVariable public Date dataDa;
        @InvocableVariable public Date dataA;
        @InvocableVariable public String descrizione;

    }

    public class FlowOutputs{
        
        @InvocableVariable public String codice;
        @InvocableVariable public String idMemoGalileo;
        
    }

    @InvocableMethod
    public static FlowOutputs[] makeRequest(List<FlowInputs> inputs){
        System.debug('memoInput'+ inputs[0].memoInput);
        System.debug('memoInpumethodt'+ inputs[0].methodInput);
        List<String> idListMemo = new List<String>();
        for(FlowInputs input : inputs){
            idListMemo.add((String)input.memoInput.Id);
        }
        List<CRM_Memo__c> memoList = [SELECT Id, CRM_IdMemoGalileo__c, Name, Cliente__c, Cliente__r.FinServ__BankNumber__c, Cliente__r.CRM_NDG__c, CRM_FineValidita__c, CRM_Titolo__c,
                            CRM_PopupCassa__c, Da__c, A__c, CRM_Note__c, CreatedBy.FederationIdentifier, Autore__c, CRM_Tipologia_Memo__c, CRM_Tipologia__c
                            FROM CRM_Memo__c
                            WHERE Id IN: idListMemo ];
        System.debug('memoList '+ memoList.size() );
        List<FlowOutputs> outputs = new List<FlowOutputs>();
        FlowOutputs output = new FlowOutputs();

        if(inputs[0].methodInput == 'Insert') {      
            outputs = handleAfterInsert ((CRM_Memo__c)inputs[0].memoInput,inputs); 
        } else if(inputs[0].methodInput == 'Update') {
            outputs = handleAfterUpdate (memoList, inputs); 
        } else if(inputs[0].methodInput == 'Delete') {
            outputs = handleAfterDelete (memoList, inputs); 
        } 
        
        return outputs;
        
    }
    
    public static FlowOutputs[] handleAfterInsert(CRM_Memo__c memoList, List<FlowInputs> inputs){
                Map<String, Object> response = new Map<String, Object>();
                response = chiamataGalileo(JSON.serialize(memoList), null, 'afterInsert', inputs);
                List<FlowOutputs> outputs = new List<FlowOutputs>();
                FlowOutputs output = new FlowOutputs();
                output.codice = (String)response.get('codice');
                output.idMemoGalileo = (String)response.get('idMemoGalileo');
                outputs.add(output);
                return outputs;
    }
    
    public static  FlowOutputs[] handleAfterUpdate (List<CRM_Memo__c> memoList, List<FlowInputs> inputs){
            Map<String, Object> response = new Map<String, Object>();
                response = chiamataGalileo(JSON.serialize(memoList[0]), null, 'afterUpdate', inputs);
                List<FlowOutputs> outputs = new List<FlowOutputs>();
                FlowOutputs output = new FlowOutputs();
                output.codice = (String)response.get('codice');
                output.idMemoGalileo = (String)response.get('idMemoGalileo');
                outputs.add(output);
                return outputs;
    }
    
    public static FlowOutputs[] handleAfterDelete (List<CRM_Memo__c> memoList, List<FlowInputs> inputs){
            Map<String, Object> response = new Map<String, Object>();
                response = chiamataGalileo(JSON.serialize(memoList[0]), null, 'afterDelete', inputs);
                List<FlowOutputs> outputs = new List<FlowOutputs>();
                FlowOutputs output = new FlowOutputs();
                output.codice = (String)response.get('codice');
                output.idMemoGalileo = (String)response.get('idMemoGalileo');
                outputs.add(output);
                return outputs;
    }
    
    public static Map<String, Object> chiamataGalileo (String memoJSON, Map<String, String> paramsMap, String tipoTrigger, List<FlowInputs> inputs){
        
        System.debug('DK memoJSON: ' + memoJSON);
        System.debug('DK paramsMap: ' + JSOn.serialize(paramsMap));
        System.debug('DK tipoTrigger: ' + tipoTrigger);
        String responseCode = '';  
        Map<String, Object> responseMap = new Map<String, Object>();
        try {
                         
            userId = UserInfo.getUserId();
            CRM_Memo__c memo = (CRM_Memo__c)JSON.deserialize(memoJSON, CRM_Memo__c.class);
            WsRestInput restInput = new WsRestInput(currentUser, null);
            Map<String, String> testataMap = (Map<String, String>)JSON.deserialize(JSON.serialize(restInput.headers.testata), Map<String, String>.class);
            testataMap.put('channel', 'IBPR');
            testataMap.put('cab', '12905');
            testataMap.put('correlationid', '5ef755b5-fc9e-467a-9022-23b9e2f9616');
            testataMap.put('applicazione', 'NPV');
            Map<String,String> headersReq= new Map<String,String>();
            HttpRequest request = new HttpRequest();
            String endpoint;
            String method;
            Endpoint__c apiRequest = new Endpoint__c();
            String body;
            if(tipoTrigger == 'afterInsert'){
                apiRequest = Endpoint__c.getInstance('memoInsert');
                endpoint = apiRequest.Endpoint__c;
                method = apiRequest.Method__c;
                body = JSON.serialize(getMemoMap(memo, null, inputs), true);
                system.debug('il body della chiamate è' + memo);

            }else if(tipoTrigger == 'afterUpdate'){
                apiRequest = Endpoint__c.getInstance('memoUpdate');
                body = JSON.serialize(getMemoMap(memo, null, inputs), true);
                endpoint = apiRequest.Endpoint__c.replace('{idMemo}', memo.CRM_IdMemoGalileo__c);
                system.debug('endpoint memoUpdate' + endpoint);
                method = apiRequest.Method__c;
            }else if(tipoTrigger == 'afterDelete'){
                apiRequest = Endpoint__c.getInstance('memoDelete');
                endpoint = apiRequest.Endpoint__c.replace('{idMemo}', memo.CRM_IdMemoGalileo__c) + '?';
                
                Map<String, String> paramsMapDelete = new Map<String, String>{
                    'abi' => memo.Cliente__r.FinServ__BankNumber__c,
                    'ndg' => memo.Cliente__r.CRM_NDG__c,
                    'matricolaAutore' => memo.CreatedBy.FederationIdentifier
                };
                
                Map<String, String> queryParamsMap = getMemoMap(memo, paramsMapDelete, inputs);
                System.debug('DK queryParamsMap:' + JSON.serialize(queryParamsMap));
                for(String key : queryParamsMap.keySet()){
                    if(queryParamsMap.get(key) != null){
                        endpoint += key + '=' + (queryParamsMap.get(key)).replaceAll(' ', '%20') + '&';
                    }
                }
                endpoint = endpoint.removeEnd('&');
                system.debug('endpoint memoDelete' + endpoint);
                method = apiRequest.Method__c;
            }

            for(String key: testataMap.keySet()){
                if(testataMap.get(key) != null){
                    request.setHeader(key, testataMap.get(key));
                    headersReq.put(key, testataMap.get(key));
                }
            }
            
            if(tipoTrigger == 'afterUpdate' || tipoTrigger == 'afterInsert'){    
                request.setHeader('Content-Type', 'application/json');
                headersReq.put('Content-Type', 'application/json');
            } else if(tipoTrigger == 'afterDelete') {
                request.setHeader('Content-Length', '0');
                headersReq.put('Content-Length', '0');
            }
            request.setEndpoint(endpoint);
            request.setMethod(method);
            request.setClientCertificateName(certificationName);
            
            if(body != null){

                request.setBody(body);
            }
            
            Http http = new Http();
            HttpResponse response = http.send(request);
            Map<string, string> headersRes = new map<string, string>();
            String responseJson = response.getBody(); 

            if (!String.valueOf(response.getStatusCode()).startsWithIgnoreCase('2')) {
                system.debug('errore nella chiamata al webservice REST');
                /*if(tipoTrigger == 'afterInsert' ||
                tipoTrigger == 'afterDelete'){

                    insert new SV_FailedRequest__c(RequestName__c = apiRequest.Name,
                    RecordId__c = '',
                    FieldsMap__c = tipoTrigger == 'afterInsert' ? JSON.serialize(new Map<String, Object>{'CRM_IdMemoGalileo__c' => 'idMemo'}) : '',
                    RequestEndpoint__c = endpoint,
                    RequestBody__c = body,
                    RequestHeader__c = JSON.serialize(headersReq),
                    CertificationName__c = certificationName);

                }*/
                responseMap.put('codice', '400' );
            }
            else {
                if(tipoTrigger == 'afterInsert'){

                    system.debug('After Insert eseguito con successo');
                    Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                    //memo.CRM_IdMemoGalileo__c = (String)responseBody.get('idMemo');
                    //update memo;
                }
                

                string[] headerkeysRes = response.getHeaderKeys();

                for(string s : headerkeysRes){
                    headersRes.put(s,response.getHeader(s));
                }
                Map<String, Object> mapResp = (Map<String, Object>) JSON.deserializeUntyped(responseJson);
                responseMap.put('codice', '200' );
                responseMap.put('idMemoGalileo', (String) mapResp.get('idMemo') );
            }

            WsRestUtils.writeLog(
                apiRequest.Name,
                method,
                body,
                response.getStatusCode(),
                response.getStatus(),
                response.getBody().length() >= 131071 ? response.getBody().substring(0, 131071) : response.getBody(),
                headersReq,
                headersRes,
                endpoint,
                ''
                // responseObj.isCorrect() ? null : responseObj.getErrors()
            ); 
            
        } catch (Exception ex) {
            System.debug('DK Exception: ' + ex  + '; Stacktrace: ' + ex.getStackTraceString());
            responseMap.put('codice', '400' );
        }
        System.debug('responseCode '+responseCode );
        return responseMap; 
    }
    
    public static Map<String, String> getMemoMap(CRM_Memo__c memo, Map<String, String> paramsMap, List<FlowInputs> inputs){
        Map<String, String> requestBodyMap = new Map<String, String>();
        requestBodyMap.put('idEntita', generateRandomString(18));
        requestBodyMap.put('codiceEntita',String.valueof('MEMO'));
        requestBodyMap.put('entita', 'Memo');
        requestBodyMap.put('operationType', 'C');
        if(paramsMap != null){
            requestBodyMap.put('abiMemo', paramsMap.get('abi'));
            requestBodyMap.put('ndg', paramsMap.get('ndg'));
            requestBodyMap.put('matricolaAutore', 'U' + paramsMap.get('matricolaAutore'));
        }else{
            requestBodyMap.put('abi', inputs[0].abi);
            requestBodyMap.put('ndg', inputs[0].ndg);
            requestBodyMap.put('matricolaAutore', 'U' + inputs[0].matricolaAutore);
        }
        if(inputs[0].fineValidita == null) {
            requestBodyMap.put('fineValidita', String.valueof(Memo.CRM_FineValidita__c));
        } else {
            requestBodyMap.put('fineValidita', String.valueof(inputs[0].fineValidita));
        }
        requestBodyMap.put('motivo', 'Memo');
        if(inputs[0].titolo == null) {
            requestBodyMap.put('descrizione', memo.Name);
        } else {
            requestBodyMap.put('descrizione', inputs[0].titolo);
        }
        if(inputs[0].popUpCassa == null) {
            requestBodyMap.put('flagPopUp', memo.CRM_PopupCassa__c ? 'S' : 'N');
        } else {
            requestBodyMap.put('flagPopUp', inputs[0].popUpCassa ? 'S' : 'N');
        }
        
        if(inputs[0].popUpCassa!= null && inputs[0].popUpCassa) {
            requestBodyMap.put('dataInizioPopUp', inputs[0].dataDa != null ? String.valueof(inputs[0].dataDa) : '');
            requestBodyMap.put('dataFinePopUp', inputs[0].dataA != null ? String.valueof(inputs[0].dataA) : '');      
        } else if(memo.CRM_PopupCassa__c) {
            requestBodyMap.put('dataInizioPopUp', memo.Da__c != null ? String.valueof(Memo.Da__c) : '');
            requestBodyMap.put('dataFinePopUp', memo.A__c != null ? String.valueof(Memo.A__c) : '');
        }
        
        /*if(memo.CRM_PopupCassa__c||(inputs[0].popUpCassa!= null && inputs[0].popUpCassa)){
            if(inputs[0].dataDa == null) {
                requestBodyMap.put('dataInizioPopUp', memo.Da__c != null ? String.valueof(Memo.Da__c) : '');
            } else {
                requestBodyMap.put('dataInizioPopUp', inputs[0].dataDa != null ? String.valueof(inputs[0].dataDa) : '');
            }
            if(inputs[0].dataA == null) {
                requestBodyMap.put('dataFinePopUp', memo.A__c != null ? String.valueof(Memo.A__c) : '');
            } else {
                requestBodyMap.put('dataFinePopUp', inputs[0].dataA != null ? String.valueof(inputs[0].dataA) : '');
            }
        }*/
        
        if(inputs[0].descrizione == null) {
            requestBodyMap.put('nota', memo.CRM_Note__c);
        } else {
            requestBodyMap.put('nota', inputs[0].descrizione);
        }
        
        requestBodyMap.put('autore', currentUser.Name);
        requestBodyMap.put('tipologia', memo.CRM_Tipologia__c.toUpperCase());

        return requestBodyMap;
    }
    
    public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
           Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
           randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }
    
}