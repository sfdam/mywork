@isTest
public with sharing class THR_CaseTriggerHandler_Test {

    @testSetup
    static void setupUsers(){

		Account accountIT = THR_TestDataFactory.CreateSingleCompleteAccount('Italy','IT0000001');
        Account accountES = THR_TestDataFactory.CreateSingleCompleteAccount('Spain', 'ES0000001');

       	Account depAccount = THR_TestDataFactory.depositAccountCreation();
        insert depAccount;

        Contact cntct= THR_TestDataFactory.CreateSingleCompleteContact(accountIT.id);
		Contact cntctDepSpagna = THR_TestDataFactory.CreateSingleCompleteContact(accountES.id);

         Id entitlementProcessItalyId = [SELECT Id FROM SlaProcess
                                         WHERE SObjectType = 'Case'
                                         AND Name='Italy SLAs' limit 1].Id;

         Id entitlementProcessSpaignId = [SELECT Id FROM SlaProcess
                                         WHERE SObjectType = 'Case'
                                         AND Name='Spain SLAs' limit 1].Id;

        Entitlement entitlementIT = THR_TestDataFactory.createEntitlement('Entitlement Italy', 'IT', accountIT.Id);
        entitlementIT.SlaProcessId = entitlementProcessItalyId;
        Entitlement entitlementES = THR_TestDataFactory.createEntitlement('Entitlement Spain', 'ES', accountES.Id);
        entitlementES.SlaProcessId = entitlementProcessSpaignId;

        insert new List<Entitlement>{entitlementIT, entitlementES};
    }

    @isTest
    private static void assignEntitlementItaly(){
		Account accItaly = [SELECT Id FROM Account WHERE THR_Country__c ='IT' LIMIT 1];
		Contact contItaly = [SELECT Id FROM Contact WHERE AccountId =: accItaly.Id LIMIT 1];
        Account depAcc = [SELECT Id FROM Account WHERE THR_AccountGroup__c='Deposit' LIMIT 1];
        Entitlement entitlementES = [SELECT Id FROM Entitlement WHERE Name='Entitlement Italy' LIMIT 1];

        Test.startTest();
        Case newCase = THR_TestDataFactory.createCase('THR_ReturnRequest', accItaly.Id, contItaly.Id, 'Pharma','IT', depAcc.id);
        insert newCase;
        newCase.entitlementId=entitlementES.Id;
        newCase.Status='Closed';
        newCase.THR_ClosureReason__c='Other Delivery';
        update newCase;
        Test.stopTest();

        Case caseAfterInsert = [SELECT id, THR_Country__c, entitlementId, entitlement.THR_Country__c FROM Case WHERE Id =: newCase.Id];
        System.assertNotEquals(caseAfterInsert.entitlementId, null);
        System.assertEquals(caseAfterInsert.entitlement.THR_Country__c, caseAfterInsert.THR_Country__c);

    }

    @isTest
    private static void assignEntitlementSpain(){
		Account accSpaign = [SELECT Id FROM Account WHERE THR_Country__c ='ES' LIMIT 1];
		Contact contSpaign = [SELECT Id FROM Contact WHERE AccountId =: accSpaign.Id LIMIT 1];
        Account depAcc = [SELECT Id FROM Account WHERE THR_AccountGroup__c='Deposit' LIMIT 1];
        Entitlement entitlementES = [SELECT Id FROM Entitlement WHERE Name='Entitlement Spain' LIMIT 1];

        Test.startTest();
        Case newCase = THR_TestDataFactory.createSpainCase('THR_Logistic_ES', accSpaign.Id,contSpaign.Id, 'Laboratorios Guidotti','ES', depAcc.id);
        insert newCase;
        newCase.entitlementId=entitlementES.Id;
        newCase.Status='Closed';
        update newCase;
        Test.stopTest();

        Case caseAfterInsert = [SELECT id, THR_Country__c, entitlementId, entitlement.THR_Country__c FROM Case WHERE Id =: newCase.Id];
        System.assertNotEquals(caseAfterInsert.entitlementId, null);
        System.assertEquals(caseAfterInsert.entitlement.THR_Country__c, caseAfterInsert.THR_Country__c);

    }

    @isTest
    private static void caseOwnershipRecords_test(){

        Account accItaly = [SELECT Id FROM Account WHERE THR_Country__c ='IT' LIMIT 1];
        Contact contItaly = [SELECT Id FROM Contact WHERE AccountId =: accItaly.Id LIMIT 1];
        Account depAcc = [SELECT Id FROM Account WHERE THR_AccountGroup__c='Deposit' LIMIT 1];

        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User u = new User(Alias = 'standt', Email='stan@testorg.com',
                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                LocaleSidKey='en_US', ProfileId = p.Id,
                TimeZoneSidKey='America/Los_Angeles', UserName='stan@testorg.com');
        insert u;

        Test.startTest();
        Case newCase = THR_TestDataFactory.createCase('THR_ReturnRequest', accItaly.Id, contItaly.Id, 'Pharma','IT', depAcc.id);
        insert newCase;
        newCase.OwnerId = u.Id;
        update newCase;
        Test.stopTest();

    }

}