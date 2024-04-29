/**
 * Created by alai on 17/03/2022.
 */
@IsTest
public with sharing class THR_ProductTriggerHandlerTest {

    @TestSetup
    static void setup() {

        Account acc = new Account();
        acc.Name = 'PACIENTE GENERICO';
        acc.THR_AccountsKey__c ='111111B';
        acc.THR_Country__c = 'ES';
        insert acc;

        Contact cntct = new Contact (FirstName= 'NomeContattodDep', LastName='CognomeContattoDep', THR_Country__c = 'ES', AccountId=acc.Id,Email='nomeContattoDep@test.it');
        Contact cntdel = new Contact (FirstName= 'Contacto', LastName='Bloqueado', THR_Country__c = 'ES', AccountId=acc.Id,Email='nomeContattoDel@test.it');
        insert cntct;
        insert cntdel;

        THR_TestDataFactory.ProductCreation();

        Map<String,String> caseRtMap = THR_TestDataFactory.createRtMap('Case');
        Case phCase = new Case();
        phCase.AccountId = acc.Id;
        phCase.ContactId = cntct.Id;
        phCase.THR_RequestType__c = 'Pharmacovigilance';
        phCase.THR_Type__c='Adverse Reaction';
        phCase.Origin ='Phone';
        phCase.RecordTypeId = caseRtMap.get('THR_Pharmacovigilance');
        phCase.Status = 'New';
        phCase.THR_Country__c = 'ES';
        phCase.THR_BuManagerAuthorizationToProceed__c ='Yes';
        phCase.THR_GdAuthorizationToProceed__c ='Yes';
        phCase.THR_SAAuthorizationToProceed__c ='Yes';
        phCase.THR_Batch__c ='LottoTest0001';
        phCase.Priority ='Medium';
        phCase.THR_Client_Request_Date__c = Date.newInstance(2020, 06, 25);
        phCase.THR_DDTNumber__c = 'DDTSPA_00001';
        phCase.THR_DDTdate__c  = Date.newInstance(2020, 06, 30);
        insert phCase;
    }

    @IsTest
    static void test1() {

        THR_TestDataFactory.userCreation('System Administrator');
        Test.startTest();

        Account acc = [SELECT Id, Name FROM Account WHERE THR_AccountsKey__c ='111111B' LIMIT 1];
        Contact cntcPh = [SELECT Id, Name, AccountId FROM Contact WHERE FirstName = 'NomeContattodDep' LIMIT 1];
        Contact cntcdel = [SELECT Id, Name, AccountId FROM Contact WHERE FirstName = 'Contacto' LIMIT 1];
        Product2 pL = [SELECT Id,IsActive, Name, ProductCode FROM Product2 LIMIT 1];
        Case c = [SELECT Id, AccountId, ContactId, THR_Contact__c, THR_Locked_Date__c, THR_Locked__c FROM Case WHERE ContactId = :cntcPh.Id];

        THR_Related_Object__c cItemProd = THR_TestDataFactory.caseItemCreationSpaign(acc.Id,pL.Id,'Product', c.Id);


        System.debug('### Verify Test Data Statuses START ###');
        System.assert(pL.IsActive == true);
        System.assert(cItemProd.THR_Marketing_End_Date__c == false);
        System.assert(c.THR_Contact__c == null);
        System.assert(c.ContactId == cntcPh.Id);
        System.assert(c.AccountId == acc.Id);
        System.debug('### Verify Test Data Statuses END ###');

        pL.IsActive = false;
        update pL;

        THR_Related_Object__c ciProd = [
                SELECT Id, THR_Marketing_End_Date__c, THR_Product__c, THR_Case_Related__r.THR_Locked_Date__c, THR_Case_Related__r.AccountId, THR_Case_Related__r.THR_Locked__c, THR_Product__r.IsActive, THR_Case_Related__r.ContactId, THR_Case_Related__r.THR_Contact__c
                FROM THR_Related_Object__c
                WHERE Id = :cItemProd.Id];

        System.debug('### Verify Test Data Statuses After Update START ###');
        System.assert(pL.IsActive == false);
        System.assert(ciProd.THR_Marketing_End_Date__c == true);
        System.assert(ciProd.THR_Case_Related__r.THR_Contact__c != null);
        System.assert(ciProd.THR_Case_Related__r.ContactId == cntcdel.Id);
        System.assert(ciProd.THR_Case_Related__r.AccountId == acc.Id);
        System.assert(ciProd.THR_Case_Related__r.THR_Locked__c != null);
        System.assert(ciProd.THR_Case_Related__r.THR_Locked_Date__c.date() == Date.today());
        System.debug('### Verify Test Data Statuses After Update END ###');


        Test.stopTest();

    }

}