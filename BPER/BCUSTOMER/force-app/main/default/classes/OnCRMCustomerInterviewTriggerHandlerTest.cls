@isTest
public with sharing class OnCRMCustomerInterviewTriggerHandlerTest {
    @TestSetup
    public static void setup(){

        Profile profile = [SELECT id FROM Profile WHERE Name =: Label.System_Administrator LIMIT 1];
        User user = AllDataFactory.getUser('01', profile.Id, 'CORPORATE');
        insert user;

        System.runAs(user)
        {
           
            Account acc = AllDataFactory.getAccount('01', 'PersonAccount');
            insert acc;

            Datetime todayDate = Datetime.now();
            Date day = Date.today();
            CRM_CustomerInterview__c crm = new CRM_CustomerInterview__c();
            crm.Name='Test';
            crm.CRM_Customer__c=acc.id;
            //crm.CRM_CreatedDate__c=todayDate;
            //crm.CRM_FormulaNumeroTagliando__c='Tagliando N. 1';
            //crm.CRM_Idx__c='4';
            //crm.CRM_Autore__c=acc.Name;
            crm.CRM_BankCreditNotes__c='test';
            crm.CRM_AttendeesLocation__c='test';
            crm.PTF_CustomerInterviewNum__c=1;
            crm.CRM_GenericNotes__c='Tagliando effettuato';
            crm.CRM_Join_Meeting__c='Private';
            crm.CRM_DataUltimaCompilazione__c=todayDate;
            crm.RecordTypeId=SV_Utilities.getRecordTypeByDeveloperName('CRM_CustomerInterview__c', 'Chiuso');
            crm.CRM_AdministeredSaving__c='Interessato a nuovo prodotto/servizio';
            crm.CRM_ContactStatus__c = 'Tagliando effettuato';

            insert crm;
        }

    }

    @IsTest
        static void testUpdateCustomerInterview(){
            CRM_CustomerInterview__c crmCustomer = [SELECT id,name FROM CRM_CustomerInterview__c WHERE name='Test'];
            crmCustomer.name='TEST2';
            update crmCustomer;
        }
}