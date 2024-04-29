public without sharing class AnnullaIterController {
    
    @AuraEnabled
    public static Boolean init(String recordId) {

        WorkOrder wo = [SELECT OriginalOwner__c, Status  FROM Workorder WHERE id =: recordId LIMIT 1][0];
        return UserInfo.getUserId() == wo.OriginalOwner__c && wo.Status == 'Pending';
    }

    @AuraEnabled
    public static void closeIter(String recordId, String nota) {

        Map<String, Object> requestBody = new Map<String, Object>{
            'recordId' => recordId
        };
        Http req = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse resp = new HttpResponse();
        Map<String, Object> response = new Map<String, Object>();
        String responseBody = '';
        request.setEndpoint('callout:CallMeBack/services/apexrest/iterhandler');
        request.setHeader('Content-Type', 'Application/JSON');
        request.setMethod('PATCH');
        request.setTimeout(120000);
        System.debug('DK requestBody: ' + JSON.serialize(requestBody));
        request.setBody(JSON.serialize(requestBody));
        responseBody = req.send(request).getBody();
        response = (Map<String, Object>)JSON.deserializeUntyped((String)JSON.deserializeUntyped(responseBody));
        System.debug('DK responseBody: ' + responseBody);
        if(response.containsKey('errorMessage')){
            throw new AuraHandledException((String)response.get('errorMessage'));
        }else{

            update new WorkOrder(Id = recordId, Status = 'Annullato', PTF_NotaAnnullamento__c = nota);
        }
    }

    public static Map<String,Object> closeIterFromResiduale( List<String> accountWithIter) {
        
        List<WrapperAnnullaIter> requestList = new List<WrapperAnnullaIter>();
        Map<String, Object> requestBody = new Map<String, Object>();

        for(String i:accountWithIter){
            WrapperAnnullaIter req1 = new WrapperAnnullaIter();
            req1.recordId=i;
            req1.Status='Annullato';
            
           // requestList.add(req1);
            requestBody.put( req1.recordId,req1.Status);
        }
      
        System.debug('DK requestList: ' + JSON.serialize(requestBody));

        Http req = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:CallMeBack/services/apexrest/iterhandler');
        request.setHeader('Content-Type', 'Application/JSON');
        request.setMethod('POST');
        request.setTimeout(120000);

        request.setBody(JSON.serialize(requestBody));
        HttpResponse resp = new HttpResponse();
        String responseBody = req.send(request).getBody();
        System.debug('DK responseBody: ' + responseBody);
        Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped((String)JSON.deserializeUntyped(responseBody));
        
        return response;
    }
    public class WrapperAnnullaIter {
        public  String recordId;
        public  String Status;
    }
}