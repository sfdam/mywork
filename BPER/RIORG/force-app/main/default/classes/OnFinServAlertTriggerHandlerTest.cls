@isTest
public with sharing class OnFinServAlertTriggerHandlerTest {
    @TestSetup
    public static void setup(){

        Profile profile = [SELECT id FROM Profile WHERE Name =: Label.System_Administrator LIMIT 1];
        User user = AllDataFactory.getUser('01', profile.Id, 'CORPORATE');
        insert user;

        System.runAs(user)
        {

            Account acc = AllDataFactory.getAccount('01', 'GruppoFinanziario');
            insert acc;

            Date today = Date.today();
            FinServ__Alert__c finServAlert = new FinServ__Alert__c();
            finServAlert.RecordTypeId=SV_Utilities.getRecordTypeByDeveloperName('FinServ__Alert__c', 'Scadenziario_Portafoglio');
            finServAlert.CRM_CED__c='123';
            finServAlert.FinServ__Account__c=acc.id;
            finServAlert.CRM_TipoDocumento__c='MAV';
            finServAlert.FinServ__Message__c='Scadenza';
            finServAlert.CRM_DataScadenza__c=today;
            finServAlert.CRM_EsitoContatto__c='Da ricontattare';
            finServAlert.CRM_Importo__c=100;
            insert finServAlert;
        }

    }

    @IsTest
        static void testTrackHistory(){
            FinServ__Alert__c alert = [SELECT id,CRM_CED__c FROM FinServ__Alert__c WHERE CRM_CED__c='123'];
            alert.CRM_CED__c='1234';
            update alert;
        }
}