@isTest
public class StSTriggerHandlerTest {
    static testMethod void testStS (){ 
		Account testAcc = new Account(Name = 'TEST', Primary_Industry__c = 'Agricultural Technologies');
        insert testAcc;
        List<string> idList = new List<string>();
        idList.add(testAcc.Id);
        StSTriggerHandler.sendRecords(idList);
    }
}