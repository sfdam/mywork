@isTest
public class WGC_Test_ModuloTecnicheComunicazione {

    @isTest
    public static void Test_getAccountData(){
        //Creo i dati di test
        WGC_AllDataFactory.createUtenzaDefault();
        WGC_AllDataFactory.createAccount(1,true);
        /*Integer rand = Integer.valueOf(Math.Random());
        Account acc1 = new Account(IndirizzoPerInvioCorrispondenza__c=);
        acc.Name = 'TestAccount'+rand;

        insert acc;*/

        List<Account> accId = [SELECT Id, Name FROM Account ];

        Test.startTest();
        Account resp1 = WGC_ModuloTecnicheComunicazione.getAccountData(accId.get(0).Id);
        Test.stopTest();
    }

    @isTest
    public static void Test_SaveRecord(){
        //Creo i dati di test
        WGC_AllDataFactory.createUtenzaDefault();
        List<Account> listAcc = WGC_AllDataFactory.createAccount(2,true);
        listAcc.get(0).IndirizzoPerInvioCorrispondenza__c = 'Sede legale';
        listAcc.get(1).IndirizzoPerInvioCorrispondenza__c = 'Sede amministrativa';
        update listAcc;
        /*Integer rand = Integer.valueOf(Math.Random());
        Account acc = new Account();
        acc.Name = 'TestAccount'+rand;

        insert acc;*/
        List<Account> lista = [SELECT Id, Name, IndirizzoPerInvioCorrispondenza__c FROM Account];
        //Account accTest = [SELECT Id, Name FROM Account LIMIT 1];
        //String accId = accTest.Id;
        String accTestStr0 = JSON.serialize(lista.get(0));
        String accTestStr1 = JSON.serialize(lista.get(1));
        //String accTestStr2 = JSON.serialize(lista.get(2));

        AdeguataVerifica__c mav = new AdeguataVerifica__c();
        String mavTestString = JSON.serialize(mav);

        Test.startTest();

        WGC_ModuloTecnicheComunicazione.SaveRecord(lista.get(0).Id, mavTestString, accTestStr0);
        WGC_ModuloTecnicheComunicazione.SaveRecord(lista.get(1).Id, mavTestString, accTestStr1);
        //WGC_ModuloTecnicheComunicazione.SaveRecord(lista.get(2).Id, mavTestString, accTestStr2);

        Test.stopTest();

        
    }

    @isTest
    public static void test_getMAV(){
        WGC_AllDataFactory.createUtenzaDefault();
        List<AdeguataVerifica__c> listAV = WGC_AllDataFactory.createAdeguataVerifica(2,false);
        List<Contact> listCont = WGC_AllDataFactory.createContact(1,true);
        Account a = [SELECT Id, Name FROM Account LIMIT 1];
        
        AdeguataVerifica__c mav = new AdeguataVerifica__c(Account__c= a.Id);        
        insert mav;

        Test.startTest();
        WGC_ModuloTecnicheComunicazione.getMAV(a.id);
        Test.stopTest();
    }
}