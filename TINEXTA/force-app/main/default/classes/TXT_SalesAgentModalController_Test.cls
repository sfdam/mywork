@isTest private class TXT_SalesAgentModalController_Test {
   @isTest static void testGetAgents(){
      	Lead[] leads = TestDataFactory.createLeads(1);
        TXT_SalesAgentModalController.WrapperResponse wr = new TXT_SalesAgentModalController.WrapperResponse();
		wr =TXT_SalesAgentModalController.getAgents(leads[0].id);
       	leads[0].postalCode = '20125';
    	insert leads;
       	wr =TXT_SalesAgentModalController.getAgents(leads[0].id);
       	TXT_SalesAgentModalController.getUserInfo();
       
       
   }

}