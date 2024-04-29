public without sharing class TXT_OpportunityApprovalCompController {

    @AuraEnabled
    public static User getUserInfo(){
        return [ SELECT Id, Name, Societa__c, Profile.Name FROM User WHERE Id =: UserInfo.getUserId() ];
        
    }

    @AuraEnabled 
    public static boolean changeActor(String actorId, String recordId){
        System.debug('SV actorId: ' + actorId);
        System.debug('SV recordId: ' + recordId);

        try{
            ProcessInstance pIst = [SELECT Id, ProcessDefinitionId, TargetObjectId, Status, CompletedDate, LastActorId, ElapsedTimeInDays, ElapsedTimeInHours, ElapsedTimeInMinutes, SubmittedById, IsDeleted, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp 
                                    FROM ProcessInstance
                                    WHERE TargetObjectId =: recordId AND 
                                          Status = 'Pending' LIMIT 1];
            system.debug('pIst: '+pIst);

            ProcessInstanceWorkItem pWI = [SELECT Id, ProcessInstanceId, OriginalActorId, ActorId, ElapsedTimeInDays, ElapsedTimeInHours, ElapsedTimeInMinutes, IsDeleted, CreatedDate, CreatedById, SystemModstamp
                                          FROM ProcessInstanceWorkItem 
                                          WHERE ProcessInstanceId =: pIst.Id LIMIT 1];
            system.debug ('pWI: '+pWI);

            PayLoad x = new PayLoad();
            x.ActorId = actorId;
                
            String jsonString = JSON.serialize(x);
            System.debug('SV jsonString: ' + jsonString); 
            //Named Credential 1
            HTTP h = new HTTP();
            HTTPRequest req = new HTTPRequest();
            HttpResponse resp = new HttpResponse();
            
            req.setEndpoint('callout:SalesforceAdminNamedCredential/services/data/v46.0/sobjects/ProcessInstanceWorkItem/'+ pWI.Id + '?_HttpMethod=PATCH');
            req.setHeader('X-HTTP-Method-Override','PATCH');
            req.setHeader( 'Content-Type', 'application/json' );    

            req.setMethod('POST');
            req.setBody(jsonString);
            resp = h.send(req);
            
            System.debug('A: ' + req.toString()); 
            System.debug('A: ' + resp.toString()); 
            System.debug('A STATUS: ' + resp.getStatus()); 
            System.debug('A STATUS_CODE: ' + resp.getStatusCode()); 
            System.debug ('A HTTPResponse Body: ' + resp.getBody()); 

            while (resp.getStatusCode() == 302) { 
                req.setEndpoint(resp.getHeader('Location')); 
                resp = new Http().send(req); 

                System.debug('B: ' + req.toString()); 
                System.debug('B: ' + resp.toString()); 
                System.debug('B STATUS: ' + resp.getStatus()); 
                System.debug('B STATUS_CODE: ' + resp.getStatusCode()); 
                System.debug ('B HTTPResponse Body: ' + resp.getBody()); 
            }

            // if(resp.getStatusCode() == 204){
            //     // 00X2X000001YVQF

            //     //New instance of a single email message
            //     Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

            //     // Who you are sending the email to
            //     mail.setTargetObjectId(actorId);

            //     // The email template ID used for the email
            //     mail.setTemplateId('00X2X000001YVQF');
            //     // mail.setWhatId(actorId);   
            //     mail.setBccSender(false);
            //     mail.setUseSignature(false);
            //     // mail.setReplyTo('recruiting@acme.com');
            //     // mail.setSenderDisplayName('HR Recruiting');
            //     mail.setSaveAsActivity(false); 
            //     Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

            // }

        	
        }catch(Exception e){
             return false;
        }
         return true;
    }

     class PayLoad {
        public String ActorId;
    }
    
}