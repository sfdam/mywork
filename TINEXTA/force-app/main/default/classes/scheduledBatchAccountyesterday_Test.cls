@isTest
public class scheduledBatchAccountyesterday_Test {
    @isTest static void testExecute(){
 
        Test.StartTest();
		scheduledBatchaAccountYesterday sh1 = new scheduledBatchaAccountYesterday();      
 		String sch = '0 0 23 * * ?';
        	system.schedule('Test check1', sch, sh1);
		Test.stopTest();
    }

}