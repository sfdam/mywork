@isTest
public with sharing class OnCRMClaimsTriggerHandlerTest {
    @TestSetup
    public static void setup(){

        Profile profile = [SELECT id FROM Profile WHERE Name =: Label.System_Administrator LIMIT 1];
        User user = AllDataFactory.getUser('01', profile.Id, 'CORPORATE');
        insert user;

        System.runAs(user)
        {

            Account acc = AllDataFactory.getAccount('01', 'GruppoFinanziario');
            insert acc;

            CRM_Claims__c crmClaims = new CRM_Claims__c();
            crmClaims.CRM_Author__c='Administrator';
            crmClaims.CRM_Account__c=acc.id;
            crmClaims.CRM_Status__c='Closed';
            crmClaims.CRM_Subject__c='TEST';
            crmClaims.Name='12559';

            insert crmClaims;
        }

    }

    @IsTest
        static void testCRMClaim(){
            CRM_Claims__c crmClaim = [SELECT id,CRM_Subject__c FROM CRM_Claims__c WHERE name='12559'];
            crmClaim.CRM_Subject__c='TEST2';
            update crmClaim;
        }
}