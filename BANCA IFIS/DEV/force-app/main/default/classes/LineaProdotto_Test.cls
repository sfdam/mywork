@isTest
public class LineaProdotto_Test {
    
    @isTest
    public static void testTriggerInsert(){
        WGC_AllDataFactory.createUtenzaDefault();
        List<WGC_Linea_Prodotto__c> listaLinProd = WGC_AllDataFactory.createLineaProdotti(1,true);
        
    }

    @isTest
    public static void testTriggerUpdateClienteInAvvio(){
        WGC_AllDataFactory.createUtenzaDefault();
        List<Opportunity> listaOpty = WGC_AllDataFactory.createOpportunity2(1);
        Funzionalita__c f = Funzionalita__c.getInstance();
        f.DisabilitaControlloCambioFaseOpp__c = true;
        upsert f;

        Account a = WGC_AllDataFactory.createAccount(1,true)[0];
        listaOpty[0].AccountId =a.Id;
        insert listaOpty;
        WGC_Linea_Prodotto__c lineaProd = new WGC_Linea_Prodotto__c();
        lineaProd.Name = 'LineaProd';
        lineaProd.Anagrafica__c =a.Id;
        lineaProd.Opportunit__c= listaOpty[0].Id;
        lineaProd.Qualifica_Prodotto__c = 'Cliente in avvio';

        Test.startTest();
        insert lineaProd;

        update lineaProd;
        System.debug('lineaProd: '+JSON.serialize(lineaProd));
        Test.stopTest();
    }

    @isTest
    public static void testTriggerUpdateClienteAttivo(){
        WGC_AllDataFactory.createUtenzaDefault();
        Funzionalita__c f = Funzionalita__c.getInstance();
        f.DisabilitaControlloCambioFaseOpp__c = true;
        upsert f;

        List<Opportunity> listaOpty = WGC_AllDataFactory.createOpportunity2(1);
        
        Account a = WGC_AllDataFactory.createAccount(1,true)[0];
        listaOpty[0].AccountId =a.Id;
        insert listaOpty;
        WGC_Linea_Prodotto__c lineaProd = new WGC_Linea_Prodotto__c();
        lineaProd.Name = 'LineaProd';
        lineaProd.Anagrafica__c =a.Id;
        lineaProd.Opportunit__c= listaOpty[0].Id;
        lineaProd.Qualifica_Prodotto__c = 'Cliente attivo';

        Test.startTest();
        insert lineaProd;

        update lineaProd;
        System.debug('lineaProd: '+JSON.serialize(lineaProd));
        Test.stopTest();
    }

}