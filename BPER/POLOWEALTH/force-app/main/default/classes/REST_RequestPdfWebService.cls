@RestResource(urlMapping='/v1/RequestPDF/*')
global class REST_RequestPdfWebService {

    public class SearchNDGException extends Exception{}

    @HttpGet
    global static Map<String, String> get() {

        String concatPDF='';

        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        
        Map<String,String> requestHeaders= request.headers;
        Map<String,String> responseHeaders = response.headers;
        String endpoint= request.requestURI;

        String externalId = request.params.get('abi') + '_' + request.params.get('ndg');
        LIst<Account> record = [SELECT Id, CRM_PEF_PDFBase64Split1__c, CRM_TimestampPEFPDF__c, CRM_PEF_PDFBase64Split2__c, CRM_PEF_PDFBase64Split3__c, CRM_PEF_PDFBase64Split4__c FROM Account WHERE NDW_ExternalId__c =: externalId LIMIT 1];
       
        if(!record.isEmpty()){
        
            //response.statusCode = 200;
            concatPDF = (record[0].CRM_PEF_PDFBase64Split1__c != null) ? record[0].CRM_PEF_PDFBase64Split1__c : '';
            concatPDF += (record[0].CRM_PEF_PDFBase64Split2__c != null) ? record[0].CRM_PEF_PDFBase64Split2__c : '';
            concatPDF += (record[0].CRM_PEF_PDFBase64Split3__c != null) ? record[0].CRM_PEF_PDFBase64Split3__c : '';
            // concatPDF += (record[0].CRM_PEF_PDFBase64Split4__c != null) ? record[0].CRM_PEF_PDFBase64Split4__c : '';

            Datetime timestamp = record[0].CRM_TimestampPEFPDF__c;
            System.debug('concatPDF: '+concatPDF );
            
            if(concatPDF != '') {
               System.debug('concatPDF!=null' );
               response.statusCode = 200; 
            } else {
                System.debug('concatPDF=null' );
                response.statusCode = 404;
            }

            WsRestUtils.writeLog(

            'REST_RequestPdfWebService', //request name
            'GET', // method
            'a', //request body
            200, //status code
            'OK', //status
            'a', //reaponse body
            RestContext.request.headers, //request header Map<String,String>
            RestContext.response.headers, //response header Map<String,String>
            RestContext.request.requestURI, //endpoint
            'NDG TROVATO' //error message
         );

        }else{
            response.statusCode = 400;
            response.responseBody = blob.valueOf('NDG Richiesto non trovato');
            WsRestUtils.writeLog('REST_RequestPdfWebService', 'GET', '',400, 'KO','', RestContext.request.headers, RestContext.response.headers, RestContext.request.requestURI, 'Non è stato trovato NDG richiesto.');
        }
        return new Map<String, String> {'pdf' => concatPDF};
    }

}