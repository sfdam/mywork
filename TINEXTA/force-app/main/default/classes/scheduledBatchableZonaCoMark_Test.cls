@isTest
public class scheduledBatchableZonaCoMark_Test {
    @isTest static void testExecute(){
             Test.StartTest();
		scheduledBatchableZonaCoMark sh1 = new scheduledBatchableZonaCoMark();      
 		String sch = '0 0 23 * * ?';
        	system.schedule('Test check', sch, sh1);
		Test.stopTest();
    }
}