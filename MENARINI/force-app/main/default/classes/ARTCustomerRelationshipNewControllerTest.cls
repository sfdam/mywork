/*------------------------------------------------------------
Author: Alessandro Di Nardo @ten 2023-08-30

Description: classe di test per ART_CustomerRelationshipNewController
Methods :  


 ------------------------------------------------------------*/

@isTest
public class ARTCustomerRelationshipNewControllerTest {

    @testSetup static void setup() {

         
        Account account = new Account
        (
			Name = 'test',
            THR_AccountsKey__c = String.valueOf(System.currentTimeMillis()),
            BillingStreet = 'test',
            BillingCountry = 'Italy',
            BillingState = 'Napoli'
        );
        Insert account;

        Account relAcc = new Account
        (
			Name = 'related', THR_AccountsKey__c = '2'+String.valueOf(System.currentTimeMillis())
        );
        Insert relAcc;

        

    }


    static testmethod void test_getRelatedCustomer_Payer(){

        Account acc = [Select id from Account where Name = 'test' limit 1];

        cgcloud__Account_Extension__c accExtensionForPayer = new cgcloud__Account_Extension__c
        (
            cgcloud__Account__c = acc.Id,
			cgcloud__Payer_Role_Valid_From__c = System.today(),
            cgcloud__Payer_Role_Valid_Thru__c = System.today().addMonths(1)
        );
        Insert accExtensionForPayer;

        Test.startTest();
        String relationshipType = 'Payer';
        List<cgcloud__Account_Extension__c> acclist = ART_CustomerRelationshipNewController.getRelatedCustomer(relationshipType);
        Test.stopTest();

    }


    static testmethod void test_getRelatedCustomer_Broker(){

        Account acc = [Select id from Account where Name = 'test' limit 1];

        cgcloud__Account_Extension__c accExtensionForBroker = new cgcloud__Account_Extension__c
        (
            cgcloud__Account__c = acc.Id,
			cgcloud__Broker_Role_Valid_From__c = System.today(),
            cgcloud__Broker_Role_Valid_Thru__c = System.today().addMonths(1)
        );
        Insert accExtensionForBroker;

        Test.startTest();
        String relationshipType = 'Wholesaler';
        List<cgcloud__Account_Extension__c> acclist = ART_CustomerRelationshipNewController.getRelatedCustomer(relationshipType);
        Test.stopTest();

    }


    static testmethod void test_insertCustomer(){

        Account acc = [Select id from Account where Name = 'test' limit 1];
        Account relAcc = [Select id from Account where Name = 'related' limit 1];
        String selectedCustomerId = acc.id;
        String relatedCustomer = relAcc.Id;
        String relationshipType = 'Wholesaler';
        Date currentDay = Date.today().addDays(-1);
        Date lastDay = Date.today().addDays(1);
        String currentStartDate=  Date.today().Year()+'-'+Date.today().Month()+'-'+currentDay.Day();
        String currentEndDate= Date.today().Year()+'-'+Date.today().Month()+'-'+lastDay.Day();


        Test.startTest();
        String acclist = ART_CustomerRelationshipNewController.insertCustomer(selectedCustomerId,relatedCustomer,relationshipType,currentStartDate, currentEndDate);
        Test.stopTest();
        
    }


}