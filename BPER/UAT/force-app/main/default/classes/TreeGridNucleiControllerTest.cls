@IsTest
public with sharing class TreeGridNucleiControllerTest {
    @TestSetup
        public static void setup(){

            Account filiale = AllDataFactory.getAccount('04', 'FilialeDiRelazione');
            filiale.PTF_BranchTypology__c = 'A';
            insert filiale;
            Wallet__c port = AllDataFactory.getWallet('MicroWallet', filiale.Id, 'Personal');
            insert port;
            Nucleo__c nuc=new Nucleo__c();
            nuc.PTF_CodId__c ='Test';
            insert nuc;
            String personAccountRTId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
            Account acc= new Account();
            acc.LastName='TestChild';
            acc.PTF_Portafoglio__c=port.Id;
            acc.PTF_Nucleo__c=nuc.Id;
            acc.RecordTypeId=personAccountRTId;
            insert acc;    
        }

        @isTest
        public static void testgetAllData(){
            String recordId=[SELECT Id FROM Wallet__c LIMIT 1].Id;
            TreeGridNucleiController.getAllData(recordId);
        }
}