@isTest private class TXT_SalesAgentModalController_V2_Test {
   @isTest static void testGetAgents(){
      	Lead[] leads = TestDataFactory.createLeads(1);
        TXT_SalesAgentModalController_V2.WrapperResponse wr = new TXT_SalesAgentModalController_V2.WrapperResponse();
		wr =TXT_SalesAgentModalController_V2.getAgents(leads[0].id, 'Innolva');
       	leads[0].postalCode = '20125';
    	insert leads;
       	wr =TXT_SalesAgentModalController_V2.getAgents(leads[0].id,'Innolva');
       wr =TXT_SalesAgentModalController_V2.getAgents(leads[0].id,'Warrant');
       wr =TXT_SalesAgentModalController_V2.getAgents(leads[0].id,'CoMark');
       wr =TXT_SalesAgentModalController_V2.getAgents(leads[0].id,'');
       	Account[] acc = TestDataFactory.createAccounts(1);
       insert acc;
         wr =TXT_SalesAgentModalController_V2.getAgents(acc[0].id,'CoMark');
       wr =TXT_SalesAgentModalController_V2.getAgents(acc[0].id,'Warrant');
        
       
       	TXT_SalesAgentModalController_V2.getUserInfo();
       
       
   }

}