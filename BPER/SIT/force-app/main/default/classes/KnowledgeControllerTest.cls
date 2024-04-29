@isTest
public with sharing class KnowledgeControllerTest {
    @TestSetup
    static void setup(){
        Case cs = AllDataFactory.getCase();
        cs.CRM_DigitalServices__c='Smart Web';
        insert cs;

    }

    @isTest 
    static void testKnowledge() {
        List<String> ls1 = new List<String>();
        ls1.add('Digital Services');
        Id recordId = [SELECT id FROM Case LIMIT 1].Id;

        

        
        User usr = KnowledgeController.getUserInfo();
        List<String> aree = KnowledgeController.getAllArea();
        Map<String, SObject> getOpenAreaChild = KnowledgeController.getOpenAreaChild(ls1);
        Map<String, SObject> getOpenScopeChild = KnowledgeController.getOpenScopeChild(ls1);
        Map<String, SObject> getOpenLevel1Child = KnowledgeController.getOpenLevel1Child(ls1);
        Map<String, SObject> getOpenLevel2Child = KnowledgeController.getOpenLevel2Child(ls1);
        Map<String, SObject> getOpenLevel3Child = KnowledgeController.getOpenLevel3Child(ls1);

        Map<String, SObject> getAllDataFromText = KnowledgeController.getAllDataFromText('digital');
        Map<String, SObject> getAllDataForCase = KnowledgeController.getAllDataForCase(recordId);
        Map<String,SObject> getAllDataFromTextHCI = KnowledgeController.getAllDataFromTextHCI('digital');
        Map<String,SObject> getAllDataFromTextHCE = KnowledgeController.getAllDataFromTextHCE('digital');
        Map<String,SObject> getAllDataFromTextExUBI = KnowledgeController.getAllDataFromTextExUBI('digital');
        Map<String,SObject> getAllDataFromTextExISP = KnowledgeController.getAllDataFromTextExISP('digital');
        Test.startTest();
        list<RecordType> getActiveRecordType = KnowledgeController.getActiveRecordType();
		Test.stopTest();
        System.assertEquals(true, getActiveRecordType.size()>0);

    }
}