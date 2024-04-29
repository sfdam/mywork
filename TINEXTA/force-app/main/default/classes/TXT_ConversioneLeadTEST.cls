@isTest
public with sharing class TXT_ConversioneLeadTEST {

    @isTest
    public static void TXT_ConversioneLeadTEST() {
        Test.startTest();

        Lead newlead = new Lead();
        newlead.FirstName = 'newlead';
        newlead.LastName = 'newlead';
        newlead.Forma_giuridica__c = 'PERSONA FISICA';
        newlead.Codice_fiscale__c = '1234567890';
        newlead.Partiva_Iva__c = '1234567890';
        newlead.Company = 'newlead';
        newlead.Data_Ultimo_Arricchimento__c = System.today();
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
        newaccount.Data_Ultimo_Arricchimento__c = System.today();
        insert newaccount;

        List<Account> ListA = TXT_ProcessiLeadAccountUtils.executeCallMock( 1, 'NEW');
        Account result = TXT_ConversioneLead.TXT_RecapInfo(newlead.Id,ListA[0], null);
        Account result2 = TXT_ConversioneLead.TXT_RecapInfo(null,ListA[0], null);
        //System.assertEquals(result.denosociale__c,'New Account');

        

        Test.stopTest();
    }

    @isTest
    public static void TXT_UpdateLeadTEST() {
        Test.startTest();

        Lead newlead = new Lead();
        newlead.FirstName = 'newlead';
        newlead.LastName = 'newlead';
        newlead.Forma_giuridica__c = 'PERSONA FISICA';
        newlead.Codice_fiscale__c = '1234567890';
        newlead.Partiva_Iva__c = '1234567890';
        newlead.CCIAA_CMK__c = '1234567890';
        newlead.CCIAA_REA_Innolva__c = '1234567890';
        newlead.Via_Sede_Operativa_Innolva__c = 'New Lead';
        newlead.Provincia_Sede_Operativa_Innolva__c = 'New Lead';
        newlead.CAP_Sede_Operativa_Innolva__c = 'New Lead';
        newlead.Paese_Sede_Operativa_Innolva__c = 'New Lead';
        newlead.Citta_Sede_Operativa_Innolva__c = 'New Lead';
        newlead.Company = 'newlead';
        newlead.Data_Ultimo_Arricchimento__c = System.today();
        insert newlead;

        List<Account> ListA = TXT_ProcessiLeadAccountUtils.executeCallMock( 1, 'NEW');
        Lead result = TXT_ConversioneLead.TXT_UpdateLead(newlead.Id,ListA[0], true);
        System.assertEquals(result.Codice_fiscale__c,'1234567890');

        

        Test.stopTest();
    }

    @isTest
    public static void TXT_RetriveDataLeadTEST() {
        Test.startTest();

        Lead newlead = new Lead();
        newlead.FirstName = 'newlead';
        newlead.LastName = 'newlead';
        newlead.Forma_giuridica__c = 'PERSONA FISICA';
        newlead.Codice_fiscale__c = '1234567890';
        newlead.Partiva_Iva__c = '1234567890';
        newlead.CCIAA_CMK__c = '1234567890';
        newlead.CCIAA_REA_Innolva__c = '1234567890';
        newlead.Via_Sede_Operativa_Innolva__c = 'New Lead';
        newlead.Provincia_Sede_Operativa_Innolva__c = 'New Lead';
        newlead.CAP_Sede_Operativa_Innolva__c = 'New Lead';
        newlead.Paese_Sede_Operativa_Innolva__c = 'New Lead';
        newlead.Citta_Sede_Operativa_Innolva__c = 'New Lead';
        newlead.Company = 'newlead';
        newlead.Data_Ultimo_Arricchimento__c = System.today();
        insert newlead;


        Lead result = TXT_ConversioneLead.TXT_RetriveDataLead(newlead.Id);
        System.assertEquals(result.Codice_fiscale__c,'1234567890');

        

        Test.stopTest();
    }

    @isTest
    public static void TXT_ProcessoDiConversioneTEST() {
        Test.startTest();

        Lead newlead = new Lead();
        newlead.FirstName = 'new lead';
        newlead.LastName = 'new lead';
        newlead.Email = 'x@x.it';
        newlead.Forma_giuridica__c = 'PERSONA FISICA';
        newlead.Codice_fiscale__c = '1234567890';
        newlead.Partiva_Iva__c = '1234567890';
        newlead.Company = 'new lead';
        newlead.Data_Ultimo_Arricchimento__c = System.today();
        insert newlead;
        /*
        Id Lid, Id Id, String ACName,
    String Forma_giuridica, 
    String Natura_Giuridica,
    String CCIAA_CMK,
    String CCIAA_REA,
    String denosociale,
    String Partita_iva,
    String Codice_fiscale,
    String Via_Sede_Legale,
    String Provincia_Sede_Legale,
    String CAP_Sede_Legale,
    String Paese_Sede_Legale,
    String Citta_Sede_Legale,
    Boolean Censimento_Manuale,
    String Fatturato,
    String Dipendenti,
    String convertStatus,
    Boolean Opportnunity
    */
        Account result = TXT_ConversioneLead.TXT_ProcessoDiConversione(newlead.Id, newlead.Id, 
        'NewAccount',
        'PERSONA FISICA',
        'PERSONA FISICA',
        '1234567890',
        '1234567890', 
        'New Account', 
        '1234567890', 
        '1234567890', 
        'New Account', 
        'New Account', 
        '20142', 
        'New Account', 
        'New Account',
        true,
        '12344',
        '13',
        'Convertito',
        true);

        TXT_ConversioneLead.handleCTM(result.Id, newlead.Id);
        // System.assertEquals(result.denosociale__c,null);

        /*
        newlead = new Lead();
        newlead.FirstName = 'new   lead';
        newlead.LastName = 'new    lead';
        newlead.Forma_giuridica__c = 'PERSONA FISICA';
        newlead.Codice_fiscale__c = '1234567890';
        newlead.Partiva_Iva__c = '1234567890';
        newlead.Company = 'new   lead';
        insert newlead;

        Account newaccount = new Account();
        newaccount.Name = 'New  Account';
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
        insert newaccount;

        result = TXT_ConversioneLead.TXT_ProcessoDiConversione(newlead.Id, newaccount.Id,
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        null,
        true);
        System.assertEquals(result.denosociale__c,null);
        */
        Test.stopTest();
    }

    @isTest
    public static void TXT_ProcessoDiConversioneTEST2() {
        Test.startTest();
        Lead newlead = new Lead();
        newlead = new Lead();
        newlead.FirstName = 'new   lead';
        newlead.LastName = 'new    lead';
        newlead.Email = 'x@x.it';
        newlead.Forma_giuridica__c = 'PERSONA FISICA';
        newlead.Codice_fiscale__c = '1234567890';
        newlead.Partiva_Iva__c = '1234567890';
        newlead.Company = 'new   lead';
        newlead.Data_Ultimo_Arricchimento__c = System.Today();
        insert newlead;

        Account newaccount = new Account();
        newaccount.Name = 'New  Account';
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
        newaccount.Data_Ultimo_Arricchimento__c = System.Today();
        insert newaccount;

        // Account result = TXT_ConversioneLead.TXT_ProcessoDiConversione(newlead.Id, newaccount.Id,
        // '',
        // '',
        // '',
        // '',
        // '',
        // '',
        // '',
        // '',
        // '',
        // '',
        // '',
        // '',
        // '',
        // null,
        // true);
        // System.assertEquals(result.denosociale__c,null);
        
        Test.stopTest();
    }

    @isTest
    public static void TXT_ProcessoDiConversioneTEST3() {
        Test.startTest();

        Lead newlead = new Lead();
        newlead.FirstName = 'new lead';
        newlead.LastName = 'new lead';
        newlead.Email = 'x@x.it';
        newlead.Forma_giuridica__c = 'PERSONA FISICA';
        newlead.Codice_fiscale__c = '1234567890';
        newlead.Partiva_Iva__c = '1234567890';
        newlead.Company = 'new lead';
        newLead.Data_Ultimo_Arricchimento__c = System.Today();
        insert newlead;
        /*
        Id Lid, Id Id, String ACName,
    String Forma_giuridica, 
    String Natura_Giuridica,
    String CCIAA_CMK,
    String CCIAA_REA,
    String denosociale,
    String Partita_iva,
    String Codice_fiscale,
    String Via_Sede_Legale,
    String Provincia_Sede_Legale,
    String CAP_Sede_Legale,
    String Paese_Sede_Legale,
    String Citta_Sede_Legale,
    Boolean Censimento_Manuale,
    String Fatturato,
    String Dipendenti,
    String convertStatus,
    Boolean Opportnunity
    */
        Id result = TXT_ConversioneLead.TXT_UpdateLeadBeforeConversion(newlead.Id, newlead.Id, 
        'NewAccount',
        'PERSONA FISICA',
        'PERSONA FISICA',
        '1234567890',
        '1234567890', 
        'New Account', 
        '1234567890', 
        '1234567890', 
        'New Account', 
        'New Account', 
        '20142', 
        'New Account', 
        'New Account',
        true,
        '12344',
        '13',
        '1',
        'NewAccount',
        'Convertito',
        true,
        false);
        // System.assertEquals(result.denosociale__c,null);

        /*
        newlead = new Lead();
        newlead.FirstName = 'new   lead';
        newlead.LastName = 'new    lead';
        newlead.Forma_giuridica__c = 'PERSONA FISICA';
        newlead.Codice_fiscale__c = '1234567890';
        newlead.Partiva_Iva__c = '1234567890';
        newlead.Company = 'new   lead';
        insert newlead;

        Account newaccount = new Account();
        newaccount.Name = 'New  Account';
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
        insert newaccount;

        result = TXT_ConversioneLead.TXT_ProcessoDiConversione(newlead.Id, newaccount.Id,
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        null,
        true);
        System.assertEquals(result.denosociale__c,null);
        */
        Test.stopTest();
    }
    
    @isTest
    public static void coverProcess()
    {
        
        string s = '';
        for(decimal i = 0; i <= 100000000; i += 600000)
        {
            
            s = TXT_ProcessiLeadAccountUtils.TXT_PickList_Fatturato(i);
            
        }
        //s = TXT_ProcessiLeadAccountUtils.TXT_PickList_Fatturato(100000000);
    }

}