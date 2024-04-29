/* 

Created by: Lorenzo Vento 05-12-2022

Last modified by: Lorenzo Vento 05-12-2022

*/

@isTest
public with sharing class onAccountTriggerHandlerTest {
    public onAccountTriggerHandlerTest() {

    }

    @TestSetup
    static void makeData() {
    }

    @IsTest
    static void afterInsert() {
        
        user u = THR_TestDataFactory.userCreation('CGCloud_User_Profile');
        
        Test.startTest();

        System.runAs(u) {

            Account a = THR_TestDataFactory.createAccount('Test DCR', 'IT', '0000');
            a.BillingCity='Milano';
            a.BillingCountry='Italy';
            a.BillingPostalCode='10222';
            a.BillingState='Milano';
            a.BillingStreet='Via nuova';
            insert a;
        }

        Test.stopTest();
    }

    @IsTest
    static void beforeUpdate() {
        
        user u = THR_TestDataFactory.userCreation('CGCloud_User_Profile');

        Test.startTest();

        System.runAs(u) {

            Account a = THR_TestDataFactory.createAccount('Test DCR', 'IT', '0000');
            a.BillingCity='Milano';
            a.BillingCountry='Italy';
            a.BillingPostalCode='10222';
            a.BillingState='Milano';
            a.BillingStreet='Via nuova';
            insert a;

            a.cgcloud__name_2__c = 'Test DCR';
            update a;
        }

        Test.stopTest();    
    }
}