public class WGC_EventiNegativi_Detail_Controller {
	
    @AuraEnabled
    public static Account GetAccountDataEN(String recordId){
        Account a = new Account();
        a = [SELECT Id, Name, EventiNegativiAllarmiQuote__c, EventiNegativiCIGS__c, EventiNegativiGlobale__c, 
             EventiNegativiPregiudizievoli__c, EventiNegativiProcedureConcorsuali__c, EventiNegativiProtesti__c FROM Account WHERE Id=:recordId];
        
        System.debug('@@@ account data ' + a);
        
        return a;
    }
}