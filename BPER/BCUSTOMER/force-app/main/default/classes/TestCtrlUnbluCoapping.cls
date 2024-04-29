@isTest
public class TestCtrlUnbluCoapping {

    @isTest
    static void test_getCoappingUrl_1(){

        Test.startTest();

        CC_Unblu_Settings__c cc = new CC_Unblu_Settings__c();
        cc.Name = 'COAPPING_URL';
        cc.CC_Value__c = 'test';
        insert cc;

        Case c = new Case();
        c.Origin = 'Chat';
        insert c;

        CtrlUnbluCoapping.getCoappingUrl(c.Id,'');

        Test.stopTest();

    }
    
    @isTest
    static void test_getCoappingUrl_2(){

        Test.startTest();

        Account acc = new Account();
        acc.Name = 'test1234599';
        insert acc;

        CC_Unblu_Settings__c cc = new CC_Unblu_Settings__c();
        cc.Name = 'COAPPING_URL';
        cc.CC_Value__c = 'test';
        insert cc;

        Case c = new Case();
        c.Origin = 'Chat';
        c.AccountId = acc.Id;
        insert c;

        CtrlUnbluCoapping.getCoappingUrl(c.Id,'');

        Test.stopTest();

    }

    @isTest
    static void test_getCoappingUrl_3(){

        Test.startTest();

        Account acc = new Account();
        acc.Name = 'test1234599';
        insert acc;

        CRM_Channel__c channel = new CRM_Channel__c();
        channel.CRM_Account__c = acc.Id;
        channel.CRM_UserCodeStatus__c = 'Active';
        insert channel;

        CC_Unblu_Settings__c cc = new CC_Unblu_Settings__c();
        cc.Name = 'COAPPING_URL';
        cc.CC_Value__c = 'test';
        insert cc;

        Case c = new Case();
        c.Origin = 'Chat';
        c.AccountId = acc.Id;
        insert c;

        CtrlUnbluCoapping.getCoappingUrl(c.Id,'');

        Test.stopTest();

    }

}