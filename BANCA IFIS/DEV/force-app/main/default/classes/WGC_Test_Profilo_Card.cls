@isTest
public class WGC_Test_Profilo_Card {

    @isTest
    public static void Test_getElementAccount(){
        //Creo i dati di test
        WGC_AllDataFactory.disattivaTrigger();
        Double rand = Math.Random();
        List<Ateco__c> listAteco = WGC_AllDataFactory.createAteco(1,true);
        List<Account> accList = WGC_AllDataFactory.createAccount(2,true);
        
        accList.get(0).WGC_Factoring_Attivo__c = true;
        accList.get(0).WGC_Filo_Diretto_Attivo__c = true;
        accList.get(0).Ateco__c=listAteco.get(0).Id;

        update accList;
        
        Map<String, Schema.RecordTypeInfo> rtid = Schema.SObjectType.WGC_Soggetti_Collegati__c.getRecordTypeInfosByName();
        System.debug('@@@ rt id ' + rtid);

        //Creo i soggetti collegati (uno per ogni record type)
        WGC_Soggetti_Collegati__c sc = new WGC_Soggetti_Collegati__c();
        sc.Name = 'Test_SC'+rand;
        sc.Anagrafica__c = accList.get(0).Id;
        sc.Anagrafica_Collegata__c = accList.get(0).Id;
        sc.RecordTypeId = rtid.get('Competitor').getRecordTypeId();

        insert sc;

        WGC_Soggetti_Collegati__c sc2 = new WGC_Soggetti_Collegati__c();
        sc2.Name = 'Test_SC'+rand;
        sc2.Anagrafica__c = accList.get(0).Id;
        sc2.Anagrafica_Collegata__c = accList.get(0).Id;
        sc2.RecordTypeId = rtid.get('Fornitore/Cliente').getRecordTypeId();

        insert sc2;

        WGC_Soggetti_Collegati__c sc3 = new WGC_Soggetti_Collegati__c();
        sc3.Name = 'Test_SC'+rand;
        sc3.Anagrafica__c = accList.get(0).Id;
        sc3.Anagrafica_Collegata__c = accList.get(0).Id;
        sc3.RecordTypeId = rtid.get('Tribunale').getRecordTypeId();

        insert sc3;

        WGC_Soggetti_Collegati__c sc4 = new WGC_Soggetti_Collegati__c();
        sc4.Name = 'Test_SC'+rand;
        sc4.Anagrafica__c = accList.get(0).Id;
        sc4.Anagrafica_Collegata__c = accList.get(0).Id;
        sc4.RecordTypeId = rtid.get('Partner').getRecordTypeId();

        insert sc4;

        WGC_Soggetti_Collegati__c sc5 = new WGC_Soggetti_Collegati__c();
        sc5.Name = 'Test_SC'+rand;
        sc5.Anagrafica__c = accList.get(0).Id;
        sc5.Anagrafica_Collegata__c = accList.get(0).Id;
        sc5.RecordTypeId = rtid.get('FCI').getRecordTypeId();

        insert sc5;

        Test.startTest();
        WGC_Profilo_Card_Controller.getElementAccount(accList.get(0).Id);
        WGC_Profilo_Card_Controller.getElementAccount(accList.get(1).Id);
        Test.stopTest();
    }
}