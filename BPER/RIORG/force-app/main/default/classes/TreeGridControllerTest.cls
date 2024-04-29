@IsTest
public with sharing class TreeGridControllerTest {
        @TestSetup
        public static void setup(){
            String personAccountRTId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
            String cointestazioneRTId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Cointestazione').getRecordTypeId();
            Account childAccount= new Account();
            childAccount.LastName='TestChild';
            childAccount.RecordTypeId=personAccountRTId;
            Account cointestazione= new Account();
            cointestazione.Name='TestCoint';
            cointestazione.RecordTypeId=cointestazioneRTId;
            insert childAccount;
            insert cointestazione;
            CRM_AccountAccountJointOwnershipRelation__c relation = new CRM_AccountAccountJointOwnershipRelation__c();
            relation.CRM_Account__c=childAccount.Id;
            relation.CRM_JointOwnership__c=cointestazione.Id;
            insert relation;
        }
        @isTest
        public static void testGetRecordInfo(){
            String recordId=[SELECT Id FROM Account WHERE LastName='TestChild'][0].Id;
            test.startTest();
            TreeGridController.getRecordInfo(recordId);
            test.stopTest();
            System.assertEquals(true, (TreeGridController.getRecordInfo(recordId)) !=null);
        }
        @isTest
        public static void testgetAllData(){
            String personAccountRTId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
            String cointestazioneRTId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Cointestazione').getRecordTypeId();
            String recordIdChild=[SELECT Id FROM Account WHERE RecordTypeId=:personAccountRTId][0].Id;
            String recordIdCoin=[SELECT Id FROM Account WHERE RecordTypeId=:cointestazioneRTId][0].Id;
            test.startTest();
            TreeGridController.getAllData(recordIdChild,'PersonAccount');
            TreeGridController.getAllData(recordIdCoin,'Cointestazione');
            test.stopTest();
            System.assertEquals(true, (TreeGridController.getAllData(recordIdChild,'PersonAccount')) !=null);
            System.assertEquals(true, (TreeGridController.getAllData(recordIdCoin,'Cointestazione')) !=null);
        }
}