@isTest
public class ExternalRoutingController_Test {
	static testMethod void myUnitTest() {
        ExternalRoutingController erc = new ExternalRoutingController();

         ExternalRoutingController.createTask('123abc', 'customer name'); 
         
         ExternalRoutingController.createCase('123abc', 'customer name'); 
        
        List<Task> objId = new List<Task>{new task(Subject='test', softphoneerc__IWS_PreChat_Id__c='123abc', softphoneerc__IWS_Customer_Name__c='customer name',Status='Open')};
        insert objId;
        HTTPResponse res = new HTTPResponse();
                res.setBody('{}');
                res.setStatusCode(200); 
         
        Test.startTest();
        ExternalRoutingController.externalRouting(objId); 
        Test.stopTest();  
        ExternalRoutingController.updateTaskFromResponse(res, '123abc');
    }
    
   static testMethod void myUnitTest2() {
        ExternalRoutingControllerAbandoned erc = new ExternalRoutingControllerAbandoned();
       	Task t= new task(Subject='test', softphoneerc__IWS_PreChat_Id__c='1234567890abcde', softphoneerc__IWS_Customer_Name__c='customer name', softphone_it__IWS_Interaction_ID__c = null,Status='Open');
        insert t;
        List<String> ids = new List<String>{'1234567890abcdefgi'};
        Test.startTest();
        ExternalRoutingControllerAbandoned.CalloutOutbound('1234567890abcde');
        Test.stopTest();  
        ExternalRoutingControllerAbandoned.externalRouting(ids);
    }
    
    static testMethod void myUnitTest3() {
        ExternalRoutingControllerOmni erc = new ExternalRoutingControllerOmni();
        List<String> ids = new List<String>{'1234567890abcdefgi'};
        Test.startTest();    
        ExternalRoutingControllerOmni.CalloutOutbound('1234567890abcde', 'customerName');
        Test.stopTest(); 
        HTTPResponse res = new HTTPResponse();
                res.setBody('{}');
                res.setStatusCode(200);
        ExternalRoutingControllerOmni.createTaskFromResponse(res, '123abc');
        ExternalRoutingControllerOmni.externalRouting (ids);
    }
    
     static testMethod void myUnitTest4() {
        ExternalRoutingControllerTransfer erc = new ExternalRoutingControllerTransfer();
        Task t= new task(Subject='test', softphoneerc__IWS_PreChat_Id__c='1234567890abcde', softphoneerc__IWS_Customer_Name__c='customer name', softphone_it__IWS_Interaction_ID__c = null,Status='Open');
        insert t;
        List<String> ids = new List<String>{'1234567890abcdefgi'};
            
        Test.startTest();    
        ExternalRoutingControllerTransfer.CalloutOutbound('1234567890abcde', 'customerName');
        Test.stopTest(); 
        HTTPResponse res = new HTTPResponse();
                res.setBody('{}');
                res.setStatusCode(200);
        ExternalRoutingControllerTransfer.externalRouting (ids);
    }
}