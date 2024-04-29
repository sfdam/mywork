@isTest private class INN_SalesAgentModalController_V2_Test {
   @isTest static void testGetAgents(){
       
       
       	Lead[] leads = TestDataFactory.createLeads(1);
        INN_SalesAgentModalController_V2.WrapperResponse wr = new INN_SalesAgentModalController_V2.WrapperResponse();
       	leads[0].postalCode = '20125';
    	insert leads;
		wr =INN_SalesAgentModalController_V2.getAgent(leads[0].id);

       	Account[] acc = TestDataFactory.createAccounts(1);
       	insert acc;
        wr =INN_SalesAgentModalController_V2.getAgent(acc[0].id);   
       
       	INN_SalesAgentModalController_V2.getUserInfo();
       wr =INN_SalesAgentModalController_V2.updateLead(acc[0].id, null, null);
        wr =INN_SalesAgentModalController_V2.updateLead(leads[0].id, null, null);
       
   }
}