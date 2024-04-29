@IsTest
public  class UpdateAttemptTest {
   @TestSetup
   static void makeData(){
        Account acc=AllDataFactory.getAccount('01', 'PersonAccount');
        insert acc;
        Account ac=[SELECT PersonContactId FROM Account WHERE Id=: acc.Id];
        Campaign camp= new Campaign(
                Name='Test'
                );
        insert camp;
        CampaignMember member = new CampaignMember(
                ContactId = ac.PersonContactId,
                softphone_it__Gc_Contact_Id_externalId__c='Test',
                softphone_it__Gc_Contact_List_Id__c='Test',
                Status = 'Completed',
                CampaignId = camp.Id);
        insert member ;
   }

   @isTest
   private static void testUpdateAttempt(){
        List<CampaignMember> cmList = [SELECT Id FROM CampaignMember LIMIT 1];
        UpdateAttempt.UpdateAttemptRequest req = new UpdateAttempt.UpdateAttemptRequest();
        req.campaignMemberId='Test';
        //req.dialerContactListId='Test';
        //req.attempt=2;
        UpdateAttempt.updateAttempt(req);
        List<CampaignMember> cmListAfter = [SELECT Id, CRM_NumeroTentativi__c FROM CampaignMember WHERE Id=:cmList[0].Id];
        //System.assert(cmListAfter[0].CRM_NumeroTentativi__c==1);
   }

   @isTest 
   private static void testParamsException(){
    List<CampaignMember> cmList = [SELECT Id FROM CampaignMember LIMIT 1];
    UpdateAttempt.UpdateAttemptRequest req = new UpdateAttempt.UpdateAttemptRequest();
    UpdateAttempt.updateAttempt(req);
   }

   @isTest 
   private static void testNotFound(){
    List<CampaignMember> cmList = [SELECT Id FROM CampaignMember LIMIT 1];
    UpdateAttempt.UpdateAttemptRequest req = new UpdateAttempt.UpdateAttemptRequest();
    req.campaignMemberId='Test';
    //req.dialerContactListId='Test';
    //req.attempt=2;
    delete cmList[0];
    UpdateAttempt.updateAttempt(req);
    UpdateAttempt.testRun();
   }
}