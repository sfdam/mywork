@isTest private class OnAccountTeamMamberTriggerHandler_Test {
    @testSetup static void setup() {
        // Create common test accounts
        Account[] acc= TestDataFactory.createAccounts(1);
        insert acc;
    }

     @isTest static void testATM(){
        List<Account> acct = [SELECT Id FROM Account LIMIT 1];
        System.debug('acct'+acct);
        List<Coverage_Team_Member__c> ctmList = TestDataFactory.createCoverageTeamMember(acct);
        insert ctmList;
        List<Coverage_Team_Member__c> ctm= [SELECT Id, Account__c, User__c ,Account_Team_Member_Id__c FROM Coverage_Team_Member__c LIMIT 1];
        List<AccountTeamMember> atm = [SELECT Id, AccountId, UserId FROM AccountTeamMember WHERE Id =: ctm[0].Account_Team_Member_Id__c LIMIT 1];
         System.debug('atm: '+ atm);
		Test.startTest();
           delete atm;
        Test.stopTest(); 
     }
    
    

}