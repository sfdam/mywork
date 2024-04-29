@IsTest
public with sharing class GruppiFinanziariTreeGridPFControllerTest {
    @TestSetup
        public static void setup(){
            // Wallet__c port = new Wallet__c();
            // port.Name='PTF-PE-05387-00000-000058';
            // insert port;
            Account filiale = AllDataFactory.getAccount('01', 'FilialeDiRelazione');
            insert filiale;


            Wallet__c port = AllDataFactory.getWallet('MicroWallet',  filiale.Id, 'Personal');
            insert port;
            
            String personAccountRTId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
            String gruppoRTId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('GruppoFinanziario').getRecordTypeId();
            Account acc= new Account();
            acc.LastName='TestChild';
            acc.PTF_Portafoglio__c=port.Id;
            acc.RecordTypeId=personAccountRTId;
            insert acc;
            Account gruppo= new Account();
            gruppo.Name='TestGruppo';
            gruppo.RecordTypeId=gruppoRTId;
            insert gruppo;    
        }
    @isTest
    public static void testGetRecordInfo(){
        String recordId=[SELECT Id FROM Wallet__c LIMIT 1].Id;
        GruppiFinanziariTreeGridPFController.getRecordInfo(recordId);
    }



    @isTest
    public static void testgetAllData(){
        String recordId=[SELECT Id FROM Wallet__c LIMIT 1].Id;
        GruppiFinanziariTreeGridPFController.getAllData(recordId, null);
    }
}