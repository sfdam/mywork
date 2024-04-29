@isTest private class OnAccountTriggerHandler_Test {
	 @isTest static void testAccount(){
     	Account[] accts = TestDataFactory.createAccounts(4);
      for(Account acc : accts){
         acc.Censimento_Manuale__c = false;
         acc.Data_Ultimo_Arricchimento__c = System.Today();
         acc.Rating__c = 'A';
      }
      insert accts;

      accts= TestDataFactory.updateAccounts(accts);
      for(Account acc : accts){
         acc.Societa_su_CTM__c = 'Corvallis';
      }
      update accts;
         Map_Slave__c msTest = [SELECT Name FROM Map_Slave__c WHERE Name =: accts[0].id LIMIT 1];
      	Database.DeleteResult msResults = Database.delete(msTest, false);
        Test.startTest();
        	Database.DeleteResult[] results = Database.delete(accts, false);
        Test.stopTest();     
     }
}