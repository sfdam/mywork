/**
* Progetto:         Banca IFIS
* Sviluppata il:    10/02/2017
* Developer:        Giuliani Luigi
*/
@isTest
private class CtrlWizardOpportunityTest
{
    
    @testSetup
    static void dataSetup() {
        Funzionalita__c f = Funzionalita__c.getInstance();
        f.DisabilitaNamingAutomaticaOpportunita__c = true;
        upsert f;
        
        User dora = TestUtils.creaUtente('dora');
        TestUtils.impostaCS();
        TestUtils.creaImpostazioni();
        TestUtils.creaEndpointServizi();
        
        Account a = TestUtils.creaAccount('A', dora, 'MI', '12345678909', 'MRAMTT78A01F205A' , 'Cliente' , 'DI');
        
        
        Contact c = TestUtils.creaReferente(a);
        
        
        /*
        c.NDGGruppo__c = 'DI';
        c.CF__c = 'MRAMTT78A01F205A';
        c.Birthdate = Date.newInstance(1980,01,01);
        c.Sesso__c = 'M';
        c.LuogoNascita__c = 'milano';
		*/
        update c;
        Opportunity o = TestUtils.CreaOpportunity(a, '01');
        NDGLinea__c ndg = TestUtils.CreaNGDLineaTitolare(c, o, false);
        NDGLinea__c ndgDeb = TestUtils.CreaNDGLineaDebitore(c, o);
        
        NDGLinea__c ndg2 = TestUtils.CreaNGDLineaTitolare(c, o, true);
        Prodotto__c prod1 = TestUtils.creaProdotto('Mutuo', '963', K.CODPROD_MUTUO, 'Prodotto bancario', '');
        Prodotto__c prod2 = TestUtils.creaProdotto('Fido di cassa', '', K.CODPROD_FIDO, 'Prodotto di supporto', '');
        Prodotto__c prod3= TestUtils.creaProdotto('Con proroga', '', K.CODPROD_CON_PROROGA, 'Factoring indiretto', 'Factoring');
        Prodotto__c prod4 = TestUtils.creaProdotto('IFIS Impresa', '151', K.CODPROD_IFIS_IMPRESA, 'Prodotto bancario', '');
        Prodotto__c prod5 = TestUtils.creaProdotto('IFIS Impresa Non Affidato', '222', K.CODPROD_IFIS_IMPRESA_NON_AFFIDATO, 'Prodotto bancario', '');
        
        AdeguataVerifica__c adv = new AdeguataVerifica__c ( Opportunita__c = o.id, CorrispondenzaCity__c = 'test', ScopoFD11__c = TRUE, ScopoFD12__c = FALSE, ScopoFD13__c = TRUE, ScopoFD14__c = FALSE, ScopoFD15__c = TRUE, ScopoFD16__c = TRUE, ScopoFD17__c= TRUE);
        insert adv;
        Map<String, SObject> types = U.getRecordTypes('Linea__c');
        List<Linea__c> linee = new List<Linea__c>();
        
        linee.add( new Linea__c(RecordTypeId = types.get('Fido').Id, Opportunity__c = o.id, FinalitaMutuo__c='test', Importo__c=1000, QuotaProSoluto__c = 100, DurataMaxCredito__c = 50, Prodotto__c = prod1.Id) );
        linee.add( new Linea__c(RecordTypeId = types.get('Fido').Id, Opportunity__c = o.id, Importo__c=1000, QuotaProSoluto__c = 100, DurataMaxCredito__c = 50, Prodotto__c = prod2.Id) );
        linee.add( new Linea__c(RecordTypeId = types.get('FactInd').Id, Opportunity__c = o.id, DurataDilazione__c=10, Importo__c=1000, QuotaProSoluto__c = 100, DurataMaxCredito__c = 50, Prodotto__c = prod3.Id) );
        linee.add( new Linea__c(RecordTypeId = types.get('Fido').Id, Opportunity__c = o.id, FinalitaMutuo__c='test', Importo__c=0, QuotaProSoluto__c = 100, DurataMaxCredito__c = 50, Prodotto__c = prod4.Id) );
        linee.add( new Linea__c(RecordTypeId = types.get('Corporate').Id, Opportunity__c = o.id, FinalitaMutuo__c='test', Importo__c=0, QuotaProSoluto__c = 100, DurataMaxCredito__c = 50, Prodotto__c = prod4.Id) );
        insert linee;
        
        Test.startTest();
        Opportunity o2 = TestUtils.CreaOpportunity(TestUtils.creaAccount('B',dora), '02');
        
        TestUtils.creaGaranzia(o, '666111');
        
        Linea__c lineaPerc = new Linea__c(Prodotto__c = prod1.Id, Opportunity__c = o.id, FinalitaMutuo__c='testPercentuale');
        Garanzia__c garanziaPerc = new Garanzia__c(CodiceGaranzia__c = 'GARFD', Opportunita__c = o.Id);
        insert lineaPerc;
        insert garanziaPerc;
        Test.stopTest();
    }
    
