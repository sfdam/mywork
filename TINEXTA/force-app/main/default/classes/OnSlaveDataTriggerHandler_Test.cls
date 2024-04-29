@isTest private class OnSlaveDataTriggerHandler_Test {

    @testSetup static void setup() {
        // Create common test accounts
        Account[] acc= TestDataFactory.createAccounts(4);
        insert acc;
    }

     @isTest static void testSlaves(){
        Account acct = [SELECT Id FROM Account LIMIT 1];

        Slave_Data__c slave = TestDataFactory.getSlave(acct);
        
        Test.startTest();
            Database.DeleteResult results = Database.delete(slave, false);
         Database.DeleteResult results2 = Database.delete(acct, false);
         
        Test.stopTest(); 

     }
}