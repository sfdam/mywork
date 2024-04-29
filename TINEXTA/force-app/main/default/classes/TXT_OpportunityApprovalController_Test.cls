@isTest
private class TXT_OpportunityApprovalController_Test {
    
    @testSetup static void setup() {
        Funzionalita__c x= new Funzionalita__c();
        x.Disabilita_tutti_i_trigger__c=true;
        insert x;
        User runuser = TestDataFactory.create_User(UserInfo.getProfileId());
        System.runAs(runuser){
            Account[] acc = TestDataFactory.createAccounts(1);
            insert acc;
            Opportunity[] opp = TestDataFactory.createOpportunity(acc);
            opp[0].Account_Owner__c = runuser.Id;
            insert opp;
            Id usrId = UserInfo.getUserId();      
            Approval.ProcessSubmitRequest req1 = 
            new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(opp[0].id);
    
            // Submit on behalf of a specific submitter
            req1.setSubmitterId(usrId); 
    
            // Submit the record to specific process and skip the criteria evaluation
            req1.setProcessDefinitionNameOrId('ApprovaOpportunit_v4');
            req1.setSkipEntryCriteria(true);

        // Submit the approval request for the account
            Approval.ProcessResult result = Approval.process(req1);
        }
        x.Disabilita_tutti_i_trigger__c=false;
        update x;
    }
    
    @isTest static void testGetUserInfo(){
        User u = TXT_OpportunityApprovalCompController.getUserInfo();    
    }
    
    @isTest static void TestchangeActor(){
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Map<String,String> header = new Map<String,String>();
         header.put('Content-type', 'application/json');
        header.put('X-HTTP-Method-Override','PATCH');
         HttpMockFactory mock = new HttpMockFactory(302, 'OK', '{"success":true,"message":"success","status":"200"', header);
         Test.setMock(HttpCalloutMock.class, mock);
        Boolean res = TXT_OpportunityApprovalCompController.changeActor(UserInfo.getUserId(), opp.Id);
    }
}