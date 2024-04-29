@isTest
public class ART_WholesalerControllerTest {

    @isTest 
    static void test() {
        
        Test.startTest();
        
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
        
        cgcloud__Order_Template__c orderTemplate = new cgcloud__Order_Template__c
		(
        
        );
        Insert orderTemplate;
        
        cgcloud__Order__c order = new cgcloud__Order__c
        (
			cgcloud__Order_Template__c = orderTemplate.Id,
            cgcloud__Order_Account__c = customerAcc.Id
        );
        Insert order;
        
    	ART_WholesalerController.getAccountRelationshipList(order.Id);
        ART_WholesalerController.updateOrder(order.Id, customerAcc.Id);
        Test.stopTest();
	}
    
}