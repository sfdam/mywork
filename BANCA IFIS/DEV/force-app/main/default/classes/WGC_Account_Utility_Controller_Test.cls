@isTest
public with sharing class WGC_Account_Utility_Controller_Test {

    @isTest
    public static void Test_callServiceEventiNegativi(){
        
        WGC_AllDataFactory.createUtenzaDefault();
        WGC_AllDataFactory.creaImpServ();
        WGC_AllDataFactory.createLagKey();
        List<Account> listAcc = WGC_AllDataFactory.createAccount(1,true);
       
        
        User u = WGC_AllDataFactory.createUser(1,true).get(0);
        WGC_AllDataFactory.createLinkLegalEntity(15,true);
        listAcc = [SELECT Id,Name,NDGGruppo__c,ProvinciaCCIAA__c,RAE__c FROM Account];
        System.debug('listAcc '+listAcc);
        Test.setMock(HttpCalloutMock.class, new WGC_HttpRequestController_MockImpl());
        Test.startTest();
        WGC_Account_Utility_Controller.callServiceEventiNegativi(listAcc.get(0).Id);
        
        Test.stopTest();
    }

    @isTest
    public static void Test_accountHasHesitatedTaskOrEvent(){
        
        WGC_AllDataFactory.createUtenzaDefault();
        WGC_AllDataFactory.creaImpServ();
        WGC_AllDataFactory.createLagKey();
        List<WGC_Linea_Prodotto__c> listProd= WGC_AllDataFactory.createLineaProdotti(1,true);
        List<Account> listAcc = [SELECT Id, Name, codiceIstituto3N__c FROM Account LIMIT 1];
        User u = WGC_AllDataFactory.createUser(1,true).get(0);
        System.debug('qua: '+listAcc.get(0).codiceIstituto3N__c);
        WGC_Link_Legal_Entity__c testLegEnt = new WGC_Link_Legal_Entity__c();
        testLegEnt.NDG__c='107400';
        testLegEnt.NDG_collegato__c='107400';
        testLegEnt.Anagrafica__c = listAcc.get(0).Id;
        testLegEnt.Anagrafica_collegata__c=listAcc.get(0).Id;
        testLegEnt.Cod_ist__c='881';
        testLegEnt.Cod_ist_collegato__c='881';
        insert testLegEnt;
        listAcc.get(0).codiceIstituto3N__c='881';
        update listAcc;
        Test.setMock(HttpCalloutMock.class, new WGC_HttpRequestController_MockImpl());
        Test.startTest();
        WGC_Account_Utility_Controller.accountHasHesitatedTaskOrEvent(listAcc.get(0).Id);
        Test.stopTest();
    }
     @isTest
    public static void Test_getAccountHeaderData(){
        
        WGC_AllDataFactory.createUtenzaDefault();
        WGC_AllDataFactory.creaImpServ();
        WGC_AllDataFactory.createLagKey();
        List<Account> listAcc = WGC_AllDataFactory.createAccount(2,true);
        
        User u = WGC_AllDataFactory.createUser(1,true).get(0);
        WGC_AllDataFactory.createLinkLegalEntity(15,true);
        
        
        Test.setMock(HttpCalloutMock.class, new WGC_HttpRequestController_MockImpl());
        Test.startTest();
        WGC_Account_Utility_Controller.getAccountHeaderData(listAcc.get(1).Id);
        Test.stopTest();
    }
    
    @isTest
    public static void Test_getAccountHeaderData2(){
        WGC_AllDataFactory.createUtenzaDefault();
        WGC_AllDataFactory.creaImpServ();
        WGC_AllDataFactory.createLagKey();
        
        User u = WGC_AllDataFactory.createUser(1,true).get(0);
        //WGC_AllDataFactory.createLinkLegalEntity(15,true);
        List<Account> listAcc = WGC_AllDataFactory.createAccount(2,true);
        
        Test.setMock(HttpCalloutMock.class, new WGC_HttpRequestController_MockImpl());
        Test.startTest();
        WGC_Account_Utility_Controller.getAccountHeaderData(listAcc.get(1).Id);
        Test.stopTest();
    }
    
     @isTest
    public static void Test_getLegalEntities(){
        
        WGC_AllDataFactory.createUtenzaDefault();
        WGC_AllDataFactory.creaImpServ();
        WGC_AllDataFactory.createLagKey();
        List<Account> listAcc = WGC_AllDataFactory.createAccount(2,true);
        
        User u = WGC_AllDataFactory.createUser(1,true).get(0);
        WGC_AllDataFactory.createLinkLegalEntity(15,true);
        
        
        Test.setMock(HttpCalloutMock.class, new WGC_HttpRequestController_MockImpl());
        Test.startTest();
        WGC_Account_Utility_Controller.getLegalEntities('107499','881');
        Test.stopTest();
    }
    @isTest
    public static void Test_getBilancioRibes(){
        
        WGC_AllDataFactory.createUtenzaDefault();
        WGC_AllDataFactory.creaImpServ();
        WGC_AllDataFactory.createLagKey();
        List<Account> listAcc = WGC_AllDataFactory.createAccount(2,true);
        // listAcc.get(0).CF__c= null;
        // listAcc.get(0).PIVA__c= null;
        // update listAcc;
        
        User u = WGC_AllDataFactory.createUser(1,true).get(0);
        WGC_AllDataFactory.createLinkLegalEntity(15,true);
        
        Test.setMock(HttpCalloutMock.class, new WGC_HttpRequestController_MockImpl());
        Test.startTest();
        WGC_Account_Utility_Controller.getBilancioRibes(listAcc.get(1).Id,'Civilistico');
        WGC_Account_Utility_Controller.getBilancioRibes(listAcc.get(0).Id,'Controllante');
        WGC_Account_Utility_Controller.getBilancioRibes(listAcc.get(0).Id,'Civilistico');
        Test.stopTest();

        listAcc.get(0).CF__c= null;
        listAcc.get(0).PIVA__c= null;
        update listAcc;
    }
    @isTest
    public static void Test_checkRinnovoAvailable(){
        WGC_AllDataFactory.createUtenzaDefault();
        WGC_AllDataFactory.creaImpServ();
        WGC_AllDataFactory.createLagKey();
        List<Account> listAcc = WGC_AllDataFactory.createAccount(1,true);

        Test.startTest();
        WGC_Account_Utility_Controller.checkRinnovoAvailable(listAcc.get(0).Id);
        Test.stopTest();
    }

	@isTest
    public static void Test_getPDF_EventiNegativi(){
        WGC_AllDataFactory.createUtenzaDefault();
        WGC_AllDataFactory.creaImpServ();
        WGC_AllDataFactory.createLagKey();
        List<Account> listAcc = WGC_AllDataFactory.createAccount(1,true);

        Test.startTest();
        WGC_Account_Utility_Controller.getPDF_EventiNegativi(listAcc.get(0).Id);
        Test.stopTest();
    }

	

}