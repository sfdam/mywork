/*
 * classi di riferimento 
 * 							OnWorkOrderTriggerHandler
 * 							OnWorkOrderLineItemTriggerHandler
 * */
@isTest
public class OnWorkOrderTriggerHandlerTest 
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
        
        WRT_Warrant_FSL_Settings__c sett = new WRT_Warrant_FSL_Settings__c();
        sett.SetupOwnerId = UserInfo.getOrganizationId();
        sett.Supplier_Low_Marginality__c = 0;
        sett.Where_query_batch_WOLI__c = 'WRT_Record_Type_Name__c = \'Driver\'';
        sett.BonoficaWOLIToday__c = false;
        insert sett;
        //create account
        account[] accList = DataFactoryNew.createAccounts(1);
        //create opportunity
        opportunity[] opp = DataFactoryNew.createOpportunityWarrant(accList);
        //create product2
        product2 prod = DataFactoryNew.createProductDriver();
        prod.name = 'IPER';
        update prod;
        //create pricebookentry
        pricebookentry[] priceb = DataFactoryNew.createPricebookEntry(prod);
        //update opportunity
        opp[0].Pricebook2Id = Test.getStandardPricebookId();
        update opp;
        //create opportunitylineitem
        opportunitylineitem oppli = DataFactoryNew.createProdOpp(opp[0], prod);
        //update custom settings
        //fun.Disabilita_tutti_i_workflow__c = false;
        //fun.Disabilita_tutti_i_process_builder__c = false;
        //update fun;
        //create workorder
        workorder wok = DataFactoryNew.createWO(accList[0], opp[0]);
        //wok.WRT_Product_Name__c = 'IPER';
        wok.WRT_Opportunity_Product__c = oppli.id;
        update wok;
        //create workorderlineitems
        workorderlineitem[] woli = DataFactoryNew.createWoli(wok);
        //update custom settings
        //fun.Disabilita_tutti_i_workflow__c = true;
        //fun.Disabilita_tutti_i_process_builder__c = true;
        //update fun;
        //create supplier
        WRT_FSL_Supplier__c[] supp = DataFactoryNew.createSupp();
    }
    @isTest
    public static void testTrigger()
    {
        Funzionalita__c fun = [select id,Disabilita_Trigger_WorkOrder__c  from Funzionalita__c ];
        fun.Disabilita_Trigger_WorkOrder__c = false;
        update fun;
        Id rid= [SELECT Id from RecordType where Name = 'Iper' AND SObjectType = 'WorkOrder' LIMIT 1].Id;
        workorder[] wok = [select id from workorder];
        wok[0].RecordTypeId = rid;
        wok[0].Status = 'Technical Analysis';
        wok[0].WRT_Investment_Amount__c = 500;
        wok[0].WRT_Number_Of_Goods__c = 0;
        update wok;
        
        workorder wokClone = wok[0].clone(false, false, false);
        insert wokClone;
    }
    @isTest
    public static void testTriggerWoli()
    {
        Funzionalita__c fun = [select id,Disabilita_Trigger_WorkOrderLineItems__c from Funzionalita__c ];
        fun.Disabilita_Trigger_WorkOrderLineItems__c = false;
        update fun;
        workorderlineitem[] woli = [select id from workorderlineitem];
        woli[0].status = 'Completato';
        update woli;
        woli[0].status = 'Nuovo';
        update woli;
    }
    @isTest
    public static void testBatchWOLI()
    {
        WRT_BatchWOLI btcWOLI = new WRT_BatchWOLI();
        database.executebatch(btcWOLI, 200);
        
        workorder[] wok = [select id from workorder];
        
        WRT_BatchWO btcWO = new WRT_BatchWO(new set<String>{wok[0].id}, new set<string>());
        database.executebatch(btcWO, 200);
    }
}