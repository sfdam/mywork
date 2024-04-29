public with sharing class CMK_SharepointIntegrationCtrl implements Queueable, Database.AllowsCallouts {

    public List<Id> optyIds;
    public List<Log__c> logs = new List<Log__c>();
    public static String sourceAuth = 'CMK_AuthSharepoint';
    public static String sourceCreateFolder = 'CMK_CreateFolderSharepoint';

    public CMK_SharepointIntegrationCtrl(List<Id> optyIds) {
        this.optyIds = optyIds;
    }

    public void execute(QueueableContext ctx) {

        Id optyId = this.optyIds.remove(0);
        Map<String,Object> auth = AuthSharepoint();

        if(auth != null && auth.containsKey('access_token')){
            createSharepointFolder(optyId, String.valueOf(auth.get('access_token')));
        }

        insert this.logs;

        if(!this.optyIds.isEmpty() && !Test.isRunningTest()) {
            System.enqueueJob(new CMK_SharepointIntegrationCtrl(this.optyIds));
        }
    }

    public void createSharepointFolder(Id optyId, String access_token) {
        Map<String,Object> result = new Map<String,Object>();
        Boolean success = true;
        String requestBody;
        String responseBody;
        String errorMessage;

        try {

            EndpointServizi__c es = EndpointServizi__c.getInstance();
            String folderIdAccount;
            Opportunity opty = [SELECT Id, Name, CloseDate, OpportunityNumber__c, CMK_Url_Sharepoint__c, AccountId, Account.Name, Account.Codice_Unico_Tinexta__c FROM Opportunity WHERE Id =: optyId];

            Boolean existAccountsFolder = false;
            List<Opportunity> existingAccountLink = new List<Opportunity>([SELECT Id, CMK_folderId_Account_Sharepoint__c FROM Opportunity WHERE RecordType.DeveloperName = 'Co_Mark' AND AccountId =: opty.AccountId AND CMK_folderId_Account_Sharepoint__c != null LIMIT 1]);
            //TODO: Aggiungi campo per folderId;
            Map<String,Object> resultSharepointFolderAccount;

            if(existingAccountLink.isEmpty()) {
                resultSharepointFolderAccount = createSharepointFolder_Account(opty, access_token);

                if(resultSharepointFolderAccount == null || 
                    (resultSharepointFolderAccount != null && !resultSharepointFolderAccount.containsKey('id'))) {
                    return;
                }

                if(resultSharepointFolderAccount != null) {
                    folderIdAccount = String.valueOf(resultSharepointFolderAccount.get('id'));
                }
            } else {
                folderIdAccount = existingAccountLink[0].CMK_folderId_Account_Sharepoint__c;
            }

            HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            req.setEndpoint(es.CMK_Url_Sharepoint_CreateFolder__c.replace(':folderId',folderIdAccount));
            req.setHeader('Content-Type', 'application/json;odata.metadata=minimal;odata.streaming=true;IEEE754Compatible=false');
            req.setHeader('Accept','application/json;odata.metadata=minimal;odata.streaming=true;IEEE754Compatible=false');
            req.setHeader('Authorization', 'Bearer ' + access_token);

            Map<String,Object> bodyMap = new Map<String,Object>();
            bodyMap.put('name', String.valueOf(opty.CloseDate).replaceAll('-','') + ' ' + opty.OpportunityNumber__c + ' ' + opty.Name.replaceAll('\\.|\\-|\\~|\\#|\\%|\\&|\\*|\\{|\\}|\\|\\:|\\<|\\>|\\?|\\/|\\||\"', ''));
            bodyMap.put('folder', new Map<String,Object>());
            requestBody = JSON.serialize(bodyMap);

            req.setBody(requestBody);

            HttpResponse response = new Http().send(req);
            responseBody = response.getBody();


            if(response.getStatusCode() == 201) {
                result = (Map<String,Object>)JSON.deserializeUntyped(responseBody);
                opty.CMK_Url_Sharepoint__c = (String) result.get('webUrl');
                opty.CMK_folderId_Account_Sharepoint__c = folderIdAccount;
                update opty;
            } else {
                success = false;
            }

        } catch (Exception e) {
            System.debug('@@@ eccezione auth ' + e.getStackTraceString());
            success = false;
            errorMessage = e.getStackTraceString();
        }

        this.logs.add(generateLog(requestBody, responseBody, errorMessage, false, sourceCreateFolder));
        // return result;
    }

    private Map<String,Object> createSharepointFolder_Account(Opportunity opty, String access_token) {
        Map<String,Object> result = new Map<String,Object>();
        Boolean success = true;
        String requestBody;
        String responseBody;
        String errorMessage;

        try {

            EndpointServizi__c es = EndpointServizi__c.getInstance();

            HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            req.setEndpoint(es.CMK_Url_Sharepoint_CreateFolder__c.replace(':folderId','root'));
            req.setHeader('Content-Type', 'application/json;odata.metadata=minimal;odata.streaming=true;IEEE754Compatible=false');
            req.setHeader('Accept','application/json;odata.metadata=minimal;odata.streaming=true;IEEE754Compatible=false');
            req.setHeader('Authorization', 'Bearer ' + access_token);

            Map<String,Object> bodyMap = new Map<String,Object>();
            String accountName = opty.Account.Name.replaceAll('\\.|\\-|\\~|\\#|\\%|\\&|\\*|\\{|\\}|\\|\\:|\\<|\\>|\\?|\\/|\\||\"', '');
            String accountCode = opty.Account.Codice_Unico_Tinexta__c.replaceAll('\\.|\\-|\\~|\\#|\\%|\\&|\\*|\\{|\\}|\\|\\:|\\<|\\>|\\?|\\/|\\||\"', '');
            bodyMap.put('name', accountCode + ' ' + accountName);
            bodyMap.put('folder', new Map<String,Object>());
            requestBody = JSON.serialize(bodyMap);

            req.setBody(requestBody);

            HttpResponse response = new Http().send(req);
            responseBody = response.getBody();


            if(response.getStatusCode() == 201) {
                result = (Map<String,Object>)JSON.deserializeUntyped(responseBody);
                // opty.CMK_Url_Sharepoint__c = (String) result.get('webUrl');
                // update opty;
            } else {
                success = false;
            }
        } catch(Exception e) {
            System.debug('@@@ eccezione sharepoint folder account ' + e.getStackTraceString());
            success = false;
            errorMessage = e.getStackTraceString();
        }

        this.logs.add(generateLog(requestBody, responseBody, errorMessage, false, sourceCreateFolder));
        return result;
    }

    private Map<String,Object> AuthSharepoint() {
        Map<String,Object> result = new Map<String,Object>();
        Boolean success = true;
        String requestBody;
        String responseBody;
        String errorMessage;

        try {

            EndpointServizi__c es = EndpointServizi__c.getInstance();

            HttpRequest authReq = new HttpRequest();
            authReq.setMethod('POST');
            authReq.setEndpoint(es.CMK_Url_Sharepoint_Token__c); //TODO: Sostituisci con custom settings
            authReq.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            String client_id = es.CMK_client_id_Sharepoint__c;
            String scope = 'https://graph.microsoft.com/.default'; //FISSO
            String client_secret = es.CMK_client_secret_Sharepoint__c;
            String grant_type = 'client_credentials'; //FISSO

            requestBody = 'client_id='+client_id +'&scope='+scope+'&client_secret='+client_secret+'&grant_type='+grant_type;
            authReq.setBody(requestBody);

            HttpResponse response = new Http().send(authReq);
            responseBody = response.getBody();

            if(response.getStatusCode() == 200) {
                result = (Map<String,Object>)JSON.deserializeUntyped(responseBody);
            } else {
                success = false;
            }

        } catch (Exception e) {
            System.debug('@@@ eccezione auth ' + e.getStackTraceString());
            success = false;
            errorMessage = e.getStackTraceString();
        }

        this.logs.add(generateLog(requestBody, responseBody, errorMessage, false, sourceAuth));
        return result;
    }

    private static Log__c generateLog(String input, String output, String errorMessage, Boolean success, String source) {
        Log__c l = new Log__c(
            Source__c = source,
            InputPayload__c = input,
            OutputPayload__c = output,
            ErrorMessage__c = errorMessage,
            Success__c = success
        );
        return l;
    }
}