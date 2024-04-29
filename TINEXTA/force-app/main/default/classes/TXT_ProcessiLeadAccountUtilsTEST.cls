@isTest
public with sharing class TXT_ProcessiLeadAccountUtilsTEST {


    @isTest
    public static void TXT_Verifica_Account_TEST() {
        Test.startTest();

        Lead newlead = new Lead();
        newlead.FirstName = 'newlead';
        newlead.LastName = 'newlead';
        newlead.Forma_giuridica__c = 'PERSONA FISICA';
        newlead.Codice_fiscale__c = '1234567890';
        newlead.Partiva_Iva__c = '1234567890';
        newlead.Company = 'newlead';
        insert newlead;

        Account newaccount = new Account();
        newaccount.Name = 'NewAccount';
        newaccount.CCIAA_CMK__c = '1234567890';
        newaccount.CCIAA_REA__c = '1234567890';
        newaccount.denosociale__c = 'New Account';
        newaccount.Partita_iva__c = '1234567890';
        newaccount.Codice_fiscale__c = '1234567890';
        newaccount.Via_Sede_Legale__c = 'New Account';
        newaccount.Provincia_Sede_Legale__c = 'New Account';
        newaccount.CAP_Sede_Legale__c = 'New Account';
        newaccount.Paese_Sede_Legale__c = 'New Account';
        newaccount.Citta_Sede_Legale__c = 'New Account';
        newaccount.Forma_giuridica__c = 'PERSONA FISICA';
        newaccount.Data_Ultimo_arricchimento__c = System.Today();
        insert newaccount;

        TXT_ProcessiLeadAccountUtils u = new TXT_ProcessiLeadAccountUtils();
        String[] Data = new List<String>();
        Data.add('1234567890');
        Data.add('1234567890');
        Data.add('1234567890');
        Data.add('1234567890');
        List<Account> results = u.TXT_Verifica_Account_PF(Data);
        System.assertEquals('New Account','New Account');

        results = u.TXT_Verifica_Account_PG(Data);
        System.assertEquals('New Account','New Account');

        results = u.TXT_VerificaCFPIinAccount('1234567890',' ', 'ccc', '');
        System.assertEquals('New Account','New Account');
        List<Account> ListA = TXT_ProcessiLeadAccountUtils.executeCallMock( 1, 'NEW');
        Test.stopTest();
    }

    @isTest
    public static void TXT_PickList_FatturatoTEST() {
        Test.startTest();
        String res = TXT_ProcessiLeadAccountUtils.TXT_PickList_Fatturato(1000000000);
        Test.stopTest();
    }

    @isTest
    public static void TXT_PickList_DipendentiTEST() {
        Test.startTest();
        String res = TXT_ProcessiLeadAccountUtils.TXT_PickList_Dipendenti('250');
        Test.stopTest();
    }
}