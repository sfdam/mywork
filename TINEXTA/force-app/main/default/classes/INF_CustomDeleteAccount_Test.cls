@isTest private class INF_CustomDeleteAccount_Test {
     @testSetup static void setup() {
        // Create common test accounts
        Account[] acc= TestDataFactory.createAccounts(1);
        insert acc;
    }

     @isTest static void testCoverage(){

       User usr = TestDataFactory.create_User(UserInfo.getProfileId());
       insert usr;

        List<Account> acct = [SELECT Id FROM Account LIMIT 1];
        System.debug('acct'+acct);
        List<Coverage_Team_Member__c> ctmList = TestDataFactory.createCoverageTeamMember(acct);
        insert ctmList;
        INF_CustomDeleteAccount.WrapperResponse wr = new INF_CustomDeleteAccount.WrapperResponse();
         wr = INF_CustomDeleteAccount.deleteRecord(acct[0].Id);
      }
}