@isTest
public class WGC_Test_EventiNegativi_Detail {
	
    @isTest
    public static void Test_GetAccountData(){
        //creo i dati di test
        WGC_AllDataFactory.disattivaTrigger();
        Double rand = Math.random();
        Account acc = new Account();
        acc.Name = 'Test_Account'+rand;
        acc.EventiNegativiAllarmiQuote__c = 'V';
        acc.EventiNegativiCIGS__c = 'V'; 
        acc.EventiNegativiGlobale__c = 'F';
        acc.EventiNegativiPregiudizievoli__c = 'F';
        acc.EventiNegativiProcedureConcorsuali__c = 'V';
        acc.EventiNegativiProtesti__c = 'V';
        
        insert acc;
        
        Test.startTest();
        WGC_EventiNegativi_Detail_Controller.getAccountDataEN(acc.Id);
        Test.stopTest();
    }
}