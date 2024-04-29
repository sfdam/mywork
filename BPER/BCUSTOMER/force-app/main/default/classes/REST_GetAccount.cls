/**
 * @author            : alessandro.dinardo@lutech.it
 * @group             : tengroup
 * @last modified on  : 14-03-2024
 * description        :  ricerca account in base al campo 'NDW_ExternalId__c' passato da input
 *                       se è presente almeno un account rispondere con 'NDG trovato'
 *                       altrimenti rispondere con 'NDG non trovato'
**/
@RestResource(urlMapping='/v1/getAccount/*')
global class REST_GetAccount {
    
    @HttpGet
    global static void getAccount(){
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        
        Map<String,String> requestHeaders= request.headers;
        Map<String,String> responseHeaders = response.headers;
        String endpoint= request.requestURI;
        String responseBody;
        String responseStatus = '';
        if(String.isBlank(request.params.get('abi')) || String.isBlank(request.params.get('ndg'))){
            response.statusCode = 400;
            responseStatus = 'KO';
            responseBody = JSON.serialize(new Map<String, String>{
                'message' => 'Mancano campi obbligatori',
                'status' => 'KO'
            });
            response.responseBody = blob.valueOf(responseBody);
        }else{

            String abiNdgLegacy = request.params.get('abi') + '_' + request.params.get('ndg');
            String contactIdToPass = '';
    
            List<Account> acc = [SELECT Id, PersonContactId, PTF_Filiale__c, PTF_StatoCRM__c, Recordtype.DeveloperName  FROM Account WHERE NDW_ExternalId__c =: abiNdgLegacy LIMIT 1];
            
            if (acc[0].Recordtype.DeveloperName == 'PersonAccount') {
                contactIdToPass = acc[0].PersonContactId;
            } else {
                List<Contact> ctc = [SELECT Id  FROM Contact WHERE RecordType.DeveloperName = 'IndustriesBusiness' AND AccountId =: acc[0].Id LIMIT 1];
                if (!ctc.isEmpty()) {
                    contactIdToPass = ctc[0].Id;
                }
            }
        
            if(acc.isEmpty()){
                responseBody = JSON.serialize(new Map<String, String>{
                    'message' => 'NDG non trovato',
                    'status' => 'KO'
                });
                responseStatus = 'KO';
                response.statusCode = 200;
                response.responseBody = blob.valueOf(responseBody);
                // WsRestUtils.writeLog('REST_GetAccount', 'GET', '', 204, 'KO', 'NDG non trovato', RestContext.request.headers, RestContext.response.headers, RestContext.request.requestURI, 'NDG non trovato');
            }else{
                responseBody = JSON.serialize(new Map<String, String>{
                    'message' => 'NDG trovato',
                    'contactId' =>  contactIdToPass,
                    'branch' => acc[0].PTF_Filiale__c,
                    'statoNDG' => acc[0].PTF_StatoCRM__c,
                    'status' => 'OK'
                });
                responseStatus = 'OK';
                response.statusCode = 200;
                response.responseBody = blob.valueOf(responseBody);
                //WsRestUtils.writeLog('REST_GetAccount', 'GET', '', 200, 'OK', '', RestContext.request.headers, RestContext.response.headers, RestContext.request.requestURI, 'NDG trovato.');
            }
        }
        WsRestUtils.writeLog(
            'REST_GetAccount', //request name
            'GET', // method
            null, //request body
            response.statusCode, //status code
            responseStatus, //status
            responseBody, //reaponse body
            RestContext.request.headers, //request header Map<String,String>
            RestContext.response.headers, //response header Map<String,String>
            RestContext.request.requestURI, //endpoint
            '' //error message
         ); 
    }
}