@isTest
public class CalcolaSommaControvaloriControllerTest {

    @TestSetup
    static void makeData(){
        
        Product2 product = new Product2(
            Name = 'Test'
        );
        insert product;
        Account acc = new Account(Name = 'TestPrimary');
        insert acc;

        Account acc2 = new Account(Name = 'TestJoint');
        insert acc2;

        FinServ__FinancialAccount__c parentRecord = new FinServ__FinancialAccount__c(Name = 'TestCalcolaSomma', FinServ__PrimaryOwner__c = acc.Id, FinServ__JointOwner__c = acc2.Id);
        parentRecord.FinServ__ProductName__c = product.Id;
        insert parentRecord;
        List<FinServ__FinancialAccount__c> childRecords = new List<FinServ__FinancialAccount__c>();

        Schema.DescribeSObjectResult d = Schema.SObjectType.FinServ__FinancialAccount__c;
        Id rtChildRecords = d.getRecordTypeInfosByName().get('Titolo').getRecordTypeId();

        FinServ__FinancialAccount__c child1 = new FinServ__FinancialAccount__c(FinServ__PrimaryOwner__c = acc.Id, FinServ__JointOwner__c = acc2.Id, CRM_Deposito__c = parentRecord.Id, CRM_Equivalent__c = 2000, RecordTypeId = rtChildRecords);
        child1.FinServ__ProductName__c = product.Id;
        childRecords.add(child1);
        FinServ__FinancialAccount__c child2 = new FinServ__FinancialAccount__c(FinServ__PrimaryOwner__c = acc.Id, FinServ__JointOwner__c = acc2.Id, CRM_Deposito__c = parentRecord.Id, CRM_Equivalent__c = 4000, RecordTypeId = rtChildRecords);
        child2.FinServ__ProductName__c = product.Id;
        childRecords.add(child2);

        insert childRecords;
    }

    @isTest
    private static void calcolaSomma(){

        FinServ__FinancialAccount__c record = [SELECT Id FROM FinServ__FinancialAccount__c WHERE Name = 'TestCalcolaSomma' LIMIT 1];

        Test.startTest();
            CalcolaSommaControvaloriController.CalcolaSommaControvalori(record.Id);
            CalcolaSommaControvaloriController.CalcolaSommaControvalori(null);
        Test.stopTest();
    }
}