    @isTest
    static void testUpdatePrivacy()
    {
        Account a = [SELECT Id,
                     OwnerId,
                     ConsensoAllaProfilazione__c,
                     ConsensoAttivitaPromRicercheMercato__c,
                     ConsensoAttivitaPromozionaleTerzi__c,
                     ConsensoProdottiBancaRicercheMercato__c,
                     ConsensoProdottiSocietaTerze__c,
                     ConsensoSoloModalitaTradizionali__c,
                     DataInserimentoConsensi__c
                     FROM Account WHERE Name = 'A'];
        a.ConsensoAllaProfilazione__c = true;
        a.ConsensoAttivitaPromRicercheMercato__c = true;
        a.ConsensoSoloModalitaTradizionali__c = true;
        
        Opportunity o = [SELECT Id FROM Opportunity WHERE Name = '01'];
        CtrlWizardOpportunity.updatePrivacy(a, o.Id);
        a = [SELECT Id,
             OwnerId,
             ConsensoAllaProfilazione__c,
             ConsensoAttivitaPromRicercheMercato__c,
             ConsensoAttivitaPromozionaleTerzi__c,
             ConsensoProdottiBancaRicercheMercato__c,
             ConsensoProdottiSocietaTerze__c,
             ConsensoSoloModalitaTradizionali__c,
             DataInserimentoConsensi__c
             FROM Account WHERE Name = 'A'];
        System.assertEquals(true, a.ConsensoAllaProfilazione__c);
        System.assertEquals(true, a.ConsensoAttivitaPromRicercheMercato__c);
        System.assertEquals(false, a.ConsensoProdottiBancaRicercheMercato__c);
        System.assertEquals(false, a.ConsensoProdottiSocietaTerze__c);
        System.assertEquals(true, a.ConsensoSoloModalitaTradizionali__c);
    }
    
    @isTest
    static void testUpdateNoteIstruttoria()
    {
        Opportunity o = [SELECT Id,
                         OwnerId,
                         NoteStoricheAziendaeAttivitaSvolte__c,
                         ComposizioneDelCapitaleSociale__c,
                         NoteSuEsponentiManagementESoci__c,
                         ProgrammiEProspettiveFuture__c,
                         AnalisiDiBilancio__c,
                         RapportiBancariECR__c,
                         Approfondimenti__c,
                         DescrizioneOperazioneProposta__c,
                         Garanzie__c
                         FROM Opportunity WHERE Name = '01'];
        o.NoteStoricheAziendaeAttivitaSvolte__c = 'AAAA';
        o.NoteSuEsponentiManagementESoci__c = 'BBBB';
        o.RapportiBancariECR__c = 'CCCC';
        CtrlWizardOpportunity.updateNoteIstruttoria(o);
        o = [SELECT Id,
             OwnerId,
             NoteStoricheAziendaeAttivitaSvolte__c,
             ComposizioneDelCapitaleSociale__c,
             NoteSuEsponentiManagementESoci__c,
             ProgrammiEProspettiveFuture__c,
             AnalisiDiBilancio__c,
             RapportiBancariECR__c,
             Approfondimenti__c,
             DescrizioneOperazioneProposta__c,
             Garanzie__c
             FROM Opportunity WHERE Name = '01'];
        System.assertEquals('AAAA', o.NoteStoricheAziendaeAttivitaSvolte__c);
        System.assertEquals(null, o.ComposizioneDelCapitaleSociale__c);
        System.assertEquals('BBBB', o.NoteSuEsponentiManagementESoci__c);
        System.assertEquals(null, o.ProgrammiEProspettiveFuture__c);
        System.assertEquals('CCCC', o.RapportiBancariECR__c);
    }
    
    @isTest
    static void testEditFatca()
    {
        Opportunity opp = [SELECT id, Name FROM Opportunity WHERE Name = '01' LIMIT 1];
        List<NDGLinea__c> linee = CtrlWizardOpportunity.editFatca(opp.id);
        System.assertEquals(0, linee.size());
        linee = [SELECT Id FROM NDGLinea__c WHERE Opportunita__c = :opp.Id ];
        for(NDGLinea__c linea : linee){
            linea.ReferenteFatca__c = true;
        }
        update linee;
        linee = CtrlWizardOpportunity.editFatca(opp.id);
        System.assertEquals(3, linee.size());
    }
    
