@isTest
public with sharing class WGC_CreateContact_Test {
    @isTest
    public static void Test_Metodi(){
        WGC_AllDataFactory.disattivaTrigger();
        WGC_AllDataFactory.createLagKey();
        WGC_AllDataFactory.creaImpServ();


        //WGC_AllDataFactory.createUtenzaDefault();
        List<Account> listAcc = WGC_AllDataFactory.createAccount(3,true);
        Account a = listAcc.get(0);
        List<Contact> listContact = WGC_AllDataFactory.createContact(3,true);
        List<Opportunity> listOpportunity = WGC_AllDataFactory.createOpportunity(1,true);
        List<String> listStr = new List<String>();
        listStr.add('a');
        listStr.add('b');
        listStr.add('c');

        WGC_CreateContact.WrapperRecords wr1 = new WGC_CreateContact.WrapperRecords();
        wr1.cf =listContact.get(0).CF__c;
    	wr1.firstName=listContact.get(0).FirstName;
    	wr1.lastName=listContact.get(0).LastName;

        String prova1 = JSON.serialize(wr1);

        WGC_CreateContact.WrapperRecords wr2 = new WGC_CreateContact.WrapperRecords();
        wr2.cf =listContact.get(0).CF__c;
    	wr2.firstName=listContact.get(0).FirstName;
    	wr2.lastName=listContact.get(0).LastName;
        wr2.tipoDiRicerca=  'test';
        
        String prova2 = JSON.serialize(wr2);

        WGC_CreateContact.WrapperRecords wr3 = new WGC_CreateContact.WrapperRecords();
        wr3.cf =listContact.get(0).CF__c;
    	wr3.firstName=listContact.get(0).FirstName;
    	wr3.lastName=listContact.get(0).LastName;
        wr3.tipoDiRicerca=  'cFiscale';
        wr3.whoAreYou = 'filoDiretto';

        String prova3 = JSON.serialize(wr3);

        Comune__c comune = new Comune__c(Name='ROMA',Provincia__c='RM', Cap__c='100', CodiceCatastale__c='H501');
        insert comune;

        // System.debug('chiamata: '+WsAnagrafe.gestioneCollNdg(a.NDGGruppo__c));

        Test.setMock(HttpCalloutMock.class, new WGC_HttpRequestController_MockImpl());
        Test.startTest();
        WGC_CreateContact.getInformationContact(prova1);
        WGC_CreateContact.getInformationContact(prova2);
        WGC_CreateContact.getInformationContact(prova3);
        WGC_CreateContact.getOriginAccount(listAcc.get(0).id);
        WGC_CreateContact.getAccountConnectedWithContact(listContact.get(0));
        //WGC_CreateContact.setInformationContact(listContact.get(0));  //Errore nel recupero dati anagrafici cedacri 
        // WGC_CreateContact.saveContact(listContact.get(0),listAcc.get(0).id,listStr,'censimentoLead','Opportunity',listOpportunity.get(0));
        // WGC_CreateContact.saveContact(listContact.get(0),listAcc.get(0).id,listStr,'light','Opportunity',listOpportunity.get(0));
        WGC_CreateContact.getselectOptions(a,'Name');
        WGC_CreateContact.getselectOptions_Nazione('Account', null,null);
        WGC_CreateContact.getselectOptions_ComuniFromProvincia('Account','Mi');
        WGC_CreateContact.getPositionRecords();
        WGC_CreateContact.fetchLookUpValues('Account','Account');
        WGC_CreateContact.getOriginOpportunity(listOpportunity.get(0).Id);
        WGC_CreateContact.setInformationContact(listContact.get(0));
        Test.stopTest();
    }

    @isTest
    public static void test_Save_censimentoLead(){
        WGC_AllDataFactory.createLagKey();
        WGC_AllDataFactory.creaImpServ();
        WGC_AllDataFactory.createUtenzaDefault();
        
        List<Comune__c> listComune = WGC_AllDataFactory.createComune(3,true);
        List<Ateco__c> listAteco = WGC_AllDataFactory.createAteco(3,true);
		List<Opportunity> listOpportunity = WGC_AllDataFactory.createOpportunity2(1);
        List<Account> listAcc = WGC_AllDataFactory.createAccount(2,true);
        listOpportunity.get(0).AccountId=listAcc.get(0).Id;
        insert listOpportunity;
        List<String> listStr = new List<String>();
        listStr.add('a');
        listStr.add('b');
        listStr.add('c');
        // SV insertAccount Account: Account:{Name="PANINOTECA PK - S.R.L.", NaturaGiuridica__c=SRL, ProvinciaCCIAA__c=ME, REA__c=188154, PIVA__c=02717290833, VAT__c=02717290833, CF__c=02717290833, Origine__c=Ribes, CodiceIstituto3N__c=881, DettaglioSettore__c=56102, ShippingStreet=VIA GIORDANO BRUNO 63, ShippingCity=MESSINA, ShippingState=ME, ShippingPostalCode=98123, ShippingStreetName__c=GIORDANO BRUNO, ShippingStreetNumber__c=63, ShippingStreetType__c=VIA, BillingStreet=VIA GIORDANO BRUNO 63, BillingCity=MESSINA, BillingPostalCode=98123, BillingState=ME, BillingStreetName__c=GIORDANO BRUNO, BillingStreetNumber__c=63, BillingStreetType__c=VIA, StatoAnagrafica__c=ATTIVA, RecordTypeId=01258000000FIjdAAG, TAG_Controllante__c=NB Inbound, WGC_Originator__c=Web, WGC_Originator_dettaglio__c=FORM_MPMI}
        // SV source: 
        // SV zIgnoreErrors: false
        // SV tipoCensimento: light
        // SV contactDI: null


        // Account a = new Account(PIVA__c='12803211007', BillingStreetNumber__c='70', ShippingStreetName__c='DI TORRE ARGENTINA', BillingCity='ROMA', StatoAnagrafica__c='ATTIVA', ProvinciaCCIAA__c='RM', REA__c='1401327', Origine__c='Ribes', Name='PANINOTECA BOOM BOOM DI SILVANO ANTONIETTI', CF__c='NTNSVN56A06A132N', CodiceIstituto3N__c='881', NaturaGiuridica__c='DI', Phone=null, RecordTypeId='01258000000FIjdAAG', ShippingCountry='ITALIA', ShippingCity='ROMA', BillingPostalCode='00186', Ateco__c='56.10.2', VAT__c='12803211007', DettaglioSettore__c='56102', BillingStreetName__c='DI TORRE ARGENTINA', ShippingStreet='VIA DI TORRE ARGENTINA 70', StatoCensimento__c='Richiesta evasa', RAE__c='660', BillingStreetType__c='VIA', BillingCountry='ITALIA', BillingStreet='VIA DI TORRE ARGENTINA 70', ShippingPostalCode='00186', ShippingStreetNumber__c='70', ShippingState='RM', SAE__c='615', BillingState='RM', ShippingStreetType__c='VIA');
        // insert a;
        Contact c = new Contact(CodCatastaleLocNascita__c='A132', FirstName='SILVANO', LuogoEmissioneDoc__c='ALBANO LAZIALE', DataEmissioneDoc__c= Date.newInstance(2009,05,21), DataScadenzaDoc__c=Date.newInstance(2029,05,21), Birthdate=Date.newInstance(1956,01,06), CI3N_CF__c='881-NTNSVN56A06A132N', TipoDocumentoId__c='1', LuogoNascita__c='ALBANO LAZIALE', CF__c='NTNSVN56A06A132N', CodiceIstituto3N__c='881', EnteEmitettenteDocumento__c='ALBANO LAZIALE', TAECode__c='984', Sesso__c='M', LastName='ANTONIETTI', SAE__c='600', NumeroDoc__c='AZ1029283');
        
        Account a = listAcc.get(0);
        Test.setMock(HttpCalloutMock.class, new WGC_HttpRequestController_MockImpl());
        Test.startTest();

        WGC_CreateContact.saveContact(c,listAcc.get(0).id,listStr,'censimentoLead','Opportunity',listOpportunity.get(0));
        
        Test.stopTest();
    }

    @isTest
    public static void test_Save_full_NDG_null(){
        WGC_AllDataFactory.createLagKey();
        WGC_AllDataFactory.creaImpServ();
        WGC_AllDataFactory.createUtenzaDefault();
        
        //List<Comune__c> listComune = WGC_AllDataFactory.createComune(3,true);
        
        List<Ateco__c> listAteco = WGC_AllDataFactory.createAteco(3,true);
		List<Opportunity> listOpportunity = WGC_AllDataFactory.createOpportunity2(1);
        Account a = new Account(PIVA__c='12803211007', NDGGruppo__c='107499', BillingStreetNumber__c='70', ShippingStreetName__c='DI TORRE ARGENTINA', BillingCity='ROMA', StatoAnagrafica__c='ATTIVA', ProvinciaCCIAA__c='RM', REA__c='1401327', Origine__c='Ribes', Name='PANINOTECA BOOM BOOM DI SILVANO ANTONIETTI', CF__c='NTNSVN56A06A132N', CodiceIstituto3N__c='881', NaturaGiuridica__c='DI', Phone=null, RecordTypeId='01258000000FIjdAAG', ShippingCountry='ITALIA', ShippingCity='ROMA', BillingPostalCode='00186', Ateco__c='56.10.2', VAT__c='12803211007', DettaglioSettore__c='56102', BillingStreetName__c='DI TORRE ARGENTINA', ShippingStreet='VIA DI TORRE ARGENTINA 70', StatoCensimento__c='Richiesta evasa', RAE__c='660', BillingStreetType__c='VIA', BillingCountry='ITALIA', BillingStreet='VIA DI TORRE ARGENTINA 70', ShippingPostalCode='00186', ShippingStreetNumber__c='70', ShippingState='RM', SAE__c='615', BillingState='RM', ShippingStreetType__c='VIA');
        insert a;
        listOpportunity.get(0).AccountId=a.Id;
        insert listOpportunity;
        insert  new Comune__c(Name = 'ALBANO LAZIALE',Provincia__c = 'RM', CAP__c = '00041');

        List<String> listStr = new List<String>();
        listStr.add('UF');
        listStr.add('J');
        listStr.add('Z1');
        
        
        Contact c = new Contact(AccountId=a.Id, CodCatastaleLocNascita__c='A132', FirstName='SILVANO', LuogoEmissioneDoc__c='ALBANO LAZIALE', DataEmissioneDoc__c= Date.newInstance(2009,05,21), DataScadenzaDoc__c=Date.newInstance(2029,05,21), Birthdate=Date.newInstance(1956,01,06), CI3N_CF__c='881-NTNSVN56A06A132N', TipoDocumentoId__c='1', LuogoNascita__c='ALBANO LAZIALE', CF__c='NTNSVN56A06A132N', CodiceIstituto3N__c='881', EnteEmitettenteDocumento__c='ALBANO LAZIALE', TAECode__c='984', Sesso__c='M', LastName='ANTONIETTI', SAE__c='600', NumeroDoc__c='AZ1029283', MailingCity='ALBANO LAZIALE', MailingStreetName__c='STAZIONE');
        insert c;
        

        Test.setMock(HttpCalloutMock.class, new WGC_HttpRequestController_MockImpl());
        Test.startTest();

        WGC_CreateContact.saveContact(c,a.Id,listStr,'full','Opportunity',listOpportunity.get(0));
        
        Test.stopTest();
    }

     @isTest
    public static void test_Save_full_con_NDG(){
        WGC_AllDataFactory.createLagKey();
        WGC_AllDataFactory.creaImpServ();
        WGC_AllDataFactory.createUtenzaDefault();
        
        //List<Comune__c> listComune = WGC_AllDataFactory.createComune(3,true);
        
        List<Ateco__c> listAteco = WGC_AllDataFactory.createAteco(3,true);
		List<Opportunity> listOpportunity = WGC_AllDataFactory.createOpportunity2(1);
        Account a = new Account(PIVA__c='12803211007', NDGGruppo__c='107499', BillingStreetNumber__c='70', ShippingStreetName__c='DI TORRE ARGENTINA', BillingCity='ROMA', StatoAnagrafica__c='ATTIVA', ProvinciaCCIAA__c='RM', REA__c='1401327', Origine__c='Ribes', Name='PANINOTECA BOOM BOOM DI SILVANO ANTONIETTI', CF__c='NTNSVN56A06A132N', CodiceIstituto3N__c='881', NaturaGiuridica__c='DI', Phone=null, RecordTypeId='01258000000FIjdAAG', ShippingCountry='ITALIA', ShippingCity='ROMA', BillingPostalCode='00186', Ateco__c='56.10.2', VAT__c='12803211007', DettaglioSettore__c='56102', BillingStreetName__c='DI TORRE ARGENTINA', ShippingStreet='VIA DI TORRE ARGENTINA 70', StatoCensimento__c='Richiesta evasa', RAE__c='660', BillingStreetType__c='VIA', BillingCountry='ITALIA', BillingStreet='VIA DI TORRE ARGENTINA 70', ShippingPostalCode='00186', ShippingStreetNumber__c='70', ShippingState='RM', SAE__c='615', BillingState='RM', ShippingStreetType__c='VIA');
        insert a;
        listOpportunity.get(0).AccountId=a.Id;
        insert listOpportunity;
        insert  new Comune__c(Name = 'ALBANO LAZIALE',Provincia__c = 'RM', CAP__c = '00041');

        List<String> listStr = new List<String>();
        listStr.add('UF');
        listStr.add('J');
        listStr.add('Z1');
        
        
        
        Contact c = new Contact(AccountId=a.Id, CodCatastaleLocNascita__c='A132', FirstName='SILVANO', LuogoEmissioneDoc__c='ALBANO LAZIALE', DataEmissioneDoc__c= Date.newInstance(2009,05,21), DataScadenzaDoc__c=Date.newInstance(2029,05,21), Birthdate=Date.newInstance(1956,01,06), CI3N_CF__c='881-NTNSVN56A06A132N', TipoDocumentoId__c='1', LuogoNascita__c='ALBANO LAZIALE', CF__c='NTNSVN56A06A132N', CodiceIstituto3N__c='881', EnteEmitettenteDocumento__c='ALBANO LAZIALE', TAECode__c='984', Sesso__c='M', LastName='ANTONIETTI', SAE__c='600', NumeroDoc__c='AZ1029283');
        c.NDGGruppo__c= '107499';
        insert c;
        

        Test.setMock(HttpCalloutMock.class, new WGC_HttpRequestController_MockImpl());
        Test.startTest();

        WGC_CreateContact.saveContact(c,a.Id,listStr,'full','Opportunity',listOpportunity.get(0));
        
        Test.stopTest();
    }

    @isTest
    public static void test_Save_light(){
        WGC_AllDataFactory.createLagKey();
        WGC_AllDataFactory.creaImpServ();
        WGC_AllDataFactory.createUtenzaDefault();
        
        //List<Comune__c> listComune = WGC_AllDataFactory.createComune(3,true);
        
        List<Ateco__c> listAteco = WGC_AllDataFactory.createAteco(3,true);
		List<Opportunity> listOpportunity = WGC_AllDataFactory.createOpportunity2(1);
        Account a = new Account(PIVA__c='12803211007', BillingStreetNumber__c='70', ShippingStreetName__c='DI TORRE ARGENTINA', BillingCity='ROMA', StatoAnagrafica__c='ATTIVA', ProvinciaCCIAA__c='RM', REA__c='1401327', Origine__c='Ribes', Name='PANINOTECA BOOM BOOM DI SILVANO ANTONIETTI', CF__c='NTNSVN56A06A132N', CodiceIstituto3N__c='881', NaturaGiuridica__c='DI', Phone=null, RecordTypeId='01258000000FIjdAAG', ShippingCountry='ITALIA', ShippingCity='ROMA', BillingPostalCode='00186', Ateco__c='56.10.2', VAT__c='12803211007', DettaglioSettore__c='56102', BillingStreetName__c='DI TORRE ARGENTINA', ShippingStreet='VIA DI TORRE ARGENTINA 70', StatoCensimento__c='Richiesta evasa', RAE__c='660', BillingStreetType__c='VIA', BillingCountry='ITALIA', BillingStreet='VIA DI TORRE ARGENTINA 70', ShippingPostalCode='00186', ShippingStreetNumber__c='70', ShippingState='RM', SAE__c='615', BillingState='RM', ShippingStreetType__c='VIA');
        insert a;
        listOpportunity.get(0).AccountId=a.Id;
        insert listOpportunity;
        insert  new Comune__c(Name = 'ALBANO LAZIALE',Provincia__c = 'RM', CAP__c = '00041');

        List<String> listStr = new List<String>();
        listStr.add('J');
        listStr.add('Z1');
        
        
        Contact c = new Contact(AccountId=a.Id, CodCatastaleLocNascita__c='A132', FirstName='SILVANO', LuogoEmissioneDoc__c='ALBANO LAZIALE', DataEmissioneDoc__c= Date.newInstance(2009,05,21), DataScadenzaDoc__c=Date.newInstance(2029,05,21), Birthdate=Date.newInstance(1956,01,06), CI3N_CF__c='881-NTNSVN56A06A132N', TipoDocumentoId__c='1', LuogoNascita__c='ALBANO LAZIALE', CF__c='NTNSVN56A06A132N', CodiceIstituto3N__c='881', EnteEmitettenteDocumento__c='ALBANO LAZIALE', TAECode__c='984', Sesso__c='M', LastName='ANTONIETTI', SAE__c='600', NumeroDoc__c='AZ1029283');
        insert c;
        

        Test.setMock(HttpCalloutMock.class, new WGC_HttpRequestController_MockImpl());
        Test.startTest();

        WGC_CreateContact.saveContact(c,a.Id,listStr,'light','Opportunity',listOpportunity.get(0));
        
        Test.stopTest();
    }
    
    @isTest
    public static void test_getCS_CedacriSleepTime() {
        //no real test, just code coverage
        WGC_CreateContact.getCS_CedacriSleepTime();
    }
    
    @isTest
    public static void test_getUserInfo() {
        //no real test, just code coverage
        WGC_CreateContact.getUserInfo();
    }
    
    
/*
    @isTest
    public static void test_Save_catch(){
        WGC_AllDataFactory.createLagKey();
        WGC_AllDataFactory.creaImpServ();
        WGC_AllDataFactory.createUtenzaDefault();
        
        //List<Comune__c> listComune = WGC_AllDataFactory.createComune(3,true);
        
        List<Ateco__c> listAteco = WGC_AllDataFactory.createAteco(3,true);
		List<Opportunity> listOpportunity = WGC_AllDataFactory.createOpportunity2(1);
        Account a = new Account(PIVA__c='12803211007', BillingStreetNumber__c='70', ShippingStreetName__c='DI TORRE ARGENTINA', BillingCity='ROMA', StatoAnagrafica__c='ATTIVA', ProvinciaCCIAA__c='RM', REA__c='1401327', Origine__c='Ribes', Name='PANINOTECA BOOM BOOM DI SILVANO ANTONIETTI', CF__c='NTNSVN56A06A132N', CodiceIstituto3N__c='881', NaturaGiuridica__c='DI', Phone=null, RecordTypeId='01258000000FIjdAAG', ShippingCountry='ITALIA', ShippingCity='ROMA', BillingPostalCode='00186', Ateco__c='56.10.2', VAT__c='12803211007', DettaglioSettore__c='56102', BillingStreetName__c='DI TORRE ARGENTINA', ShippingStreet='VIA DI TORRE ARGENTINA 70', StatoCensimento__c='Richiesta evasa', RAE__c='660', BillingStreetType__c='VIA', BillingCountry='ITALIA', BillingStreet='VIA DI TORRE ARGENTINA 70', ShippingPostalCode='00186', ShippingStreetNumber__c='70', ShippingState='RM', SAE__c='615', BillingState='RM', ShippingStreetType__c='VIA');
        insert a;
        listOpportunity.get(0).AccountId=a.Id;
        insert listOpportunity;
        insert  new Comune__c(Name = 'ALBANO LAZIALE',Provincia__c = 'RM', CAP__c = '00041');

        List<String> listStr = new List<String>();
        listStr.add('J');
        listStr.add('Z1');
        
        
        Contact c = new Contact(AccountId=a.Id, CodCatastaleLocNascita__c='A132', FirstName='SILVANO', LuogoEmissioneDoc__c='ALBANO LAZIALE', DataEmissioneDoc__c= Date.newInstance(2009,05,21), DataScadenzaDoc__c=Date.newInstance(2029,05,21), Birthdate=Date.newInstance(1956,01,06), CI3N_CF__c='881-NTNSVN56A06A132N', TipoDocumentoId__c='1', LuogoNascita__c='ALBANO LAZIALE', CF__c='NTNSVN56A06A132N', CodiceIstituto3N__c='881', EnteEmitettenteDocumento__c='ALBANO LAZIALE', TAECode__c='984', Sesso__c='M', LastName='ANTONIETTI', SAE__c='600', NumeroDoc__c='AZ1029283');
        // insert c;
        

        // Test.setMock(HttpCalloutMock.class, new WGC_HttpRequestController_MockImpl());
        Test.startTest();

        WGC_CreateContact.saveContact(c,a.Id,listStr,'light','Opportunity',listOpportunity.get(0));
        WGC_CreateContact.saveContact(c,a.Id,listStr,'full','Opportunity',listOpportunity.get(0));

        Test.stopTest();
    }
*/

}