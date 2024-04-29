@isTest
public class scheduledCMKBachableAccountTimeout_Test {
    @isTest static void testExecute(){
         Funzionalita__c x= new Funzionalita__c();
        x.Disabilita_Integrazione__c = true;
        x.Disabilita_tutti_i_process_builder__c= true;
        x.Disabilita_tutti_i_trigger__c = true;
        insert x;
        Test.StartTest();
		scheduledCMKBachableAccountTimeout sh1 = new scheduledCMKBachableAccountTimeout();      
 		String sch = '0 0 23 * * ?';
        	system.schedule('Test check', sch, sh1);
		Test.stopTest();
    }


}