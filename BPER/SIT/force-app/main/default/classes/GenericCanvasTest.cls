/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-09-2020
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   10-09-2020   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
@isTest
private  class GenericCanvasTest {

    @TestSetup
    static void setup(){
        Account acc = AllDataFactory.getAccount('test01','Banca');
        acc.CRM_NDG__c = '1234';
        acc.FinServ__BankNumber__c = '1234';
        insert acc;
        CRM_Channel__c channel = new CRM_Channel__c();
        channel.CRM_Account__c = acc.Id;
        insert channel;
    }

    @isTest static void canavsUnitTest() {
        User u = TestDataFactorySSO.createUser();
        u.banca__c = '1234';
        insert u;
        CRM_Channel__c record = [SELECT Id FROM CRM_Channel__c LIMIT 1];
        Test.startTest();
        GenericCanvasController.getCanvas('Phone_Banking', 'CRM_Channel__c',record.Id);
        System.runAs(u) {
            System.debug('AAA'+u);
        	GenericCanvasController.getCanvas('PDV', 'CRM_Channel__c',record.Id);
        }
        Test.stopTest();
    }
}