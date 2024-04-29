@RestResource(urlMapping='/v1/GeneratePDF/*')
global class REST_GeneratePdfWebService {

    @HttpGet
    global static void getAccount() {

        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        
        Map<String,String> requestHeaders= request.headers;
        Map<String,String> responseHeaders = response.headers;
        String endpoint= request.requestURI;
        String abiNdgLegacy = request.params.get('abi') + '_' + request.params.get('ndg');

        List<Account> acc = [SELECT Id, RecordType.DeveloperName, CRM_PEF_PDFBase64Split1__c, CRM_PEF_PDFBase64Split2__c, CRM_PEF_PDFBase64Split3__c, CRM_PEF_PDFBase64Split4__c
                              FROM Account WHERE NDW_ExternalId__c =: abiNdgLegacy LIMIT 1];
        System.debug('acc lista ' + acc);
        if(acc.isEmpty()){
            response.statusCode = 400;
            response.responseBody = blob.valueOf('NDG Richiesto non trovato');
            WsRestUtils.writeLog('REST_GeneratePdfWebService', 'GET', '', 400, 'KO', '', RestContext.request.headers, RestContext.response.headers, RestContext.request.requestURI, 'Non è stato trovato NDG richiesto.');
        }else{

            String rootCampiAggiuntivi = PrintPDFController.getRootCampiAggiuntivi('Account', String.valueOf(acc[0].RecordType.DeveloperName));
            String query = String.escapeSingleQuotes(SV_Utilities.selectAllField('Account')+ ' WHERE NDW_ExternalId__c =: abiNdgLegacy LIMIT 1');
            if(String.isNotBlank(rootCampiAggiuntivi)){
                rootCampiAggiuntivi = (rootCampiAggiuntivi.startsWith(',')) ?
                rootCampiAggiuntivi : ', ' + rootCampiAggiuntivi;
                query = query.replaceFirst('FROM', String.escapeSingleQuotes(rootCampiAggiuntivi) + ' FROM');
            }
    
            Account currentAcc = (Account)Database.query(query);
            System.debug('currentAcc ' + currentAcc);
            System.debug('CURR 1 ' +  currentAcc.CRM_PEF_PDFBase64Split1__c);
            System.debug('CURR 2 ' + currentAcc.CRM_PEF_PDFBase64Split2__c);
            System.debug('CURR 3 ' + currentAcc.CRM_PEF_PDFBase64Split3__c);
            System.debug('CURR 4 ' + currentAcc.CRM_PEF_PDFBase64Split4__c);
    
    
            // if(currentAcc != null){
                response.statusCode = 200;
    
                if(currentAcc.CRM_PEF_PDFBase64Split1__c != null) currentAcc.CRM_PEF_PDFBase64Split1__c = '';
                if(currentAcc.CRM_PEF_PDFBase64Split2__c != null) currentAcc.CRM_PEF_PDFBase64Split2__c = '';
                if(currentAcc.CRM_PEF_PDFBase64Split3__c != null) currentAcc.CRM_PEF_PDFBase64Split3__c = '';
                if(currentAcc.CRM_PEF_PDFBase64Split4__c != null) currentAcc.CRM_PEF_PDFBase64Split4__c = '';
                
                if(acc[0].CRM_PEF_PDFBase64Split1__c != null) acc[0].CRM_PEF_PDFBase64Split1__c = '';
                if(acc[0].CRM_PEF_PDFBase64Split2__c != null) acc[0].CRM_PEF_PDFBase64Split2__c = '';
                if(acc[0].CRM_PEF_PDFBase64Split3__c != null) acc[0].CRM_PEF_PDFBase64Split3__c = '';
                if(acc[0].CRM_PEF_PDFBase64Split4__c != null) acc[0].CRM_PEF_PDFBase64Split4__c = '';
                
                update acc;
                
                PrintPDFController.savePDF(currentAcc);
    
                WsRestUtils.writeLog(
                'REST_RequestPdfWebService', //request name
                'GET', // method
                '', //request body
                200, //status code
                'OK', //status
                '', //reaponse body
                RestContext.request.headers, //request header Map<String,String>
                RestContext.response.headers, //response header Map<String,String>
                RestContext.request.requestURI, //endpoint
                '' //error message
             ); 
            /*}else {
       
                response.statusCode = 400;
                WsRestUtils.writeLog('REST_GeneratePdfWebService', 'GET', '', 400, 'KO', '', RestContext.request.headers, RestContext.response.headers, RestContext.request.requestURI, 'Non è stato trovato NDG richiesto.');
            }*/
        }
    }
}