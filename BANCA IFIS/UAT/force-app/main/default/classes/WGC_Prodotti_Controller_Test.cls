@isTest
public class WGC_Prodotti_Controller_Test {
    
    /*NON FUNZIONA QUESTO TEST*/
    @isTest
    public static void Test_aggiornaCampi_Prodotti_Posizione(){
        WGC_AllDataFactory.createUtenzaDefault();
        WGC_AllDataFactory.createLagKey();
        List<WGC_Linea_Prodotto__c> listLinee = WGC_AllDataFactory.createLineaProdotti2(1,true);
        listLinee.get(0).Descrizione_Posizione__c = 'FACTORING - CEDENTE';
        listLinee.get(0).Codice_Stato__c = '003';
        listLinee.get(0).Name ='2286931';
        Account a =[SELECT Id FROM Account LIMIT 1];
        // List<WGC_Linea_Prodotto__c> listLinProd = WGC_AllDataFactory.createLineaProdotti()

        Test.setMock(HttpCalloutMock.class, new WGC_HttpRequestController_MockImpl());
        Test.startTest();
        WGC_Prodotti_Controller.aggiornaCampi_Prodotti_Posizione('Account',a.Id);
        Test.stopTest();
    }

     @isTest
    public static void Test_aggiornaCampi_Prodotti_Posizione2(){
        WGC_AllDataFactory.createUtenzaDefault();
        WGC_AllDataFactory.createLagKey();
        List<WGC_Linea_Prodotto__c> listLinee = WGC_AllDataFactory.createLineaProdotti2(1,true);
        listLinee.get(0).Descrizione_Posizione__c = 'FACTORING - CEDENTE';
        listLinee.get(0).Codice_Stato__c = '003';
        listLinee.get(0).Name ='2286931';
        Account a =[SELECT Id FROM Account LIMIT 1];
        // List<WGC_Linea_Prodotto__c> listLinProd = WGC_AllDataFactory.createLineaProdotti()

        update listLinee;
        
        Test.setMock(HttpCalloutMock.class, new WGC_HttpRequestController_MockImpl());
        Test.startTest();
        WGC_Prodotti_Controller.aggiornaCampi_Prodotti_Posizione('Prodotto',a.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void Test_getAllProducts(){
        WGC_AllDataFactory.createUtenzaDefault();
        WGC_AllDataFactory.createLagKey();
        Account a = WGC_AllDataFactory.createAccount(1,false).get(0);
        a.CodiceIstituto3N__c='889';
        a.NDGGruppo__c = '107499';
        a.NDG__c = '107499';
        insert a;
        insert new WGC_Link_Legal_Entity__c(Anagrafica__c=a.Id, NDG_collegato__c =a.NDGGruppo__c, Cod_ist_collegato__c=a.CodiceIstituto3N__c);
        Test.startTest();
        WGC_Prodotti_Controller.getAllProducts(a.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void Test_getAllProductsNullID(){
        //List<Account> acc = WGC_AllDataFactory.createAccount(1,true);
        Test.startTest();
        WGC_Prodotti_Controller.getAllProducts(null);
        Test.stopTest();
    }

    @isTest
    public static void Test_getFacCedente(){
        WGC_AllDataFactory.createUtenzaDefault();
        WGC_AllDataFactory.createLagKey();
        Account a = WGC_AllDataFactory.createAccount(1,false).get(0);
        a.CodiceIstituto3N__c='889';
        a.NDGGruppo__c = '107499';
        a.NDG__c = '107499';
        insert a;
        insert new WGC_Link_Legal_Entity__c(Anagrafica__c=a.Id, NDG_collegato__c =a.NDGGruppo__c, Cod_ist_collegato__c=a.CodiceIstituto3N__c);

        //System.debug('1Query: '+WGC_LegalEntity_Utility.getLinkLegalEntity(a.NDGGruppo__c, a.CodiceIstituto3N__c));
        Test.startTest();
        WGC_Prodotti_Controller.getFacCedente(a.Id);
        Test.stopTest();
    }
    
    
    @isTest
    public static void Test_creaWrapperProd(){
        WGC_AllDataFactory.disattivaTrigger();
        List<WGC_Linea_Prodotto__c> lista = WGC_AllDataFactory.createLineaProdotti(5,true);
		/*lista.get(0).Anagrafica__r.CodiceIstituto3N__c = '123';
        lista.get(2).Anagrafica__r.CodiceIstituto3N__c = '123';
        lista.get(4).Anagrafica__r.CodiceIstituto3N__c = '123';
        update lista;*/
        Test.startTest();
        WGC_Prodotti_Controller.creaWrapperProd(lista);
        Test.stopTest();
    }
}