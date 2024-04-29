@isTest
private class OnPrefeasibilityTriggerHandlerTest
{

	@testSetup static void setup()
    {
     	Funzionalita__c fun = DataFactoryNew.createCustomSettings();
        fun.Disabilita_Trigger_WorkOrder__c = true;
        fun.Disabilita_tutti_i_workflow__c = true;
        fun.Disabilita_tutti_i_process_builder__c = true;
        fun.Disabilita_tutti_i_trigger__c = true;
        fun.Disabilita_Trigger_Prefeasibility__c = false;
        update fun;
                
        account[] accList = DataFactoryNew.createAccounts(1);
        //create opportunity
        opportunity[] opp = DataFactoryNew.createOpportunityWarrant(accList);
        
        //recordtype id and WRT_Outcome__c != 'Approved'
		Wrt_pre_feasibility__c wrtprefeasibilitycObj = new Wrt_pre_feasibility__c (
			WRT_Object__c ='A', 
			WRT_Reference_Opportunity__c = opp[0].id, 
			WRT_Brand__c ='D',
            WRT_Technician_Iper__c = system.UserInfo.getUserId()
		);
		insert wrtprefeasibilitycObj;
	}

	@isTest static void testMethod1() 
    {
        opportunity opp = [select id from opportunity];
        
        Funzionalita__c fun = [select id,Disabilita_Trigger_Prefeasibility__c from Funzionalita__c ];
        fun.Disabilita_Trigger_Prefeasibility__c = false;
        update fun;
        
        /*Wrt_pre_feasibility__c wrtprefeasibilitycObj = new Wrt_pre_feasibility__c (
			WRT_Object__c ='A', 
			WRT_Reference_Opportunity__c = opp.id, 
			WRT_Brand__c ='D'
		);*/
        Wrt_pre_feasibility__c wrtprefeasibilitycObj = [select id, WRT_Technician_Iper__c from Wrt_pre_feasibility__c];
        wrtprefeasibilitycObj.WRT_Technician_Iper__c = null;
		update wrtprefeasibilitycObj;
	}
}