@isTest
public class WRT_QblWorkOrderInfostoreTest 
{
	@TestSetup
    static void makeData()
    {
        EndpointServizi__c endp = new EndpointServizi__c();
        endp.WRN_Key_IntegrazioneInfoStore__c = 'test';
        endp.WRN_Url_IntegrazioneInfoStore__c = 'https://salesforce-test.test.it/api/v1/Wh/Opportunity';
        endp.WRT_SharePoint_Folders_Account__c = 'test';
        endp.WRT_SharePoint_Create_Folder_Account__c = 'https://sp-integration.test.it/api/SharePoint/CreateCustomerFolders';
        endp.WRN_URL_SharePoint_Auth__c = 'https://sp-integration.test.it/token';
        endp.WRT_SharePoint_Create_Folder_Opportunity__c = 'https://sp-integration.test.it/api/SharePoint/CreateOpportunityFolders';
        endp.WRT_SharePoint_Folders_Opportunity__c = 'test';
        endp.WRT_Create_CPQ_Infostore__c = 'https://salesforce-test.warranthub.it/api/v1/Wh/Quote';
        endp.WRT_URL_Integrazione_HdR__c = 'https://salesforce-test.warranthub.it/api/v1/Wh/WorkOrder';
        insert endp;
        
        Funzionalita__c x= new Funzionalita__c();
        x.Disabilita_tutti_i_trigger__c=true;
        x.Disabilita_Integrazione__c = false;
        x.Disabilita_tutti_i_process_builder__c = true;
        x.Disabilita_tutti_i_workflow__c = true;
        insert x;
        
        
        
    }
    
    @isTest
    public static void testBatch()
    {
        account[] accList = DataFactoryNew.create_Account();
        opportunity[] opp = DataFactoryNew.createOpportunityWarrant(accList);
        workorder wok = DataFactoryNew.createWO(accList[0], opp[0]);
        
        Test.setMock(HttpCalloutMock.class, new HTTPMockFactory(200, 'OK', '{'+
                                                                '"WorkOrders" : [ {'+
                                                                    '"WorkOrderLineItems" : [ ],'+
                                                                        '"WRT_Link_WorkOrder_Infostore__c" : "https://infostore-test.warranthub.it/pages/offerte.php?xcodid=1655917418",'+
                                                                    '"ID_External_System__c" : 165565457418,'+
                                                                        '"Id" : "'+ wok.id+'"'+
                                                                            '} ]'+
                                                                '}', new Map<String,String>()));
        
        Test.startTest();
        
        System.enqueueJob(new WRT_QblWorkOrderInfostore (new list<String>{wok.id})); 
        
        Test.stopTest();
        
    }
}