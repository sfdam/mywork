/*------------------------------------------------------------
Author: Alessandro Di Nardo @ten 2023-08-30

Description: classe di test per ART_CustomerRelationshipEditController
Methods :  


 ------------------------------------------------------------*/


@isTest
public class ART_CustomerRelationshipEditCtrl_Test {
    
    @testSetup static void setup() {
 

        Account customerAcc = new Account
        (
			Name = 'customer', THR_AccountsKey__c = '1'+String.valueOf(System.currentTimeMillis())
        );
        Insert customerAcc;
       
        Account relAcc = new Account
        (
			Name = 'related', THR_AccountsKey__c = '2'+String.valueOf(System.currentTimeMillis())
        );
        Insert relAcc;
        
        cgcloud__Account_Relationship__c accRel = new cgcloud__Account_Relationship__c
        (
            cgcloud__Account__c = customerAcc.Id,
            cgcloud__Related_Account__c = RelAcc.Id,
            cgcloud__Relationship_Type__c = 'Wholesaler',
            cgcloud__Start_Date__c = Date.today().addDays(-1),
            cgcloud__End_Date__c = Date.today().addDays(1)
        );
        Insert accRel;

    }

    
    static testmethod void selectCustomerRelationship_Test(){
        
        Test.startTest();
        cgcloud__Account_Relationship__c accRel = [SELECT id from cgcloud__Account_Relationship__c limit 1];
        System.debug('AD cgcloud__Account_Relationship__c accRel : ' +accRel.id );
        ART_CustomerRelationshipEditController.selectCustomerRelationship(accRel.id);
        
        Test.stopTest();
    
    }

    @isTest
    static void updateCustomerRelationship_Test(){
    //(String customerRelationshipID,String selectedCustomerId,String relatedCustomer,String relationshipType,String currentStartDate,String currentEndDate,String recordID)
        Test.startTest();
        cgcloud__Account_Relationship__c accRel = [SELECT id from cgcloud__Account_Relationship__c limit 1];
        Account customerAcc = [SELECT id from Account where Name=:'customer'];
        Account relAcc = [SELECT id from Account where Name=:'related'];

        String relationshipType='Payer';
        Date currentDay = Date.today().addDays(-1);
        Date lastDay = Date.today().addDays(1);
        String currentStartDate=  Date.today().Year()+'-'+Date.today().Month()+'-'+currentDay.Day();
        String currentEndDate= Date.today().Year()+'-'+Date.today().Month()+'-'+lastDay.Day();
        
        ART_CustomerRelationshipEditController.updateCustomerRelationship(customerAcc.id,relAcc.id,relationshipType,currentStartDate,currentEndDate,accRel.id);
        
        Test.stopTest();
    }

}