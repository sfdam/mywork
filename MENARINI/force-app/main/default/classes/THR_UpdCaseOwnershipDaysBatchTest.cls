/**
 * Created by ssalaris on 12/08/2021.
 */

@isTest
public with sharing class THR_UpdCaseOwnershipDaysBatchTest {

    @isTest
    public static void caseOwnershipRecords_test(){

        Account accountIT = THR_TestDataFactory.CreateSingleCompleteAccount('Italy','IT0000001');
        Account depAccount = THR_TestDataFactory.depositAccountCreation();
        insert depAccount;

        Contact cntct= THR_TestDataFactory.CreateSingleCompleteContact(accountIT.id);

        Account accItaly = [SELECT Id FROM Account WHERE THR_Country__c ='IT' LIMIT 1];
        Contact contItaly = [SELECT Id FROM Contact WHERE AccountId =: accItaly.Id LIMIT 1];
        Account depAcc = [SELECT Id FROM Account WHERE THR_AccountGroup__c='Deposit' LIMIT 1];

        Case newCase = THR_TestDataFactory.createCase('THR_ReturnRequest', accItaly.Id, contItaly.Id, 'Pharma','IT', depAcc.id);
        insert newCase;

        Test.startTest();
        Database.executeBatch(new THR_UpdCaseOwnershipDaysBatch(), 200);
        Test.stopTest();

    }

}