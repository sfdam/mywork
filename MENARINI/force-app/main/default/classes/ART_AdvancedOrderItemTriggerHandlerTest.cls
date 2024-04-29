@isTest
public class ART_AdvancedOrderItemTriggerHandlerTest {
	@TestSetup
    static void setupData(){
        Account a = new Account(Name = 'Test', THR_AccountsKey__c = '12345');
        insert a;
        
        cgcloud__Order_Template__c orderTemplate = new cgcloud__Order_Template__c(Name = 'TestTemplate');
        insert orderTemplate;
        
        cgcloud__Order__c order = new cgcloud__Order__c(cgcloud__Order_Template__c = orderTemplate.Id);
        insert order;
        
        cgcloud__Order_Item__c oi = new cgcloud__Order_Item__c(cgcloud__Order__c = order.Id);
        insert oi;
    }
    
    @isTest
    static void testAdvancedOrderItemInsert(){
        Test.startTest();
        cgcloud__Order__c order = [SELECT Id FROM cgcloud__Order__c LIMIT 1];
        insert new cgcloud__Order_Item__c(cgcloud__Order__c = order.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testAdvancedOrderItemDelete(){
        Test.startTest();
        cgcloud__Order__c order = [SELECT Id FROM cgcloud__Order__c LIMIT 1];
        cgcloud__Order_Item__c oi = new cgcloud__Order_Item__c(cgcloud__Order__c = order.Id);
        insert oi;
                
        delete oi;
        Test.stopTest();
    }
}