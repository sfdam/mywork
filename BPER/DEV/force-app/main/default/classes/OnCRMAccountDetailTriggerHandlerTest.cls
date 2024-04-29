@isTest
public with sharing class OnCRMAccountDetailTriggerHandlerTest {
    @TestSetup
    public static void setup(){

        

            Account acc = AllDataFactory.getAccount('01', 'GruppoFinanziario');
            insert acc;

            CRM_AccountDetail__c crmAccountDetails = new CRM_AccountDetail__c();
            crmAccountDetails.CRM_Account__c=acc.id;
            crmAccountDetails.CRM_AbilitatoOFS__c=true;
            crmAccountDetails.CRM_IntestatarioRapporto__c=true;
            crmAccountDetails.Name='Nome dettaglio test';
            crmAccountDetails.OperationStrategy__c='test';
            crmAccountDetails.NDW_ExternalId__c='id';
            crmAccountDetails.NDW_X_Update_TS__c=Date.today();

            CRM_AccountDetail__c crmAccountDetails2 = new CRM_AccountDetail__c();
            crmAccountDetails2.CRM_Account__c=acc.id;
            crmAccountDetails2.CRM_AbilitatoOFS__c=false;
            crmAccountDetails2.CRM_IntestatarioRapporto__c=false;
            crmAccountDetails2.Name='Nome dettaglio test2';
            crmAccountDetails2.OperationStrategy__c='test2';
            crmAccountDetails2.NDW_ExternalId__c='id2';
            crmAccountDetails2.NDW_X_Update_TS__c=Date.today();
            
            
            insert crmAccountDetails;
            insert crmAccountDetails2;
        

    }

    @IsTest
        static void testCRMAccountDetail(){
            CRM_AccountDetail__c crmAccountDetails = [SELECT id,CRM_AbilitatoOFS__c FROM CRM_AccountDetail__c  WHERE name='Nome dettaglio test'];
            CRM_AccountDetail__c crmAccountDetails2 = [SELECT id,CRM_AbilitatoOFS__c FROM CRM_AccountDetail__c  WHERE name='Nome dettaglio test2'];
            crmAccountDetails.CRM_AbilitatoOFS__c=false;
            crmAccountDetails2.CRM_AbilitatoOFS__c=true;
            update crmAccountDetails;
            update crmAccountDetails2;
        }
}