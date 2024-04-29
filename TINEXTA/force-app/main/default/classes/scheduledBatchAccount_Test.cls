@isTest
public class scheduledBatchAccount_Test {
    @isTest static void testExecute(){
 
        Test.StartTest();
		scheduledBatchaAccount sh1 = new scheduledBatchaAccount();      
 		String sch = '0 0 23 * * ?';
        	system.schedule('Test check', sch, sh1);
		Test.stopTest();
    }

}