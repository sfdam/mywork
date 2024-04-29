@isTest
private class RestResourceTest {
    @TestSetup
    static void setupData() {
        Funzionalita__c f = Funzionalita__c.getInstance();
        f.DisabilitaControlloCambioFaseOpp__c = true;
        
        upsert f;
        
        insert new EndpointServizi__c(
            Name = 'settings',
            LAGKey__c = 'x',
            URLGetBilancioSinteticoRibes__c = 'https://a.com',
            UrlSearchDocument__c = 'https://b.com',
            WGC_Url_Dati_PEF__c = 'https://uatservices.bancaifis.it/arch/lag/proxy/pratica/lineacredito/datipef'
        );
    }
    
    @isTest
    static void testAnagrafeCrm() {
        Account[] accs = [SELECT Id FROM Account];
        System.assert(accs.isEmpty());
        
        RestAnagrafeCrm.DatiAnagraficiCedacriGlobal d = (RestAnagrafeCrm.DatiAnagraficiCedacriGlobal)JSON.deserialize(TestMockUtils.PAYLOAD_REST_ANAGRAFECRM, RestAnagrafeCrm.DatiAnagraficiCedacriGlobal.class);
        RestCommon.ResponseObject response = RestAnagrafeCrm.updateNdg(null, d);
        System.assert(response.returnCode == RestCommon.NESSUN_ERRORE);
        
        accs = [SELECT Id FROM Account];
        System.assert(accs.isEmpty());
    }
    
    @isTest
    static void testStatoOpportunita() {
        //TODO FIX IT
        RestStatoOpportunita.UpdateCartellaInputPayload payload = new RestStatoOpportunita.UpdateCartellaInputPayload();
        payload.cartella = (RestStatoOpportunita.Cartella)JSON.deserialize(TestMockUtils.PAYLOAD_REST_STATOOPPORTUNITA_CARTELLA, RestStatoOpportunita.Cartella.class);
        RestStatoOpportunita.Linea[] t = new list<RestStatoOpportunita.Linea>();
        payload.linee = (RestStatoOpportunita.Linea[]) JSON.deserialize(TestMockUtils.PAYLOAD_REST_STATOOPPORTUNITA_LINEE, list<RestStatoOpportunita.Linea>.class);
        payload.codPratica = 123456;
        payload.cartella.esito = RestStatoOpportunita.NON_DELIBERATA_PERSA;
        system.debug('ccccccccc '+payload.linee);
        system.debug('ccccccccc '+payload.cartella);
        system.debug('ccccccccc '+payload.codPratica);
        //payload.linee = t;
        
        //RestCommon.ResponseObject response = RestStatoOpportunita.updateCartella(null, null, null, c, l);
        // System.assert(response.returnCode == RestCommon.ID_CARTELLA_ASSENTE);
        RestCommon.ResponseObject response = RestStatoOpportunita.updateCartella(null, payload);
        
        Account a = TestUtils.creaAccount('test');
        a.CodiceIstituto3N__c = '123';
        update a;
        Opportunity opp = TestUtils.CreaOpportunity(a);
        opp.WGC_Codice_Pratica__c = 123456; 
        opp.IdCartella__c = '123456';
        update opp;
        
        //response = RestStatoOpportunita.updateCartella(null, null, null, c, l);
        //System.assert(response.returnCode == RestCommon.ID_LINEA_ASSENTE);
        response = RestStatoOpportunita.updateCartella(null, payload);
        
        Funzionalita__c f = Funzionalita__c.getInstance();
        f.DisabilitaTriggers__c= true;
        update f;
        TestUtils.creaLinee(opp, 3);
        // System.debug('IDDDDD'+[SELECT IdProdotto__c  FROM Linea__c WHERE Opportunity__c = :opp.Id][0].IdProdotto__c);
        payload.linee[0].Id = [SELECT Id, IdProdotto__c  FROM Linea__c WHERE Opportunity__c = :opp.Id][0].IdProdotto__c;
        payload.linee[1].Id = [SELECT Id, IdProdotto__c  FROM Linea__c WHERE Opportunity__c = :opp.Id][1].IdProdotto__c;
        //response = RestStatoOpportunita.updateCartella(null, null, null, c, l);
        payload.cartella.esito = RestStatoOpportunita.PEF_DELIBERATA;
        response = RestStatoOpportunita.updateCartella(null, payload);
        // System.assertEquals(RestCommon.NESSUN_ERRORE, response.returnCode);
        RestStatoOpportunita.checkAllLinesDeclined(opp.id);
    }
        @isTest
    static void testStatoOpportunita2() {
        //TODO FIX IT
        RestStatoOpportunita.UpdateCartellaInputPayload payload = new RestStatoOpportunita.UpdateCartellaInputPayload();
        payload.cartella = (RestStatoOpportunita.Cartella)JSON.deserialize(TestMockUtils.PAYLOAD_REST_STATOOPPORTUNITA_CARTELLA, RestStatoOpportunita.Cartella.class);
        RestStatoOpportunita.Linea[] t = new list<RestStatoOpportunita.Linea>();
        payload.linee = (RestStatoOpportunita.Linea[]) JSON.deserialize(TestMockUtils.PAYLOAD_REST_STATOOPPORTUNITA_LINEE, list<RestStatoOpportunita.Linea>.class);
        payload.codPratica = 123456;
        system.debug('ccccccccc '+payload.linee);
        system.debug('ccccccccc '+payload.cartella);
        system.debug('ccccccccc '+payload.codPratica);
        payload.cartella.idCartella = '';
        //payload.linee = t;
        
        //RestCommon.ResponseObject response = RestStatoOpportunita.updateCartella(null, null, null, c, l);
        // System.assert(response.returnCode == RestCommon.ID_CARTELLA_ASSENTE);
        RestCommon.ResponseObject response = RestStatoOpportunita.updateCartella(null, payload);
        
        Account a = TestUtils.creaAccount('test');
        a.CodiceIstituto3N__c = '123';
        update a;
        Opportunity opp = TestUtils.CreaOpportunity(a);
        opp.WGC_Codice_Pratica__c = 123456; 
        opp.IdCartella__c = '123456';
        update opp;
        
        //response = RestStatoOpportunita.updateCartella(null, null, null, c, l);
        //System.assert(response.returnCode == RestCommon.ID_LINEA_ASSENTE);
        response = RestStatoOpportunita.updateCartella(null, payload);
        
        Funzionalita__c f = Funzionalita__c.getInstance();
        f.DisabilitaTriggers__c= true;
        update f;
        TestUtils.creaLinee(opp, 3);
        // System.debug('IDDDDD'+[SELECT IdProdotto__c  FROM Linea__c WHERE Opportunity__c = :opp.Id][0].IdProdotto__c);
        payload.linee[0].Id = [SELECT Id, IdProdotto__c  FROM Linea__c WHERE Opportunity__c = :opp.Id][0].IdProdotto__c;
        payload.linee[1].Id = [SELECT Id, IdProdotto__c  FROM Linea__c WHERE Opportunity__c = :opp.Id][1].IdProdotto__c;
        //response = RestStatoOpportunita.updateCartella(null, null, null, c, l);
        response = RestStatoOpportunita.updateCartella(null, payload);
        // System.assertEquals(RestCommon.NESSUN_ERRORE, response.returnCode);
    }
}