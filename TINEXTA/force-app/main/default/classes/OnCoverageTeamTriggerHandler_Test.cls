@isTest private class OnCoverageTeamTriggerHandler_Test {

     @testSetup static void setup() {
       Test.startTest();
        User usr = TestDataFactory.create_User(UserInfo.getProfileId());
        usr.Tinexta__c = false;
        insert usr;
      Test.stopTest();

      
    }

     @isTest static void testCoverage(){

            // Create common test accounts
            Account[] acc= TestDataFactory.createAccounts(1);
            insert acc;
      User usr = [SELECT Id FROM User ORDER BY CreatedDate DESC LIMIT 1];
        List<Account> acct = [SELECT Id FROM Account LIMIT 1];
        System.debug('acct'+acct);
        //List<Coverage_Team_Member__c> ctmList = TestDataFactory.createCoverageTeamMember(acct);
        List<Coverage_Team_Member__c> ctmList = new List<Coverage_Team_Member__c>();
        Coverage_Team_Member__c newctm = new Coverage_Team_Member__c(Account__c = acct[0].Id,
        User__c= usr.Id );
        ctmList.add(newctm);
        insert ctmList;
        
         List<Coverage_Team_Member__c> ctm= [SELECT Id, Account__c, User__c FROM Coverage_Team_Member__c LIMIT 1];
         
        
         
         
       //List<Coverage_Team_Member__c> ctm= [SELECT Id, Account__c, User__c FROM Coverage_Team_Member__c WHERE Account__c =:acct.Id LIMIT 1];
		System.debug('RC ctm : get'+ctm);
    ctm[0].User__c = usr.Id;
        update ctm;
        Test.startTest();
            Database.DeleteResult results = Database.delete(ctm[0], true);
        Test.stopTest(); 
     }

}