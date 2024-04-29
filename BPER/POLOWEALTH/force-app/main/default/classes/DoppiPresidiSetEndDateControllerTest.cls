@isTest
private class DoppiPresidiSetEndDateControllerTest {
    
    @isTest
    static void unitTest() {
        Wallet__c ptf = new Wallet__c(PTF_ModelloDiServizio__c='Private');
        insert ptf;
        Account acc = AllDataFactory.getAccount('01', 'Banca');
        acc.PTF_Portafoglio__c = ptf.Id;
        insert acc;
        String recTypeId = SV_Utilities.getRecordTypeByDeveloperName('NDGManagementMember__c','DoppioPresidio');
        NDGManagementMember__c ndgman = new NDGManagementMember__c();
        insert ndgman;
        NDGManagementMember__c ndgman2 = new NDGManagementMember__c(RecordTypeId=recTypeId,PTF_NDG__c=acc.Id);
        insert ndgman2;
        Test.startTest();
        DoppiPresidiSetEndDateController.updateFlagDoppiPresidi(ndgman.Id, null);
        try {
            DoppiPresidiSetEndDateController.updateFlagDoppiPresidi(ndgman2.Id, acc.Id);
        }
        catch(Exception exc) {}
        Test.stopTest();
        System.assertEquals(false, (DoppiPresidiSetEndDateController.updateFlagDoppiPresidi(ndgman.Id, null)));
    }
}