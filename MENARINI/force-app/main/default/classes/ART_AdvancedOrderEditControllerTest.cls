@isTest
public class ART_AdvancedOrderEditControllerTest {

    @isTest 
    static void test() {
    
    Test.startTest();
        
    cgcloud__Order_Template__c orderTemplate = new cgcloud__Order_Template__c
	(
        
    );
    Insert orderTemplate;
    
    cgcloud__Order__c order = new cgcloud__Order__c
    (
    cgcloud__Order_Template__c = orderTemplate.Id
    );
    Insert order;

    cgcloud__Order_Item__c orderItem = new cgcloud__Order_Item__c(
        cgcloud__Order__c = order.Id,
        cgcloud__Quantity__c = 20,
        cgcloud__Discount__c = 0
    );
    insert orderItem;

    ART_AdvancedOrderEditController.getPickListOptions();
    
    ART_AdvancedOrderEditController.getRecord(order.Id);
    try {
    ART_AdvancedOrderEditController.getRecord(null);
    } catch(Exception e) {}
    ART_AdvancedOrderEditController.saveRecord(order);
    ART_AdvancedOrderEditController.submitForApproval(order);
    try {
    ART_AdvancedOrderEditController.submitForApproval(new cgcloud__Order__c());
    } catch(Exception e) {}
    Test.stopTest();
	}
}