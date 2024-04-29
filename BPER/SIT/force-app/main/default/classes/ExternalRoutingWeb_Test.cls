@isTest
public class ExternalRoutingWeb_Test {
    static testMethod void myUnitTest4() {
        ExternalRoutingWeb erw = new ExternalRoutingWeb();
        Case c= new case(CRM_MotivoDellaChat__c='1234567890abcde', SuppliedName='customer name', G_LastAgentRouted__c = 'G_LastAgentRouted__c');
        insert c;
        List<String> ids = new List<String>{c.Id};
            
        Test.startTest();    
        ExternalRoutingWeb.CalloutOutbound(c.Id);
        Test.stopTest(); 
        HTTPResponse res = new HTTPResponse();
                res.setBody('{}');
                res.setStatusCode(200);
        ExternalRoutingWeb.externalRouting (ids);
        
        GenesysSetting__c gs = new GenesysSetting__c();
        gs.Name = 'WebCanale Web-To-Case';
        //gs.RecordTypeId = '0120D000000DyWHQA0';
        gs.RecordTypeId = Schema.SObjectType.GenesysSetting__c.getRecordTypeInfosByName().get('Web').getRecordTypeId();
        gs.G_MEDIA_TYPE__c = 'web';
        gs.G_PRIORITY__c = 5;
        gs.G_QUEUE_ID__c = '123';
        gs.G_MotivoDiContatto__c = 'Altri prodotti e servizi';
        insert gs;
         
        ExternalRoutingWeb.externalRouting (ids);
    }
}