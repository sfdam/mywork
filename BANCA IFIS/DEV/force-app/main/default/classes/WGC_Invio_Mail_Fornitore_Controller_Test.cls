@isTest
public with sharing class WGC_Invio_Mail_Fornitore_Controller_Test {
    @isTest
    public static void testMetodi(){
        WGC_AllDataFactory.disattivaTrigger();
        List<Account> acc = WGC_AllDataFactory.createAccount(2,true);
        WGC_Soggetti_Collegati__c sogColl = new WGC_Soggetti_Collegati__c(Anagrafica__c=acc.get(0).Id,Anagrafica_Collegata__c=acc.get(1).Id);
        insert sogColl;
        System.debug('prova: '+[SELECT Id , WGC_Email_Referente_Fornitore__c, WGC_Invio_Mail_Fornitore__c, Anagrafica__c, Anagrafica_Collegata__c, Anagrafica_Collegata__r.WGC_Specialista_Factoring__r.Email FROM WGC_Soggetti_Collegati__c]);

        Test.startTest();
        WGC_Invio_Mail_Fornitore_Controller.updateFlagAccount(acc.get(1).Id, acc.get(0).Id);
        
        Test.stopTest();
    }

}