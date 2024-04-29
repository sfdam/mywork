@isTest
public with sharing class OnCRMRetiEsterneTriggerHandlerTest {
    @TestSetup
    public static void setup(){

        Profile profile = [SELECT id FROM Profile WHERE Name =: Label.System_Administrator LIMIT 1];
        User user = AllDataFactory.getUser('01', profile.Id, 'CORPORATE');
        insert user;

        System.runAs(user)
        {

            Account acc = AllDataFactory.getAccount('01', 'GruppoFinanziario');
            insert acc;

            CRM_IngaggioRetiEsterne__c  crmIngaggioRetiEsterne = new CRM_IngaggioRetiEsterne__c ();
            crmIngaggioRetiEsterne.CRM_Cliente__c=acc.id;
            crmIngaggioRetiEsterne.CRM_Esito__c='test';
            crmIngaggioRetiEsterne.CRM_Motivo__c='test';
            crmIngaggioRetiEsterne.CRM_Notes__c='test';
            
            insert crmIngaggioRetiEsterne;
        }

    }

    @IsTest
        static void testUpdateIngaggioRetiEsterne(){
            CRM_IngaggioRetiEsterne__c retiEsterne = [SELECT id,CRM_Esito__c FROM CRM_IngaggioRetiEsterne__c WHERE CRM_Esito__c='test'];
            retiEsterne.CRM_Esito__c='TEST2';
            update retiEsterne;
        }
}