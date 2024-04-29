@isTest
public with sharing class WGC_EditContact_Test {
    @isTest
    public static void Test_saveContact_NDG_null(){
        WGC_AllDataFactory.disattivaTrigger();
        WGC_AllDataFactory.createLagKey();
        WGC_AllDataFactory.creaImpServ();
        Contact c = new Contact(CodCatastaleLocNascita__c='A132', FirstName='SILVANO', LuogoEmissioneDoc__c='ALBANO LAZIALE', DataEmissioneDoc__c= Date.newInstance(2009,05,21), DataScadenzaDoc__c=Date.newInstance(2029,05,21), Birthdate=Date.newInstance(1956,01,06), CI3N_CF__c='881-NTNSVN56A06A132N', TipoDocumentoId__c='1', LuogoNascita__c='ALBANO LAZIALE', CF__c='NTNSVN56A06A132N', CodiceIstituto3N__c='881', EnteEmitettenteDocumento__c='ALBANO LAZIALE', TAECode__c='984', Sesso__c='M', LastName='ANTONIETTI', SAE__c='600', NumeroDoc__c='AZ1029283', MailingCity	= 'A', MailingCountry = 'A', MailingPostalCode = 'A', MailingState = 'A', MailingStreetName__c = 'A', MailingStreetNumber__c = 'A', MailingStreetType__c = 'ALZ.', ProvinciaNascita__c='RM');
        c.NDGGruppo__c = null;
        insert c;
        //String s = JSON.serialize(c);
        Test.setMock(HttpCalloutMock.class, new WGC_HttpRequestController_MockImpl());
        Test.startTest();
        WGC_EditContact.loadLayout(c.Id);
        WGC_EditContact.saveContact(c);
        Test.stopTest();
    }
    @isTest
    public static void test_saveContact_NDG(){
        WGC_AllDataFactory.disattivaTrigger();
        WGC_AllDataFactory.createLagKey();
        WGC_AllDataFactory.creaImpServ();
        
        Contact c = new Contact(CodCatastaleLocNascita__c='A132', NDGGruppo__c= '107499', FirstName='SILVANO', LuogoEmissioneDoc__c='ALBANO LAZIALE', DataEmissioneDoc__c= Date.newInstance(2009,05,21), DataScadenzaDoc__c=Date.newInstance(2029,05,21), Birthdate=Date.newInstance(1956,01,06), CI3N_CF__c='881-NTNSVN56A06A132N', TipoDocumentoId__c='1', LuogoNascita__c='ALBANO LAZIALE', CF__c='NTNSVN56A06A132N', CodiceIstituto3N__c='881', EnteEmitettenteDocumento__c='ALBANO LAZIALE', TAECode__c='984', Sesso__c='M', LastName='ANTONIETTI', SAE__c='600', NumeroDoc__c='AZ1029283');
        Test.setMock(HttpCalloutMock.class, new WGC_HttpRequestController_MockImpl());
        Test.startTest();
        WGC_EditContact.saveContact(c);
        Test.stopTest();
    }

    @isTest
    public static void test_saveContact_catch(){
        WGC_AllDataFactory.disattivaTrigger();
        
        
        Contact c = new Contact(CodCatastaleLocNascita__c='A132', NDGGruppo__c= '107499', FirstName='SILVANO', LuogoEmissioneDoc__c='ALBANO LAZIALE', DataEmissioneDoc__c= Date.newInstance(2009,05,21), DataScadenzaDoc__c=Date.newInstance(2029,05,21), Birthdate=Date.newInstance(1956,01,06), CI3N_CF__c='881-NTNSVN56A06A132N', TipoDocumentoId__c='1', LuogoNascita__c='ALBANO LAZIALE', CF__c='NTNSVN56A06A132N', CodiceIstituto3N__c='881', EnteEmitettenteDocumento__c='ALBANO LAZIALE', TAECode__c='984', Sesso__c='M', LastName='ANTONIETTI', SAE__c='600', NumeroDoc__c='AZ1029283');
        Test.setMock(HttpCalloutMock.class, new WGC_HttpRequestController_MockImpl());
        Test.startTest();
        WGC_EditContact.saveContact(c);
        Test.stopTest();
    }

    @isTest
    public static void test_saveContactOnlyCRM(){
        WGC_AllDataFactory.createUtenzaDefault();
        WGC_AllDataFactory.createLagKey();
        WGC_AllDataFactory.creaImpServ();
        
        Contact c = new Contact(CodCatastaleLocNascita__c='A132', FirstName='SILVANO', LuogoEmissioneDoc__c='ALBANO LAZIALE', DataEmissioneDoc__c= Date.newInstance(2009,05,21), DataScadenzaDoc__c=Date.newInstance(2029,05,21), Birthdate=Date.newInstance(1956,01,06), CI3N_CF__c='881-NTNSVN56A06A132N', TipoDocumentoId__c='1', LuogoNascita__c='ALBANO LAZIALE', CF__c='NTNSVN56A06A132N', CodiceIstituto3N__c='881', EnteEmitettenteDocumento__c='ALBANO LAZIALE', TAECode__c='984', Sesso__c='M', LastName='ANTONIETTI', SAE__c='600', NumeroDoc__c='AZ1029283');
        Test.startTest();
        WGC_EditContact.saveContactOnlyCRM(c);
        Test.stopTest();
    }
}