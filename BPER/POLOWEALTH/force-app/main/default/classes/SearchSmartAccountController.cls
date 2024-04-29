public class SearchSmartAccountController {

    private final Static String regex = '[0-9A-Za-z\\-\\+ =_&%\"]{0,255}';
    private final Static Pattern regexPattern = Pattern.compile(regex);
    public final Static String userSessionId {
        get{
            if(Test.isRunningTest())
                userSessionId='00D9E0000004kI1ARsAQPAf5JyVAfQLGPHPqfrGQbP6aQ4DGqKeWEIavWOB3fFZgsDgKsKdNQKlgRrOKK5eFsWc4CnKvuBmo_3zyYSrEp2WkdG';

            if(userSessionId != null)return userSessionId;

            List<String> matchList = new List<String>();
            Matcher regexMatcher = regexPattern.matcher(UserInfo.getSessionId());
            while (regexMatcher.find()) {
				matchList.add(regexMatcher.group());
            }
            userSessionId = String.join(matchList, '');
            System.debug('MC sessionID'+ userSessionId);
            return userSessionId;
        }set;
    }

    public static Map<String, String> statusMapping = new Map<String, String> {
        'ATTIVO' => 'Attivo',
        'ESTINTO' => 'Estinto',
        'ERRORE' => 'Errore'
    };

    public static Map<String, String> userIdStatusMapping = new Map<String, String> {
        'ATTIVO' => 'Attivo',
        'USERATTIVO' => 'Attivo',
        'LOGON' => 'In primo logon',
        'SOSPESO' => 'Sospeso',
        'USERNONATTIVO' => 'Sospeso',
        'BLOCCATA' => 'Bloccato',
        'ESTINTO' => 'Eliminato',
        'FRODE' => 'Bloccata per frode',
        'PWDATTIVO' => 'Attiva',
        'VALIDATO' => 'Attiva',
        'PWDRESET' => 'Attiva',
        'PWDNONATTIVO' => 'Bloccata',
        'DAVALIDARE' => 'Bloccata',
        'SALTAVALIDAZIONE' => '-',
        'ERRORE' => '-'
    };

    public static Map<String, String> userScaStateMapping = new Map<String, String> {
        'ATTIVA' => 'Attiva',
        'NONATTIVA' => 'Non attiva',
        'BLOCCATA' => 'Bloccata',
        'CANCELLATA' => 'Cancellata'
    };

    public static Map<String, String> passwordStatusMapping = new Map<String, String> {
        'PWDATTIVO' => 'Attiva',
        'VALIDATO' => 'Attiva',
        'PWDRESET' => 'Attiva',
        'PWDNONATTIVO' => 'Bloccata',
        'DAVALIDARE' => 'Bloccata'
    };

    public static String userId{get;set;}

    public static User currentUser {
        get{

            if(currentUser != null){
                return currentUser;
            }

            currentUser = [SELECT FederationIdentifier, FirstName, LastName, abi__c, applicazione__c, ndgsettoriale__c,
                        banca__c, terminale__c, idced__c, ip__c, cab__c, branchcode__c, userid__c,
                        sessionId__c, operationId__c, sysCaller__c, fnCaller__c, serviceName__c, fnName__c,
                        Token__c, idApplicazione__c, esb_idCed__c, esb_operatore__c, esb_IP__c,
                        serviceImplClass__c, serviceClient__c, TermId__c, customerId__c, ServiceVersion__c, Matricola6CifreFormula__c
                        FROM User WHERE id =: userId];
            return currentUser;
        }set;
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

    @AuraEnabled
    public static String makeRequest(String apiRequestName, Id recordId, Map<String, Map<String, Object>> fieldsMap, Map<String, Map<String, String>> conditions, String certificateName, String runAsUserId, Boolean disableLog){

        System.debug('SV apiRequestName: ' + apiRequestName);
        System.debug('SV recordId: ' + recordId);
        System.debug('SV fieldsMap: ' + fieldsMap);
        System.debug('SV conditions: ' + conditions);
        System.debug('SV certificateName: ' + certificateName);
        System.debug('SV runAsUserId: ' + runAsUserId);

        Map<String,String> headersReq= new Map<String,String>();
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$'; // source: http://www.regular-expressions.info/email.html
        System.debug('conditions: ' + JSON.serialize(conditions));

        userId = !String.isBlank(runAsUserId) ? runAsUserId : UserInfo.getUserId();

        WsRestInput restInput = new WsRestInput(currentUser, null);
        Map<String, String> userProfileMap = (Map<String, String>)JSON.deserialize(JSON.serialize(restInput.headers.userProfile), Map<String, String>.class);
        Map<String, String> bindingInfoMap = (Map<String, String>)JSON.deserialize(JSON.serialize(restInput.headers.bindingInfo), Map<String, String>.class);

        userProfileMap.put('esb_idCed', currentUser.idced__c);
        userProfileMap.put('esb_operatore', currentUser.FederationIdentifier);
        userProfileMap.put('esb_IP', currentUser.ip__c);
        

        //Recupre dati da custom setting Endpoint List
        Endpoint__c apiRequest = Endpoint__c.getInstance(apiRequestName);
        String endpoint = apiRequest.Endpoint__c;
        String method = apiRequest.Method__c;
        Decimal timeout = apiRequest.Timeout__c;

        Account record = [SELECT id , CRM_NDG__c , IsActive__c , CRM_SmartWebMobilePhone__c, CRM_SmartWebEmail__c, FinServ__BankNumber__c, (SELECT Id, NDW_ExternalId__c, CRM_RelationshipStatus__c,Financial_Account__r.FinServ__ProductName__r.ProductCode,CRM_UserCodeStatus__c,CRM_PasswordStatus__c,CRM_StartDate__c,CRM_UserCode__c,CRM_UserId__c,CRM_Alias__c,CRM_SCAStatus__c FROM Channel__r) FROM Account WHERE id =: recordId LIMIT 1];

        //effettua la request
        HttpRequest req = new HttpRequest();

        for(String key: userProfileMap.keySet()){

            if(userProfileMap.get(key) != null){
                req.setHeader(!WsRestUtils.outOfObjectParams.contains(key) ? 'userProfile' + '_' + key : key, userProfileMap.get(key));
                headersReq.put(!WsRestUtils.outOfObjectParams.contains(key) ? 'userProfile' + '_' + key : key, userProfileMap.get(key));
            }else{
               
                req.setHeader(!WsRestUtils.outOfObjectParams.contains(key) ? 'userProfile' + '_' + key : key, '');
                headersReq.put(!WsRestUtils.outOfObjectParams.contains(key) ? 'userProfile' + '_' + key : key, '');
            }
        }
        for(String key: bindingInfoMap.keySet()){
    
            if(bindingInfoMap.get(key) != null){
                headersReq.put(!WsRestUtils.outOfObjectParams.contains(key) ? 'bindingInfo' + '_' + key : key, bindingInfoMap.get(key));
                req.setHeader(!WsRestUtils.outOfObjectParams.contains(key) ? 'bindingInfo' + '_' + key : key, bindingInfoMap.get(key));
            }else{
               
                headersReq.put(!WsRestUtils.outOfObjectParams.contains(key) ? 'bindingInfo' + '_' + key : key, '');
                req.setHeader(!WsRestUtils.outOfObjectParams.contains(key) ? 'bindingInfo' + '_' + key : key, '');
            }
        }
        req.setHeader('ltpaToken2', 'EXTENDED');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        headersReq.put('ltpaToken2', 'EXTENDED');
        headersReq.put('Content-Type', 'application/json');
        headersReq.put('Accept', 'application/json');
        req.setEndpoint(endpoint);
        req.setMethod(method);
        req.setTimeout(timeout.intValue());
        if(certificateName != null) req.setClientCertificateName(certificateName);
        String body = JSON.serialize(new Request((Account)record));
        req.setBody(body);

        Http http = new Http();               
        HTTPResponse res = http.send(req);
        String responseBody = res.getBody();
        Integer statusCode = res.getStatusCode();
        //Helpful debug messages 
        System.debug(res.toString()); 
        System.debug('SV STATUS: ' + res.getStatus()); 
        System.debug('SV STATUS_CODE: ' + res.getStatusCode()); 
        System.debug('SV RESPONSE_BODY: ' + JSON.serialize(res.getBody()));

        SearchSmartAccountResponse response = SearchSmartAccountResponse.parse(res.getBody());
        System.debug('Dk response ' + JSON.serialize(response));
        try{

            List<CRM_Channel__c> recordsToUpsert = new List<CRM_Channel__c>();
            String rt = SV_Utilities.getRecordTypeByDeveloperName('CRM_Channel__c', 'Internet_Banking');
            Map<String, SObject> channelMap = SV_Utilities.keyBy(record.Channel__r, 'NDW_ExternalId__c');
            if(response.searchSmartAccountExtendedResp != null){

                for(SearchSmartAccountResponse.CustomerDataNPV customerDataNPV : response.searchSmartAccountExtendedResp.listCustomerDataNPV.customerDataNPV){
                    
                    String status = (statusMapping.containsKey(customerDataNPV.clientData.status) ? statusMapping.get(customerDataNPV.clientData.status) : '');
                    String userIdStatus = (userIdStatusMapping.containsKey(customerDataNPV.clientData.userIdStatus) ? userIdStatusMapping.get(customerDataNPV.clientData.userIdStatus) : '');
                    String passwordStatus = (passwordStatusMapping.containsKey(customerDataNPV.clientData.passwordStatus) ? passwordStatusMapping.get(customerDataNPV.clientData.passwordStatus) : '');
                    String userScaState = (userScaStateMapping.containsKey(customerDataNPV.clientData.userProfileHb.userScaState) ? userScaStateMapping.get(customerDataNPV.clientData.userProfileHb.userScaState) : '');
                    String codice = customerDataNPV.clientData.ndg.bankCode + '_' + customerDataNPV.clientData.accountMC.accountCode + '_' + customerDataNPV.clientData.username + '_' + customerDataNPV.clientData.ndg.ndgCode;
                    CRM_Channel__c channelToUpsert = new CRM_Channel__c(
                    Name = 'Internet Banking', 
                    CRM_RelationshipStatus__c = status, 
                    CRM_UserCodeStatus__c = userIdStatus,
                    CRM_PasswordStatus__c = passwordStatus,
                    CRM_StartDate__c = customerDataNPV.clientData.userProfileHB.customerStart != null ? (Date)JSON.deserialize(JSON.serialize(customerDataNPV.clientData.userProfileHB.customerStart.split(' ')[0]), Date.class) : null,
                    CRM_UserCode__c = customerDataNPV.clientData.accountMC.accountCode,
                    CRM_UserId__c = customerDataNPV.clientData.username,
                    CRM_Alias__c = (String)customerDataNPV.clientData.alias,
                    CRM_SCAStatus__c = userScaState,
                    CRM_ProfileTypology__c = customerDataNPV.clientData.userProfileHb.userProduct.description,
                    CRM_SmartWebPhone__c = customerDataNPV.clientData.userProfileHB.referenceTelephoneNumber1,
                    CRM_SmartWebEmail__c = customerDataNPV.clientData.userProfileHB.referenceEmail);
                    if(channelMap.containsKey(codice)){
                        channelToUpsert.Id = (String)channelMap.get(codice).get('Id');
                    }else{
                        channelToUpsert.CRM_Account__c = record.Id;
                        channelToUpsert.NDW_ExternalId__c = codice;
                        channelToUpsert.NDW_X_Update_TS__c = Date.today();
                        channelToUpsert.RecordTypeId = rt;
                    }
                    recordsToUpsert.add(channelToUpsert);
                }
        
            }
            if(!recordsToUpsert.isEmpty()){
                
                if(record.CRM_SmartWebMobilePhone__c != recordsToUpsert[0].CRM_SmartWebPhone__c ||
                record.CRM_SmartWebEmail__c != recordsToUpsert[0].CRM_SmartWebEmail__c){
                    
                    record.CRM_SmartWebMobilePhone__c = recordsToUpsert[0].CRM_SmartWebPhone__c;
                    record.CRM_SmartWebEmail__c = recordsToUpsert[0].CRM_SmartWebEmail__c;
                    update record;
                }
                upsert recordsToUpsert;
            }
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
                WsRestUtils.writeLog(
                    apiRequest.Name,
                    method,
                    body,
                    res.getStatusCode(),
                    res.getStatus(),
                    JSON.serialize(response).length() >= 131071 ? JSON.serialize(response).substring(0, 131071) : JSON.serialize(response),
                    headersReq,
                    headersRes,
                    endpoint,
                    ''
                    // responseObj.isCorrect() ? null : responseObj.getErrors()
                );
            }
        }catch(Exception ex){
            return JSON.serialize(new Map<String, Object>{
                'error' => ex.getMessage() + ' at: ' + ex.getStackTraceString(),
                'record' => record,
                'response' => JSON.serialize(response),
                'statusCode' => statusCode,
                'isEmpty' => record.Channel__r.isEmpty()
            });
        }

        return JSON.serialize(new Map<String, Object>{
            'error' => '',
            'record' => record,
            'response' => JSON.serialize(response),
            'statusCode' => statusCode,
            'isEmpty' => record.Channel__r.isEmpty()
        });
    }

    // --------------------------------------------------------- WRAPPERS -----------------------------------------------------------

    public class Request{

        public SearchSmartAccountExtendedReq searchSmartAccountExtendedReq;

        public request(Account ndg){
            this.SearchSmartAccountExtendedReq = new SearchSmartAccountExtendedReq(currentUser, ndg);
        }
    }
    public class Ndg {
        public String ndgCode;

        public Ndg(Account ndg){
            this.ndgCode = ndg.CRM_NDG__c;
        }
    }

    public class BusinessTierBindingInfo {
        public String sessionId;
        public String operationId;
        public String sysCaller;
        public Object fnCaller;
        public String serviceName;
        public Object fnName;
        public Object serviceImplementationClass;
        public Object serviceClient;

        public BusinessTierBindingInfo(User user) {
            this.sessionId = user.Matricola6CifreFormula__c + DateTime.now().format('MM') + '' + DateTime.now().format('dd') + userSessionId.substring(17, 31);
            this.operationId = generateRandomString(20);
            this.sysCaller = 'CRM';
            this.fnCaller = user.fnCaller__c;
            this.serviceName = 'it.bper.crm.CallBack';
            this.fnName = user.fnName__c;
            this.serviceImplementationClass = user.serviceImplClass__c;
            this.serviceClient = user.serviceClient__c;
        }
    }

    public class ClientSecurityPayload {
        public ApplicationCredentials applicationCredentials;
        public UserCredentials userCredentials;

        public ClientSecurityPayload(user user){
            this.ApplicationCredentials = new ApplicationCredentials(user);
            this.UserCredentials = new UserCredentials(user);
        }
    }

    public class UserProfile {
        public String abi;
        public String termId;
        public String uid;
        public String banca;
        public String filiale;
        public String idApplicazione;
        public String esbIdCed;
        public String esbOperatore;
        public String esbIP;

        public UserProfile(User user, Account ndg) {
            this.abi = ndg.FinServ__BankNumber__c;
            this.banca = user.banca__c;
            this.filiale = user.branchCode__c;
            this.termId = user.TermId__c;
            this.uid = user.userId__c;
            this.idApplicazione = 'CRM';
            this.esbIdCed = user.idced__c;
            this.esbOperatore = user.FederationIdentifier;
            this.esbIP = user.ip__c;
        }
    }

    public class ClientData {
        public Ndg ndg;

        public ClientData(Account ndg){
            this.Ndg = new Ndg(ndg);
        }
    }

    public class ApplicationCredentials {
        public String applicationName;

        public ApplicationCredentials(User user){
            this.applicationName = user.applicazione__c;
        }
    }

    // public SearchSmartAccountExtendedReq searchSmartAccountExtendedReq;

    public class UserCredentials {
        public String username;

        public UserCredentials(User user){
            this.username = user.userId__c;
        }
    }

    public class SearchFilter {
        public ClientData clientData;
        public String scope;
        public String type;

        public SearchFilter(Account ndg){
            this.clientData = new ClientData(ndg);
            this.scope = 'POSTVENDITA';
            this.type = 'NDG';
        }
    }

    public class SearchSmartAccountExtendedReq {
        public ClientSecurityPayload clientSecurityPayload;
        public UserProfile userProfile;
        public BusinessTierBindingInfo businessTierBindingInfo;
        public SearchFilter searchFilter;
        public String isAttivo;

        public SearchSmartAccountExtendedReq(User user, Account ndg){

            this.userProfile = new UserProfile(user, ndg);
            this.businessTierBindingInfo = new businessTierBindingInfo(user);
            this.clientSecurityPayload = new clientSecurityPayload(user);
            this.searchFilter = new searchFilter(ndg);
            this.isAttivo = 'false';
        }
    }
}