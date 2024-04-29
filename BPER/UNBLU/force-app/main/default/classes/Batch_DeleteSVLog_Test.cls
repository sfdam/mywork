@isTest
public class Batch_DeleteSVLog_Test {
    
    @TestSetup
    static void setup(){
        List<SV_Log__c> svlogs = new List<SV_Log__c>();
        for (Integer i=0; i<10; i++) {
        	SV_Log__c svlog = new SV_Log__c();
            svlogs.add(svlog);
        }
        insert svlogs;
        Numeri_Tecnici__mdt nt = (Numeri_Tecnici__mdt)MetadataUtility.getRecordByName('Numeri_Tecnici__mdt', 'DelSVLogMonths');
        Integer months = Integer.valueOf(nt.Valori__c);
        Date today = Date.today();
        today = today.addMonths(-months);
        DateTime dt = DateTime.newInstanceGmt(today.year(),today.month(),1,0,0,0);
        for (SV_Log__c sv : svlogs) {
        	Test.setCreatedDate(sv.Id, dt.addDays(-1));
        }
    }
    @isTest
    static void unitTest() {
        Test.startTest();
        Batch_DeleteSVLog sv = new Batch_DeleteSVLog();
        sv.initRunner(new List<ScheduledJob__c>());
        Database.executeBatch(sv);
        Test.stopTest();
    }
}