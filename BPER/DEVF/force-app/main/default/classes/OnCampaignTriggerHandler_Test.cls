@isTest
global class OnCampaignTriggerHandler_test {
    
    

    @isTest static void testgenesysQueueCallout(){
        
        Campaign c = new Campaign();
        c.Name = 'testgenesysQueueCallout Campaign';
        c.softphone_it__Genesys_Cloud_Sync__c=true;
        c.IsActive=true;
        c.softphone_it__Gc_Custom_Fields__c='Id,CRM_NumeroTentativi__c';
        insert c;
        
        c.CRM_QueueName__c = 'Test';
        update c;
        
        
        String response = '{"entities":[{"id":"123"}]}';
        OnCampaignTriggerHandler.updateQueueIdFromResponse(response,c);
    } 

    
}