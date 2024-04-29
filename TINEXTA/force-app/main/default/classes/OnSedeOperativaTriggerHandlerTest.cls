@isTest
public class OnSedeOperativaTriggerHandlerTest 
{
    @TestSetup
    static void makeData()
    {
        //create custom settings
        Funzionalita__c fun = DataFactoryNew.createCustomSettings();
        fun.Disabilita_Trigger_SedeOperativa__c = false;
        fun.Disabilita_tutti_i_workflow__c = true;
        fun.Disabilita_tutti_i_process_builder__c = true;
        fun.Disabilita_tutti_i_trigger__c = true;
        update fun;
        //sede operativa
        //account
        account[] accList = DataFactoryNew.createAccounts(1);
        Sede_Operativa_Warrant__c sed = DataFactoryNew.createSedeOperativa(accList[0]);
    }
    @isTest
    public static void testTrigger()
    {
        Sede_Operativa_Warrant__c sed = [select id from Sede_Operativa_Warrant__c];
        sed.WRT_Default__c = false;
        update sed;
    }
    @isTest
    public static void test2()
    {
        account acc = [select id from account limit 1];
        Sede_Operativa_Warrant__c sed2 = DataFactoryNew.createSedeOperativa(acc);
    }
}