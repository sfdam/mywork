@isTest
private class TestBPER_Presa_in_Carico_KPI_TempoMedio {
    @isTest
    static void testTrigger() {
        // Retrieve existing BusinessHours record
        BusinessHours defaultBH = [SELECT Id FROM BusinessHours WHERE Name = 'BPER' LIMIT 1];
        
        // Create a test Case record
        Case caseObj = new Case(
            Case_Start_Escalation_Date__c = DateTime.newInstance(2023, 1, 1, 0, 0, 0),
            Case_End_Escalation_Owner__c = DateTime.newInstance(2023, 1, 2, 0, 0, 0)
        );
        insert caseObj;
        
        // Update the test Case record
        caseObj.Case_End_Escalation_Owner__c = DateTime.newInstance(2023, 1, 3, 0, 0, 0);
        
        Test.startTest();
        update caseObj;
        Test.stopTest();
        
        // Retrieve the updated record
        caseObj = [SELECT KPI_Escalation_Owner_Taking_Charge__c FROM Case WHERE Id = :caseObj.Id];
        
        // Verify the expected result
        Decimal expectedKPI = 10.0; // Assuming the result is 24 hours based on the provided formula
        System.assertEquals(expectedKPI, caseObj.KPI_Escalation_Owner_Taking_Charge__c);
    }
}