    @isTest
    static void testUpdateFatca()
    {
        Opportunity opp = [SELECT id, Name, AccountId FROM Opportunity WHERE Name = '01' LIMIT 1];
        List<Contact> contacts = [SELECT id, Name FROM Contact WHERE Account.Name = 'A'  LIMIT 1];
        Map<String, Object> payload = new Map<String, Object>();
        List<Map<String, Object>> referenti = new List<Map<String, Object>>();
        payload.put('referenti', referenti);
        Map<String, Object> tmpMap;
        for(Contact contatto : contacts) {
            tmpMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(contatto));
            tmpMap.put('Id' , contatto.Id);
            tmpMap.put('LastName' , 'AAAA');
            tmpMap.put('opportunityId' , opp.Id);
            tmpMap.put('Trust__c' , null);
            tmpMap.put('ValoriTrust__c' , null);
            tmpMap.put('TipoTrust__c' , null);
            tmpMap.put('ReferenteFatca__c' , true);
            tmpMap.put('Birthdate' , 0);
            referenti.add(tmpMap);
        }
        
        tmpMap = new Map<String, Object>();
        payload.put('infoAzienda', tmpMap);
        tmpMap.put('Id', opp.AccountId);
        tmpMap.put('RegimeTrasparenzaFiscale__c', 'No');
        tmpMap.put('USPerson__c', 'Si');
        tmpMap.put('SpecifiedUSPerson__c', 'Si');
        tmpMap.put('FiscalmenteResidenteSoloStatiUniti__c', 'No');
        tmpMap.put('IstituzioneFinanziaria__c', 'Si');
        tmpMap.put('ValoriFiscalmenteResidenteSoloUSA__c', null);
        tmpMap.put('ValoriActiveNFFEActiveNFE__c', null);
        tmpMap.put('AltroFiscalmenteResidenteSoloUSA__c', null);
        
        payload.put('opportunityId', opp.Id);
        
        List<NDGLinea__c> linee = CtrlWizardOpportunity.editFatca(opp.id);
        System.assertEquals(0, linee.size());
        
        CtrlWizardOpportunity.updateFatca(JSON.serialize(payload));
        
