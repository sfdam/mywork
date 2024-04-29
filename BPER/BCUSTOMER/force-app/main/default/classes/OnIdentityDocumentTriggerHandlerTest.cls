/*********************************************
 * Name             :   OnIdentityDocumentTriggerHandlerTest
 * Creation Date    :   2023-04-13
 * Author           :   Alessandro Di Nardo @TEN
 * Description      :   test for trigger handler "OnIdentityDocumentTriggerHandler"
 **********************************************/
@isTest
public with sharing class OnIdentityDocumentTriggerHandlerTest {
   
    @TestSetup
    static void setUp(){

        Funzionalita__c x = new Funzionalita__c();
        x.Disable_Trigger__c =false;
        insert x;

        List<Account> listAcc = new List<Account>();

        Account filiale= new Account();
        filiale.Name='Filiale';
        filiale.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('FilialeDiRelazione').getRecordTypeId();
        filiale.FinServ__BankNumber__c ='05387';
        filiale.PTF_OFS__c =True;

        listAcc.add(filiale);

        Account filiale2= new Account();
        filiale2.Name='Filiale';
        filiale2.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('FilialeDiRelazione').getRecordTypeId();
        filiale2.FinServ__BankNumber__c ='05387';
        filiale2.PTF_OFS__c =True;

        listAcc.add(filiale2);

        insert listAcc;

        List<Account> acc = [Select Id from Account];

        List<IdentityDocument> listIdentityDocument = new List<IdentityDocument>();

        IdentityDocument document = new IdentityDocument();

        document.Name='Test';
        document.IdDocumentType='Test';
        document.ExpirationDate=Date.today().addDays(3);
        document.RelatedLegalEntityId=acc[0].Id;

        listIdentityDocument.add(document);

        IdentityDocument document2 = new IdentityDocument();


        document2.Name='Test';
        document2.IdDocumentType='Test';
        document2.ExpirationDate=Date.today().addDays(3);
        document2.RelatedLegalEntityId=acc[1].Id;

        listIdentityDocument.add(document2);

        insert listIdentityDocument;

        
    }

    @IsTest
    static void testInsert(){

        Account a1 = [Select Id from Account limit 1];

        List<IdentityDocument> listIdentityDocument = new List<IdentityDocument>();

        IdentityDocument document = new IdentityDocument();

        document.Name='Test';
        document.IdDocumentType='Test';
        document.ExpirationDate=Date.today().addDays(3);
        document.RelatedLegalEntityId=a1.Id;

        listIdentityDocument.add(document);
        insert listIdentityDocument;
    }
}