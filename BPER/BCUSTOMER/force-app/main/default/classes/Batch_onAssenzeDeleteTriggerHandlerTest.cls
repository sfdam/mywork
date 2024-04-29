@isTest
public with sharing class Batch_onAssenzeDeleteTriggerHandlerTest {
    @isTest
    static void testBatch() {
        CRM_Assenze__c testAssenza = new CRM_Assenze__c();
        testAssenza.CRM_SyncGenesysDelete__c = true; 
        insert testAssenza;

        Set<Id> testIds = new Set<Id>();
        testIds.add(testAssenza.Id);

        Test.startTest();
        Batch_onAssenzeDeleteTriggerHandler.runBatch(testIds);
        Test.stopTest();
    }

    @isTest
    static void testExecuteMethod() {
        // Crea dati di test per il batch
        List<CRM_Assenze__c> testScope = new List<CRM_Assenze__c>();
        for (Integer i = 0; i < 10; i++) {
            CRM_Assenze__c assenza = new CRM_Assenze__c(
                CRM_IdGenesys__c = 'test' + i
            );
            testScope.add(assenza);
        }
        insert testScope;
        
        Set<Id> testScopeIds = new Set<Id>();
        for (CRM_Assenze__c assenza : testScope) {
            testScopeIds.add(assenza.Id);
        }
        
        Batch_onAssenzeDeleteTriggerHandler batchHandler = new Batch_onAssenzeDeleteTriggerHandler(testScopeIds);
        Test.startTest();
        batchHandler.execute(null, testScope);
        Test.stopTest();
        
        
    }
}