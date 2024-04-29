@isTest
public with sharing class WsAnagraficaBeanTest {
    
    @testSetup
    static void dataSetup() {
        User dora = TestUtils.creaUtente('dora');
        TestUtils.impostaCS();
        
        Account a = TestUtils.creaAccount('A', dora);
        // Contact c = TestUtils.creaReferente(a);
        Contact c = WGC_AllDataFactory.createContact(1).get(0);
        c.CodiceIstituto3N__c= '881';
        c.AccountId =a.Id;
        c.FirstName = 'Referente';
        insert c;
        Account accountCompleto = TestUtils.creaAccount('AccountCompleto', 'MI', '02213390343', 'rsscld50r15h501y');
        TestUtils.creaEndpointServizi();
        
        System.runAs(dora) {
            Funzionalita__c f = Funzionalita__c.getInstance();
            f.DisabilitaNamingAutomaticaOpportunita__c = true;
            upsert f;
        }
    }
    
    @isTest
    static void test_getEntity() {
        Account a = [SELECT Id, Name, NaturaGiuridica__c FROM Account WHERE Name = 'A'];
        SObject res = WsAnagraficaBean.getEntity(a.Id);
        system.assertNotEquals(null, res);
    }
    
    @istest
    static void test_fillFrom() {
        WsAnagraficaBean b = new WsAnagraficaBean();
        Account a = [SELECT Id, Name, NaturaGiuridica__c FROM Account WHERE Name = 'A' LIMIT 1];
        a.NDGGruppo__c = '3270';
        a.CF__c = 'rsscld50r15h501y';
        a.WGC_Emissioni_di_Azioni_al_Portatore_PNF__c = true;
        a.WGC_Partecipazione_Trust__c = 'AFGHANISTAN';
        a.WGC_Assetti_Attivita_Svolta__c = true;
        a.WGC_Partecipazione_societa_fiduciarie__c = '00';
        update a;  
        Contact c = [ SELECT Id, Name FROM Contact WHERE FirstName = 'Referente' LIMIT 1];
        c.NDGGruppo__c = '3271';
        c.CF__c = 'rsscld50r15h501y';
        c.IsReferenteCampagna__c = false;
        update c;
       
        
        //test con sorgente Account
        b.fillFrom(a);
        //test con sorgente Contact
        
        b.fillFrom(c);
    }
    
    @istest
    static void test_toJSON(){
        WsAnagraficaBean b = new WsAnagraficaBean();
        String ser = b.toJSON('WTVariazione');
    }
}