        linee = CtrlWizardOpportunity.editFatca(opp.id);
        System.assertEquals(1, linee.size());
    }
    
    @isTest
    static void testSearchReferenti()
    {
        Opportunity opp = [SELECT id, Name FROM Opportunity WHERE Name = '01' LIMIT 1];
        List<Contact> contatti = CtrlWizardOpportunity.searchReferenti(opp.id);
        System.assertEquals(1, contatti.size());
    }
    
    @isTest
    static void testEditAdeguataVerifica()
    {
        Opportunity opp = [SELECT id, Name FROM Opportunity WHERE Name = '01' LIMIT 1];
        CtrlWizardOpportunity.WoAdeguataVerifica av = CtrlWizardOpportunity.editAdeguataVerifica(opp.id);
        System.assertEquals(1, av.referenti.size());
        System.assertEquals(1, av.advL.size());
        System.assertEquals('11', av.advL[0].adv[0]);
        System.assertEquals('13', av.advL[0].adv[1]);
        System.assertEquals('test', av.indirizzo.city);
    }
    
    @isTest
    static void testUpdateAdeguataVerifica()
    {
        Opportunity opp = [SELECT id, Name FROM Opportunity WHERE Name = '01' LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Name = 'A'];
        acc.EmailPEC__c = 'testpec@test.test';
        acc.Phone = '111111';
        acc.Fax = '222222';
        acc.Email__c = 'test@test.test';
        acc.PartecipazioneSocietaFiduciarie2__c = true;
        update acc;
        CtrlWizardOpportunity.WoAdeguataVerifica av = CtrlWizardOpportunity.editAdeguataVerifica(opp.id);
        System.assertEquals(1, av.referenti.size());
        System.assertEquals(1, av.advL.size());
        System.assertEquals('11', av.advL[0].adv[0]);
        System.assertEquals('13', av.advL[0].adv[1]);
        System.assertEquals('test', av.indirizzo.city);
        
        av.advL[0].adv.remove(1);
        av.indirizzo.city = 'test2';
        av.opportunityId = opp.Id;
        av.account = acc;
        CtrlWizardOpportunity.updateAdeguataVerifica(JSON.serialize(av));
        av = CtrlWizardOpportunity.editAdeguataVerifica(opp.id);
        System.assertEquals(1, av.referenti.size());
    }
    
    @isTest
    static void testGetDestinatari()
    {
        Opportunity opp = [SELECT id, Name FROM Opportunity WHERE Name = '01' LIMIT 1];
        List<Contact> conList = CtrlWizardOpportunity.getDestinatari(opp.id);
        //only 1 user, but withut email --> expected no results
        System.assertEquals(0, conList.size());
        //now set the email to the user, expected 1 result retrieved
        Account a = [SELECT Id FROM Account WHERE Name = 'A'];
        Contact c = [SELECT id FROM Contact WHERE AccountId = :a.id AND LastName = 'test'];
        c.Email = 'test@test.com';
        update c;
        conList = CtrlWizardOpportunity.getDestinatari(opp.id);
        System.assertEquals(1, conList.size());
    }
    
    @isTest
    static void testGetAccountData()
    {
        Account a = [SELECT id, Name FROM Account  WHERE Name = 'A'];
        a = CtrlWizardOpportunity.getAccountData(a.Id);
        System.assertEquals('A', a.Name);
    }
    
    @isTest
    static void testGetDiviseDisponibili()
    {
        System.assertEquals(0, CtrlWizardOpportunity.getDiviseDisponibili().size());
    }
    
    @isTest
    static void testGetRiepilogoOpportunita()
    {
        Opportunity opp = [SELECT id, Name FROM Opportunity WHERE Name = '01' LIMIT 1];
        List<Object> data = CtrlWizardOpportunity.getRiepilogoOpportunita(opp.Id);
        // System.assertEquals(4, data.size());
    }
    
    @isTest
    static void testGetServizi() {
        Test.startTest();
        MatriceServizio__mdt[] matriceServizioList = CtrlWizardOpportunity.getServizi(false, true, false);
        Test.stopTest();
        
        Set<String> matriceServizioLabelSet = U.getSet(matriceServizioList, 'Label');
        System.assert(matriceServizioLabelSet.contains('Factoring'));
        System.assert(matriceServizioLabelSet.contains('Anticipo Crediti futuri'));
        System.assert(matriceServizioLabelSet.contains('Acquisto a titolo definitivo'));
    }
    
    @isTest
    static void testGetSezioni() {
        MatriceSezioni__mdt[] matriceSezioneList = CtrlWizardOpportunity.getSezioni();
    }
    
    @isTest
    static void testEditRsf()
    {
        Funzionalita__c x = new Funzionalita__c();
        x.DisabilitaTriggers__c = true;
        insert x;

        Opportunity opp = [SELECT id, Name FROM Opportunity WHERE Name = '01' LIMIT 1];
        opp.TiAnticipo__c = true;
        update opp;

        CtrlWizardOpportunity.WoPayload pl = CtrlWizardOpportunity.editRsf(opp.id);
        System.assertEquals(opp.id, pl.opportunityId);
        System.assertEquals(3, pl.pb.size());
        System.assertEquals(1, pl.pfi.size());
        System.assertNotEquals(null, pl.fd);
    }
    
    @isTest
    static void testSaveCategorie() {
        Test.startTest();
        // genero payload..
        Map<String, SObject> rtMap = U.getRecordTypes('Linea__c');
        Opportunity opp = [SELECT id, Name FROM Opportunity WHERE Name = '01' LIMIT 1];
        CtrlWizardOpportunity.WoPayload pl = CtrlWizardOpportunity.editRsf(opp.id);
        
        List<Linea__c> linee = [SELECT Id, Prodotto__r.CodiceUnivoco__c FROM Linea__c WHERE Opportunity__c = :pl.opportunityId AND RecordTypeId IN (:rtMap.get('Fido').Id, :rtMap.get('FactInd').Id)];
        System.assertEquals(4, linee.size());
        
        // ..lo modifico aggiungendo una linea di fido..
        CtrlWizardOpportunity.WoProdotto wp = new CtrlWizardOpportunity.WoProdotto();
        wp.tipo = K.CODPROD_FIDO;
        // wp.importo = 0;
        wp.fido = false;
        wp.preAmmortamento = false;
        pl.pb.add(wp);
        
        // ..e un mutuo..
        CtrlWizardOpportunity.WoProdotto wpM = new CtrlWizardOpportunity.WoProdotto();
        wpM.tipo = K.CODPROD_MUTUO;
        wpM.importo = 100;
        wpM.fido = false;
        wpM.preAmmortamento = false;
        pl.pb.add(wpM);
        
        pl = CtrlWizardOpportunity.saveCategorie(JSON.serialize(pl));
        
        linee = [SELECT Id, Prodotto__r.CodiceUnivoco__c FROM Linea__c WHERE Opportunity__c = :pl.opportunityId AND RecordTypeId IN (:rtMap.get('Fido').Id, :rtMap.get('FactInd').Id)];
        
        // ..e verifico che la linea di fido non sia aggiunta, in quanto già presente, ma il mutuo sì
        System.assertEquals(4, linee.size());
        System.assertEquals(0, U.filter(linee, 'Prodotto__r.CodiceUnivoco__c', K.CODPROD_FIDO).size());
        System.assertEquals(2, U.filter(linee, 'Prodotto__r.CodiceUnivoco__c', K.CODPROD_MUTUO).size());
        
        Test.stopTest();
    }
    
    @isTest
    static void testSaveGaranzie() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        NDGLinea__c ndglinea = [SELECT Id FROM NDGLinea__c LIMIT 1];
        Garanzia__c garanzia = [SELECT IdEsterno__c FROM Garanzia__c WHERE IdEsterno__c = '666111'];
        CtrlWizardOpportunity.WoPayload p = new CtrlWizardOpportunity.WoPayload();
        p.opportunityId = opp.Id;
        p.joinGaranziaGarante = new CtrlWizardOpportunity.WoJoinGaranziaGarante[]{};
            CtrlWizardOpportunity.WoJoinGaranziaGarante wjgg = new CtrlWizardOpportunity.WoJoinGaranziaGarante();
        wjgg.garante = ndglinea.Id;
        wjgg.garanzia = garanzia.IdEsterno__c;
        wjgg.percentualeGaranzia = 50;
        p.joinGaranziaGarante.add(wjgg);
        
        CtrlWizardOpportunity.saveGaranzie(JSON.serialize(p));
        // todo test: sistemare
    }
    
    @isTest
    static void testSaveConfigurazioneIcarManuali() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        NDGLinea__c deb = TestUtils.creaNDGLineaDebitore(c, opp);
        deb.FakeId__c = '1234';
        update deb;
        
        CtrlWizardOpportunity.WoPayload p = new CtrlWizardOpportunity.WoPayload();
        p.opportunityId = opp.Id;
        p.configurazioneIcarManuali = new CtrlWizardOpportunity.WoIcarManuale[]{};
            CtrlWizardOpportunity.WoIcarManuale wim = new CtrlWizardOpportunity.WoIcarManuale();
        wim.debitore = deb.FakeId__c;
        wim.ragioneSociale = 'Test';
        wim.icarManuali = new CtrlWizardOpportunity.IcarManuale[]{};
            CtrlWizardOpportunity.IcarManuale im = new CtrlWizardOpportunity.IcarManuale();
        im.annoFatturatoDa = '2016';
        im.annoFatturatoA = '2017';
        wim.icarManuali.add(im);
        p.configurazioneIcarManuali.add(wim);
        CtrlWizardOpportunity.saveConfigurazioneIcarManuali(JSON.serialize(p));
        // todo test: sistemare
    }
    
    @isTest
    static void testGetGaranzie() {
        CtrlWizardOpportunity.getGaranzie();
        // todo test: sistemare
    }
    
    @isTest
    static void testSaveWizard()
    {
        Test.startTest();
        Opportunity opp = [SELECT id, Name FROM Opportunity WHERE Name = '01' LIMIT 1];
        CtrlWizardOpportunity.WoPayload pl = CtrlWizardOpportunity.editRsf(opp.id);
        pl.debitori = new List<CtrlWizardOpportunity.WoDebitore>();
        pl.debitori.add( new CtrlWizardOpportunity.WoDebitore() );
        pl.debitori[0].dmc = 40;
        pl.debitori[0].durataNominale = 40;
        pl.debitori[0].fatturato = 40;
        pl.debitori[0].plafond = 40;
        
        Map<String, SObject> rtMap = U.getRecordTypes('Linea__c');
        List<Linea__c> linee = [SELECT Id FROM Linea__c WHERE Opportunity__c = :pl.opportunityId AND RecordTypeId IN (:rtMap.get('Fido').Id, :rtMap.get('FactInd').Id)];
        System.assertEquals(4, linee.size());
        CtrlWizardOpportunity.saveWizard(JSON.serialize(pl), 'categorie');
        linee = [SELECT Id FROM Linea__c WHERE Opportunity__c = :pl.opportunityId AND RecordTypeId IN (:rtMap.get('Fido').Id, :rtMap.get('FactInd').Id)];
        System.assertEquals(3, linee.size());
        
        System.assertEquals(null, CtrlWizardOpportunity.saveWizard(JSON.serialize(pl), 'aaaaa'));
        Test.stopTest();
    }
    
    @isTest
    static void testSaveDebitori() {
        Test.startTest();
        // genero payload..
        Account a = TestUtils.creaAccount('Accaunt');
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        Opportunity opp = [SELECT id, Name FROM Opportunity WHERE Name = '01' LIMIT 1];
        CtrlWizardOpportunity.WoPayload pl = CtrlWizardOpportunity.editRsf(opp.id);
        
        // ..lo modifico aggiungendo un debitore..
        pl.debitori = new List<CtrlWizardOpportunity.WoDebitore>();
        CtrlWizardOpportunity.WoDebitore wd = new CtrlWizardOpportunity.WoDebitore();
        wd.piva = String.valueOf(a.Id);
        wd.Id = 'AAA';
        pl.debitori.add(wd);
        
        // Test.startTest();
        CtrlWizardOpportunity.saveDebitori(JSON.serialize(pl));
        // Test.stopTest();
        
        // ..e verifico il suo inserimento
        NDGLinea__c[] ndgLinee = [SELECT Id FROM NDGLinea__c WHERE Account__r.Name = 'Accaunt'];
        System.assertEquals(1, ndgLinee.size());
        Test.stopTest();
    }
    
    
    @isTest
    static void testGetParametriProdottiLinea() {
        Opportunity opp = [SELECT Id, Name FROM Opportunity LIMIT 1];
        CtrlWizardOpportunity.getParametriProdottiLinea(opp.id);
    }
    
    @isTest
    static void testSaveJoinLineeAttore() {
        TestUtils.creaProdottoPCDFO();
        // genero payload..
        Opportunity opp = [SELECT Id, Name FROM Opportunity LIMIT 1];
        CtrlWizardOpportunity.WoPayload pl = CtrlWizardOpportunity.editRsf(opp.id);
        
        // ..genero un debitore..
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        NDGLinea__c ndgLinea = TestUtils.CreaNDGLineaDebitore(c, opp);
        ndgLinea.Tipo__c = 'Debitore';
        update ndgLinea;
        
        // ..modifico il payload aggiungendo il join..
        pl.joinLineaAttore = new List<CtrlWizardOpportunity.WoJoinLineaAttore>();
        CtrlWizardOpportunity.WoJoinLineaAttore wjla = new CtrlWizardOpportunity.WoJoinLineaAttore();
        wjla.debitore = String.valueOf(ndgLinea.Id);
        wjla.servizi = new List<String>();
        wjla.servizi.add('Factoring');
        pl.joinLineaAttore.add(wjla);
        pl.debitori = new List<CtrlWizardOpportunity.WoDebitore>();
        CtrlWizardOpportunity.WoDebitore debitore = new CtrlWizardOpportunity.WoDebitore();
        debitore.id =  String.valueOf(ndgLinea.Id);
        debitore.aNotifica = true;
        debitore.maturity = false;
        debitore.divisa = '242';
        debitore.mercato = '001';
        pl.debitori.add(debitore);
        
        Test.startTest();
        CtrlWizardOpportunity.saveJoinLineeAttore(pl);
        Test.stopTest();
        
        // ..e verifico l'inserimento del join
        JoinLineaDebitore__c[] jld = [SELECT Id FROM JoinLineaDebitore__c WHERE Opportunita__c = :opp.Id];
        System.assertEquals(1, jld.size());
    }
    
    @isTest
    static void testSaveGaranzia() {
        Garanzia__c garanzia = [SELECT IdEsterno__c, Importo__c FROM Garanzia__c WHERE IdEsterno__c = '666111'];
        garanzia.Importo__c = 10;
        
        Test.startTest();
        CtrlWizardOpportunity.saveGaranzia(garanzia);
        Test.stopTest();
        
        garanzia = [SELECT Importo__c FROM Garanzia__c WHERE IdEsterno__c = '666111'];
        System.assertEquals(10,garanzia.Importo__c);
    }
    
    
    @isTest
    static void testRemoveGaranzia() {
        Garanzia__c[] garanzie = [SELECT IdEsterno__c, Importo__c  FROM Garanzia__c];
        // System.assertEquals(2, garanzie.size());
        
        Test.startTest();
        CtrlWizardOpportunity.removeGaranzia(garanzie[0].IdEsterno__c);
        Test.stopTest();
        
        garanzie = [SELECT IdEsterno__c, Importo__c  FROM Garanzia__c];
        System.assertEquals(1, garanzie.size());
    }
    
    @isTest
    static void testRemoveGarante() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        NDGLinea__c garante = new NDGLinea__c(Opportunita__c = opp.Id);
        insert garante;
        
        Test.startTest();
        CtrlWizardOpportunity.removeGarante(garante.Id);
        Test.stopTest();
        
        System.assertEquals(0, [SELECT Id FROM NDGLinea__c WHERE Id = :garante.Id].size());
    }
    
    @isTest
    static void testRemoveGaranti() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        NDGLinea__c garante = new NDGLinea__c(Opportunita__c = opp.Id);
        insert garante;
        
        Test.startTest();
        CtrlWizardOpportunity.removeGaranti(new Id[]{garante.Id});
        Test.stopTest();
        
        System.assertEquals(0, [SELECT Id FROM NDGLinea__c WHERE Id = :garante.Id].size());
    }
    
    @isTest
    static void testSaveGarante() {
        Account a = [SELECT Id FROM Account LIMIT 1];
        Opportunity o = [SELECT Id FROM Opportunity LIMIT 1];
        User utente = [SELECT id FROM User LIMIT 1];
        
        System.assertEquals(0, [SELECT Id FROM NDGLinea__c WHERE Account__c = :a.Id AND Tipo__c = 'Garante' AND Opportunita__c = :o.Id].size());
        
        System.runAs(utente) {
            Test.startTest();
            try {
                CtrlWizardOpportunity.saveGarante(a.Id, o.Id);
            } catch(Exception e) {
            }
            Test.stopTest();
        }
        
        // System.assertEquals(1, [SELECT Id FROM NDGLinea__c WHERE Account__c = :a.Id AND Tipo__c = 'Garante' AND Opportunita__c = :o.Id].size());
        // todo test: sistemare
    }
    
    @isTest
    static void testGetDominiProdotti() {
        insert new Prodotto__c(Name = 'ProdottoTest', CodiceUnivoco__c = 'ProdottoCUTest', CategoriaProdotto__c = 'Prodotto Bancario');
        Map<String, List<Map<String, String>>> result;
        
        Test.startTest();
        result = CtrlWizardOpportunity.getDominiProdotti();
        Test.stopTest();
        System.debug('result: ' + JSON.serialize(result));
        
        System.assertEquals(1, result.get('Factoring indiretto').size());
        // todo test: sistemare
    }
    
    @isTest
    static void testLogGarante() {
        
        User utente = [SELECT id FROM User LIMIT 1];
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        NDGLinea__c garante = new NDGLinea__c(Opportunita__c = opp.Id);
        insert garante;
        
        //System.assertEquals(0, [SELECT Id FROM Log__c].size());
        
        // System.runAs(utente) {
        //   Test.startTest();
        //   CtrlWizardOpportunity.logGarante(new NDGLinea__c[]{garante}, opp.Id);
        //   Test.stopTest();
        // }
        
        // System.assertEquals(1, [SELECT Id FROM Log__c].size());
        // todo test: sistemare
    }
    
    @isTest
    static void testSaveConfigurazioneLinee() {
        Test.startTest();
        Opportunity opp = [SELECT Id, Name FROM Opportunity LIMIT 1];
        CtrlWizardOpportunity.WoPayload pl = CtrlWizardOpportunity.editRsf(opp.id);
        pl.parametriAggiuntivi = new List<CtrlWizardOpportunity.WoParametro>();
        CtrlWizardOpportunity.WoParametro tmp = new CtrlWizardOpportunity.WoParametro();
        tmp.valore = 'AAA';
        tmp.linea = [SELECT Id FROM Linea__c LIMIT 1][0].Id;
        pl.parametriAggiuntivi.add(tmp);
        System.assertEquals(0, [SELECT Id FROM PConfigurato__c].size());
        CtrlWizardOpportunity.saveConfigurazioneLinee(JSON.serialize(pl));
        System.assertEquals(1, [SELECT Id FROM PConfigurato__c].size());
        Test.stopTest();
    }
    
    @isTest
    static void testSetWizardCompletato() {
        Opportunity opp = [SELECT Id, Name, WizardCompletato__c FROM Opportunity LIMIT 1];
        Test.startTest();
        CtrlWizardOpportunity.setWizardCompletato(opp.Id, true);
        Test.stopTest();
        Opportunity result = [SELECT WizardCompletato__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(false, opp.WizardCompletato__c);
        System.assertEquals(true, result.WizardCompletato__c);
    }
    
    @isTest
    static void testGetParamPropagabili() {
        Test.startTest();
        String[] result = CtrlWizardOpportunity.getParamPropagabili();
        Test.stopTest();
        System.assertEquals(2, result.size());
        System.assertEquals('010', result[0]);
        System.assertEquals('050', result[1]);
    }
    
    @isTest
    static void testGetInformazioniPopupDebitore() {
        Account a = [SELECT Id FROM Account WHERE Name = 'A'];
        a.REA__c = '546027';
        a.ProvinciaCCIAA__c = 'MI';
        update a;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_RIBES_EVENTI_NEGATIVI));
        WSRestRibesUtils.EventiNegativiPlain response = CtrlWizardOpportunity.getInformazioniPopupDebitore(a.Id);
        Test.stopTest();
        
        System.assert(response != null);
    }
    
    @isTest
    static void testGetRiepilogoInfoCr() {
        Opportunity opp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        
        Test.startTest();
        List<Map<String,Object>> response = CtrlWizardOpportunity.getRiepilogoInfoCr(opp.Id);
        Test.stopTest();
        
        System.assertEquals(2, response.size());
        System.assertEquals('A', response[0].get('nome'));
        System.assertEquals('Cedente', response[0].get('tipo'));
        System.assertEquals(null, response[0].get('dataRichiestaCR'));
        System.assertEquals('standard-account', response[0].get('icona'));
        System.assertEquals(opp.AccountId, response[0].get('id'));
    }
    
    @isTest
    static void testGetDebitoriPerLinea() {
        
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Linea__c[] linee = [SELECT Id FROM Linea__c WHERE Opportunity__c = :opp.Id];
        NDGLinea__c deb = TestUtils.creaNDGLineaDebitore(c, opp);
        deb.FakeId__c = '1234';
        update deb;
        JoinLineaDebitore__c jld = new JoinLineaDebitore__c(Debitore__c = deb.Id, Linea__c = linee[0].Id, Opportunita__c = opp.Id);
        insert jld;
        
        Test.startTest();
        Map<String, String[]> response = CtrlWizardOpportunity.getDebitoriPerLinea(opp.Id);
        Test.stopTest();
        
        System.assertEquals(1, response.get(linee[0].Id).size());
        System.assertEquals('1234', response.get(linee[0].Id)[0]);
    }
    
    // @isTest static void testSaveGaranteDefault(){
    //     Garanzia__c g = [SELECT Id, CodiceGaranzia__c FROM Garanzia__c WHERE CodiceGaranzia__c = 'GARFD'];
    //     Linea__c l = [SELECT Id FROM Linea__c WHERE FinalitaMutuo__c = 'testPercentuale'];
    //     Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
    //     g.Linea__c = l.Id;
    //     update g;
    //     NDGLinea__c attore = (NDGLinea__c) CtrlWizardOpportunity.saveGaranteDefault(g,opp.Id);
    //     System.assertEquals(attore.TipoGarante__c, 'S');
    // }
    
    // @isTest
    // static void testGetCodiciProdottoAtd() {
    //   Test.startTest();
    //   String[] result = CtrlWizardOpportunity.getCodiciProdottoAtd(WoPayload p, Boolean haIfisImpresa);
    //   Test.stopTest();
    //   // TODO: continuare
    // }
    
    @isTest
    static void test_fetchAttorePrivacy(){
        Funzionalita__c x = new Funzionalita__c();
        x.DisabilitaTriggers__c = true;
        insert x;
        Account a = TestUtils.creaAccount('test');
        Contact c = TestUtils.creaReferente(a);
        Opportunity o = TestUtils.CreaOpportunity(a, 'testOpp');
        NDGLinea__c n = TestUtils.CreaNGDLineaTitolare(c, o, true, 'Esecutore adeguata verifica');
        Id accId = CtrlWizardOpportunity.fetchAttorePrivacy('Account', o.Id);
        Id cntId = CtrlWizardOpportunity.fetchAttorePrivacy('Contact', o.Id);
        
    }
    
    @isTest
    static void test_contains(){
        Set<String> values = new Set<String>();
        values.add('pippo');
        values.add('pluto');
        Set<String> container = new Set<String>();
        container.add('pippo');
        container.add('pluto');
        container.add('paperino');
        container.add('topolino');
        List<String> container2 = new List<String>();
        container2.add('pippo');
        container2.add('pluto');
        container2.add('paperino');
        container2.add('topolino');          
        Boolean listResult = CtrlWizardOpportunity.containsAny(container2, values);
        Boolean setResult = CtrlWizardOpportunity.containsAny(container, values);
        String getResult = CtrlWizardOpportunity.getContainedElement(container, values);
        
    }

    @isTest
    static void test_Garante(){
        Account a = [SELECT Id,
                     OwnerId,
                     ConsensoAllaProfilazione__c,
                     ConsensoAttivitaPromRicercheMercato__c,
                     ConsensoAttivitaPromozionaleTerzi__c,
                     ConsensoProdottiBancaRicercheMercato__c,
                     ConsensoProdottiSocietaTerze__c,
                     ConsensoSoloModalitaTradizionali__c,
                     DataInserimentoConsensi__c
                     FROM Account WHERE Name = 'A'];
        
        Opportunity o = [SELECT Id FROM Opportunity WHERE Name = '01'];
        NDGLinea__c ndgLinea = CtrlWizardOpportunity.creaGarante(o.Id, a.Id, 'tipoGarante', 'codiceRapporto');

        List<NDGLinea__c> ndgList = new List<NDGLinea__c>();
        ndgList.add(ndgLinea);
        CtrlWizardOpportunity.logGarante(ndgList, o.Id);
    }
    
}