public with sharing class SV_BulkAPI {

    @AuraEnabled
    public static User getUserInfo(){
        return [SELECT id, Profile.Name FROM User WHERE id =:UserInfo.getUserId()];
    }

    @AuraEnabled
    public static List<ResponseWrapper> createJobQuery(String operation, String query) {
        System.debug('SV operation '+ operation);
        System.debug('SV query '+ query);

        ResponseWrapper rw = new ResponseWrapper();
        if(query.length() == 0) {
            rw.responseBody =  'Please send correct data.';
        }

        HttpRequest request = new HttpRequest();

        request.setEndpoint('callout:CallMeBack/services/data/v56.0/jobs/query');
            request.setHeader('Content-Type', 'Application/JSON');
            request.setMethod('POST');
        // request.setHeader('Authorization' ,'Bearer '+userInfo.getSessionId() );  
        String body = '{ '+
            '"operation": "'+operation+'",'+ 
            '"query": "'+query+'"'+
        '}';



        request.setBody(body);

        Http h = new Http();
        HttpResponse resp = h.send(request);
        System.debug(LoggingLevel.DEBUG,'SV body: '+request.toString());
        System.debug(LoggingLevel.DEBUG,'SV body: '+request.getBody());
        System.debug(LoggingLevel.DEBUG,'SV response: '+resp.toString());
        System.debug(LoggingLevel.DEBUG,'SV response: '+resp.getBody());
        System.debug(LoggingLevel.DEBUG,'SV responseStatusCode: '+resp.getStatusCode());

        if(resp.getStatusCode() <= 299) {
            Map<String, Object> respMap = (Map<String, Object>) Json.deserializeUntyped(resp.getBody());
            String jobId = (String)respMap.get('id');

            rw.responseBody = 'Data processing Start '+jobId;

            CustomNotificationType notificationType = 
            [SELECT Id, DeveloperName 
             FROM CustomNotificationType 
             WHERE DeveloperName='SV_BulkV2'];
        
            // Create a new custom notification
            Messaging.CustomNotification notification = new Messaging.CustomNotification();

            // Set the contents for the notification
            notification.setTitle('SV_BulkV2');

                notification.setBody('SV_BulkV2: "' + jobId + ' risulta pronta.');

            // Set the notification type and target
            notification.setNotificationTypeId(notificationType.Id);
            notification.setTargetId(jobId);
            
            // Actually send the notification
            try {
                notification.send(new Set<String>{UserInfo.getUserId()});
            }
            catch (Exception e) {
                System.debug('Problem sending notification: ' + e.getMessage());
            }

        }else {
            System.debug('SV response: '+Json.deserializeUntyped(resp.getBody()));

            // rw.response = Json.deserializeUntyped(resp.getBody()).message;
        }

        
            
        
        return new List<ResponseWrapper>{rw};


    }

    @AuraEnabled
    public static List<ResponseWrapper> getJobQueryResult(String jobId, String locator, String maxRecords) {
        System.debug('SV jobId '+ jobId);
        System.debug('SV locator '+ locator);
        System.debug('SV maxRecords '+ maxRecords);
        ResponseWrapper rw = new ResponseWrapper();
        String locatorString = String.isBlank(locator) ? '': '&locator='+locator;

        HttpRequest request = new HttpRequest();

        request.setEndpoint('callout:CallMeBack/services/data/v56.0/jobs/query/'+jobId+'/results?maxRecords='+maxRecords+ locatorString);
        request.setHeader('Content-Type', 'Application/JSON');
        request.setHeader('Accept', 'text/csv');
        request.setMethod('GET');

        Http h = new Http();
        HttpResponse resp = h.send(request);
        System.debug(LoggingLevel.DEBUG,'SV body: '+request.toString());
        System.debug(LoggingLevel.DEBUG,'SV body: '+request.getBody());
        System.debug(LoggingLevel.DEBUG,'SV response: '+resp.toString());
        System.debug(LoggingLevel.DEBUG,'SV response: '+resp.getHeaderKeys());
        System.debug(LoggingLevel.DEBUG,'SV response: '+resp.getBody());
        System.debug(LoggingLevel.DEBUG,'SV responseStatusCode: '+resp.getStatusCode());

        if(resp.getStatusCode() <= 299) {

            rw.responseBody = resp.getBody();
            rw.responseHeaderSforceNumberOfRecords = resp.getHeader('Sforce-NumberOfRecords');
            rw.responseHeaderSforceLocator = resp.getHeader('Sforce-Locator');

        }else {
            System.debug('SV response: '+Json.deserializeUntyped(resp.getBody()));

            rw.responseBody = resp.getBody();
        }

        return new List<ResponseWrapper>{rw};


    }

    @AuraEnabled
    public static List<ResponseWrapper> createJobIngest(List<BulkDataWrapper> dataWrapperList) {

        ResponseWrapper rw = new ResponseWrapper();
        if(dataWrapperList.size() == 0) {
            rw.responseBody =  'Please send correct data.';
        }

        String objectName = dataWrapperList[0].objectName;
        String operation = dataWrapperList[0].operation;
        String contentDocumentId = dataWrapperList[0].fileIdList[0];
        ContentVersion cv = [SELECT Id, ContentDocumentId, VersionData FROM ContentVersion WHERE ContentDocumentId =: contentDocumentId ];

        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setEndpoint(URl.getOrgDomainUrl().toExternalForm()+'/services/data/v56.0/jobs/ingest');
        request.setHeader('content-type', 'application/json' );
        request.setHeader('Authorization' ,'Bearer '+userInfo.getSessionId() );  
        String body = '{ '+
                        '"externalIdFieldName": "Id",'+  
                        '"lineEnding": "CRLF",'+ 
                        '"operation": "'+operation+'",'+ 
                        '"object": "'+objectName+'",'+ 
                        '"contentType": "CSV"'+
                      '}';

        request.setBody(body);
        Http h = new Http();
        HttpResponse resp = h.send(request);
        
        if(resp.getStatusCode() <= 299) {
            Map<String, Object> respMap = (Map<String, Object>) Json.deserializeUntyped(resp.getBody());
            String jobId = (String)respMap.get('id');
            
            //second request to store data
            HttpRequest request1 = new HttpRequest();
            request1.setMethod('PUT');
            request1.setEndpoint(URl.getOrgDomainUrl().toExternalForm()+'/services/data/v50.0/jobs/ingest/'+jobId+'/batches');
            request1.setHeader('content-type', 'text/csv' );
            request1.setHeader('Authorization' ,'Bearer '+userInfo.getSessionId() );  
            
            request1.setBody(cv.VersionData.toString());
            Http h1 = new Http();
            HttpResponse resp1 = h1.send(request1);
            
            
            if(resp1.getStatusCode() <= 299) {
                //third request to start processing
                HttpRequest request2 = new HttpRequest();
                request2.setMethod('PATCH');
                request2.setEndpoint(URl.getOrgDomainUrl().toExternalForm()+'/services/data/v50.0/jobs/ingest/'+jobId);
                request2.setHeader('content-type', 'application/json' );
                request2.setHeader('Authorization' ,'Bearer '+userInfo.getSessionId() );  
                
                request2.setBody('{ "state" : "UploadComplete" }');
                Http h2 = new Http();
                HttpResponse resp2 = h2.send(request2);
               
                //Delete the uploaded file as we no longer need that
                Delete [SELECT ID FROM contentDocument WHERE ID =: contentDocumentId];
                if(resp2.getStatusCode() <= 299) {
                    rw.responseBody = 'Data processing Start '+jobId;
                } else {
                 rw.responseBody = 'There was an error. Please contact your admin.';
                }
            }
        }

        return new List<ResponseWrapper>{rw};
    }

    public class BulkDataWrapper {
        @AuraEnabled 
        public List<Id> fileIdList;
        @AuraEnabled
        public String objectName;
        @AuraEnabled
        public String operation;
        @AuraEnabled
        public String query;

    }

    public class ResponseWrapper {
        @AuraEnabled
        public String responseBody;
        @AuraEnabled
        public String responseHeaderSforceNumberOfRecords;
        @AuraEnabled
        public String responseHeaderSforceLocator;
    }
}