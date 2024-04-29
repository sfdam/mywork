@isTest
public class richiesteOppDataTableControllerTest {

    @TestSetup
    static void setupTestData() {
        Account testAccount = new Account();
        testAccount.Name = 'Test Account';
        insert testAccount;
        
        Id bstoreRtId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Opportunit_Bstore').getRecordTypeId();

        Opportunity testOpportunity = new Opportunity();
        testOpportunity.Name = 'Test Opportunity';
        testOpportunity.CRM_Canale__c = 'BSTORE';
        testOpportunity.StageName = 'Open'; // Required field
        testOpportunity.CloseDate = Date.today(); // Required field
        testOpportunity.AccountId = testAccount.Id;
        testOpportunity.RecordTypeId = bstoreRtId;
        insert testOpportunity;
        
        Id coi = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Cointestazione').getRecordTypeId();        
        
        Account testAccount2 = new Account();
        testAccount2.Name = 'Test Account2';
        testAccount2.RecordtypeId = coi;
        insert testAccount2;
        
        
        CRM_AccountAccountJointOwnershipRelation__c jointOwnershipRecord = new CRM_AccountAccountJointOwnershipRelation__c();
        jointOwnershipRecord.CRM_Account__c = testAccount.Id;
        jointOwnershipRecord.CRM_JointOwnership__c = testAccount2.Id; 
        
        insert jointOwnershipRecord;

    }

    @isTest
    public static void testGetAllData() {
        Test.startTest();
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];

        List<Opportunity> result = richiesteOpportunityDataTableController.getAllData(testAccount.Id);
        Test.stopTest();

        List<Id> accountIds = new List<Id>();
        accountIds.add(testAccount.Id); 
        List<CRM_AccountAccountJointOwnershipRelation__c> jointOwnershipRecords = [
            SELECT CRM_JointOwnership__c
            FROM CRM_AccountAccountJointOwnershipRelation__c
            WHERE CRM_Account__c = :testAccount.Id
        ];

        List<String> jointOwnershipValues = new List<String>();
        for (CRM_AccountAccountJointOwnershipRelation__c record : jointOwnershipRecords) {
            jointOwnershipValues.add(record.CRM_JointOwnership__c);
        }

        if (!jointOwnershipValues.isEmpty()) {
            List<CRM_AccountAccountJointOwnershipRelation__c> cointestatariRecords = [
                SELECT CRM_Account__c
                FROM CRM_AccountAccountJointOwnershipRelation__c
                WHERE CRM_JointOwnership__c IN :jointOwnershipValues
            ];

            for (CRM_AccountAccountJointOwnershipRelation__c record : cointestatariRecords) {
                accountIds.add(record.CRM_Account__c);
            }
        }

    }
}