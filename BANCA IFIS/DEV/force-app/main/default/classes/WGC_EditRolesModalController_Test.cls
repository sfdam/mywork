@isTest
public with sharing class WGC_EditRolesModalController_Test {
    
    
    @isTest
    public static void test_getInformationContact(){
        WGC_AllDataFactory.disattivaTrigger();
        List<Account> listAcc = WGC_AllDataFactory.createAccount(3,true);
        List<Contact> listCon = WGC_AllDataFactory.createContact(3,true);
        Test.startTest();
        WGC_EditRolesModalController.getInformationContact(listCon[0].Id,listAcc[0].Id);
        Test.stopTest();
    }

    @isTest
    public static void test_getInformationContact_catch(){
        WGC_AllDataFactory.disattivaTrigger();
        List<Account> listAcc = WGC_AllDataFactory.createAccount(3,true);
        Test.startTest();
        WGC_EditRolesModalController.getInformationContact('111',listAcc[0].Id);
        Test.stopTest();
    }

    @isTest
    public static void test_updateRole(){
        WGC_AllDataFactory.createUtenzaDefault();
        WGC_AllDataFactory.createLagKey();
        WGC_AllDataFactory.creaImpServ();
        Account a = WGC_AllDataFactory.createAccount(1,false).get(0);
        a.NDGGruppo__c='4195084';
        insert a;
        Contact c =WGC_AllDataFactory.createContact(1).get(0);
        a = [SELECT Id,NDGGruppo__c FROM Account LIMIT 1];
        c.AccountId=a.Id;
        c.NDGGruppo__c=a.NDGGruppo__c;
        // System.debug('NDG ACC: '+a.NDGGruppo__c);
        insert c;
        List<String> listaruoli = new List<String>();
        listaruoli.add('J');
        listaruoli.add('J1');
        listaruoli.add('Z1');



        System.debug('Query: '+[ SELECT Id, Label, Valore_Target__c, Valore__c FROM WGC_Dominio_Collegamenti_PF__mdt ]);
        Test.setMock(HttpCalloutMock.class, new WGC_HttpRequestController_MockImpl());

        // Da errore sulla chiamata messa nel debug qui sotto
        // System.debug('@Test response: '+WsAnagrafe.gestioneCollNdg(a.NDGGruppo__c));
        Test.startTest();
        WGC_EditRolesModalController.WrapperResponse resp = WGC_EditRolesModalController.updateRole(a.Id,c.Id,listaRuoli);
        System.debug('Resp: '+resp.msg);
        Test.stopTest();
    }

    @isTest
    public static void test_getOriginAccount(){
        WGC_AllDataFactory.createUtenzaDefault();
        WGC_AllDataFactory.createLagKey();
        WGC_AllDataFactory.creaImpServ();
        Account a = WGC_AllDataFactory.createAccount(1,true).get(0);
        Test.startTest();
        WGC_EditRolesModalController.getOriginAccount(a.Id);
        Test.stopTest();

    }


    @isTest
    public static void test_getCompatibleRoles(){
        WGC_AllDataFactory.createUtenzaDefault();
        WGC_AllDataFactory.createLagKey();
        WGC_AllDataFactory.creaImpServ();
        Account a = WGC_AllDataFactory.createAccount(1,true).get(0);
        Test.startTest();
        WGC_EditRolesModalController.getCompatibleRoles('ER');
        Test.stopTest();

    }

}