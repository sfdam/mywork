@isTest
public class scheduledBatchableZonaCoMarkYester_Test {
    @isTest static void testExecute(){
             Test.StartTest();
		scheduledBatchableZonaCoMarkyesterday sh1 = new scheduledBatchableZonaCoMarkyesterday();      
 		String sch = '0 0 23 * * ?';
        	system.schedule('Test check1',sch, sh1);
		Test.stopTest();
    }
}