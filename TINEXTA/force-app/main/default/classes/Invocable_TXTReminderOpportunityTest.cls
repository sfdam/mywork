@isTest
public class Invocable_TXTReminderOpportunityTest 
{
	@TestSetup
    static void makeData()
    {
        //create custom settings
        Funzionalita__c fun = DataFactoryNew.createCustomSettings();
        fun.Disabilita_Trigger_WorkOrder__c = true;
        fun.Disabilita_tutti_i_workflow__c = true;
        fun.Disabilita_tutti_i_process_builder__c = true;
        fun.Disabilita_tutti_i_trigger__c = true;
        update fun;
        
        id rid = [SELECT Id from RecordType where Name = 'Corvallis' AND SObjectType = 'Opportunity' LIMIT 1].Id;
        //create account
        account[] accList = DataFactoryNew.createAccounts(1);
        //create opportunity
        opportunity[] opp = DataFactoryNew.createOpportunityWarrant(accList);
        opp[0].recordtypeid = rid;
        opp[0].CRV_Listino__c = 'cyber';
        opp[0].closedate = system.today() -7;
        update opp;
        
        opportunity[] opp2 = DataFactoryNew.createOpportunityWarrant(accList);
        opp2[0].recordtypeid = rid;
        opp2[0].CRV_Listino__c = 'cyber';
        opp2[0].closedate = system.today() +7;
        update opp2;
    }
    @isTest
    public static void testInvocable()
    {
        test.startTest();
            Invocable_TXTReminderOpportunity.Invocable_TXTReminderOpportunity(new list<string>{'Scadute'});
            Invocable_TXTReminderOpportunity.Invocable_TXTReminderOpportunity(new list<string>{'InScadenza'});
        	Invocable_TXTReminderOpportunity.Invocable_TXTReminderOpportunity(new list<string>{'NonAggiornate'});
        test.stopTest();
    }
}