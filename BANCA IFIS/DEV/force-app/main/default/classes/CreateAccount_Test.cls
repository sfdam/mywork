@isTest
public class CreateAccount_Test {

    @isTest
    public static void getInformationAccount_Test_piva_catch(){        
        
        WGC_AllDataFactory.createLagKey();
        CreateAccount.WrapperRecords wr1 = new CreateAccount.WrapperRecords();
        wr1.pivaOrCf ='xxxxx';

        String prova1 = JSON.serialize(wr1);
        Test.setMock(HttpCalloutMock.class, new WGC_HttpRequestController_MockImpl());
        Test.startTest();
        CreateAccount.getInformationAccount(prova1);
        
        Test.stopTest();
    }

    @isTest
    public static void getInformationAccount_Test_piva_sfdc(){    

        WGC_AllDataFactory.createLagKey();
        WGC_AllDataFactory.disattivaTrigger();
        List<Account> listAcc = WGC_AllDataFactory.createAccount(3,true);


        CreateAccount.WrapperRecords wr1 = new CreateAccount.WrapperRecords();
        wr1.pivaOrCf = listAcc[0].CF__c;
        wr1.tipoDiRicerca = 'piva';


        String prova1 = JSON.serialize(wr1);

                System.debug(prova1);

        Test.setMock(HttpCalloutMock.class, new WGC_HttpRequestController_MockImpl());
        Test.startTest();
        CreateAccount.getInformationAccount(prova1);
        
        Test.stopTest();
    }

    @isTest
    public static void getInformationAccount_Test_RS_sfdc(){        

        WGC_AllDataFactory.createLagKey();
        WGC_AllDataFactory.disattivaTrigger();
        List<Account> listAcc = WGC_AllDataFactory.createAccount(3,true);


        CreateAccount.WrapperRecords wr1 = new CreateAccount.WrapperRecords();
        wr1.ragioneSociale = listAcc[0].Name;
        wr1.provincia = listAcc[0].BillingState;
        wr1.tipoDiRicerca = 'ragioneSociale';

        String prova1 = JSON.serialize(wr1);

                System.debug(prova1);

        Test.setMock(HttpCalloutMock.class, new WGC_HttpRequestController_MockImpl());
        Test.startTest();
        CreateAccount.getInformationAccount(prova1);
        
        Test.stopTest();
    }

    @isTest
    public static void getOriginAccount(){        

        WGC_AllDataFactory.disattivaTrigger();
        List<Account> listAcc = WGC_AllDataFactory.createAccount(3,true);
       
        Test.startTest();
        CreateAccount.getOriginAccount(listAcc.get(0).id);
        
        Test.stopTest();
    }

    @isTest
    public static void saveAccount(){        
        WGC_AllDataFactory.createLagKey();          
        WGC_AllDataFactory.disattivaTrigger();
        List<Account> listAcc = WGC_AllDataFactory.createAccount(3,true);
        List<Contact> listContact = WGC_AllDataFactory.createContact(3,true);
        List<Comune__c> listComune = WGC_AllDataFactory.createComune(3,true);
        List<Ateco__c> listAteco = WGC_AllDataFactory.createAteco(3,true);
        // listAcc.get(0).Area__c = 'EE';
        listAcc.get(0).NaturaGiuridica__c = 'DI';
        listAcc.get(0).Origine__c='Ribes';
// System.debug('@ rea: '+listAcc.get(0).REA__c);
// System.debug('@ cciaa: '+listAcc.get(0).CCIAA__c);
// System.debug('@ area: '+listAcc.get(0).Area__c);
        update listAcc;
        Test.setMock(HttpCalloutMock.class, new WGC_HttpRequestController_MockImpl());
        Test.startTest();

        CreateAccount.setInformationAccount(listAcc.get(0));
        CreateAccount.setInformationAccount(null);
        CreateAccount.getselectOptions(listAcc.get(0), 'BillingStreetType__c');
        CreateAccount.getselectOptions_Ateco(listAteco[0].RAE__c);
        CreateAccount.getselectOptions_Rae('naturaGiuridica', 'sae');
        CreateAccount.getselectOptions_Nazione('Account', null,null);
        CreateAccount.getselectOptions_ComuniFromProvincia('Comuni', 'AG');
        CreateAccount.getPositionRecords();
        CreateAccount.getselectOptions_Sae('PF');
        CreateAccount.getselectOptions_Rae('PF', '615');
        CreateAccount.getAtecoElement('12.43');
        // CreateAccount.getContactFromDI(listAcc[0]);
        CreateAccount.getCS_CedacriSleepTime();
        CreateAccount.getUserInfo();
        CreateAccount.saveAccount(listAcc.get(0),null,'Referral','full',listContact.get(0));
        
        Test.stopTest();
    }

    @isTest
    public static void saveSoggettiCollegati_Fornitore(){        
        WGC_AllDataFactory.createLagKey();          

        WGC_AllDataFactory.disattivaTrigger();
        List<Account> listAcc = WGC_AllDataFactory.createAccount(3,true);
        List<Contact> listContact = WGC_AllDataFactory.createContact(3,true);

       
        Test.startTest();
        CreateAccount.saveSoggettiCollegati(listAcc.get(0).Id,listAcc.get(1).Id,'Fornitore');
        
        Test.stopTest();
    }

    @isTest
    public static void saveSoggettiCollegati_Cliente(){        
        WGC_AllDataFactory.createLagKey();          

        WGC_AllDataFactory.disattivaTrigger();
        List<Account> listAcc = WGC_AllDataFactory.createAccount(3,true);
        List<Contact> listContact = WGC_AllDataFactory.createContact(3,true);

       
        Test.startTest();
        CreateAccount.saveSoggettiCollegati(listAcc.get(0).Id,listAcc.get(1).Id,'Cliente');
        
        Test.stopTest();
    }

    @isTest
    public static void saveSoggettiCollegati_Referral(){        
        WGC_AllDataFactory.createLagKey();          

        WGC_AllDataFactory.disattivaTrigger();
        List<Account> listAcc = WGC_AllDataFactory.createAccount(3,true);
        List<Contact> listContact = WGC_AllDataFactory.createContact(3,true);

       
        Test.startTest();
        CreateAccount.saveSoggettiCollegati(listAcc.get(0).Id,listAcc.get(1).Id,'Referral');
        
        Test.stopTest();
    }

    @isTest
    public static void saveSoggettiCollegati_catch(){        

        WGC_AllDataFactory.createLagKey();          
        WGC_AllDataFactory.disattivaTrigger();
        List<Account> listAcc = WGC_AllDataFactory.createAccount(3,true);
        List<Contact> listContact = WGC_AllDataFactory.createContact(3,true);

       
        Test.startTest();
        CreateAccount.saveSoggettiCollegati(listAcc.get(0).Id,'1234','Referral');
        
        Test.stopTest();
    }

    @isTest
    public static void test_getInformationAccountFromRibes(){
        WGC_AllDataFactory.createLagKey();          

        WGC_AllDataFactory.disattivaTrigger();
        List<Account> listAcc = WGC_AllDataFactory.createAccount(3,true);
        String strListAcc = JSON.serialize(listAcc);

        CreateAccount.WrapperRecords wr1 = new CreateAccount.WrapperRecords();
        wr1.pivaOrCf = listAcc[0].CF__c;
        wr1.tipoDiRicerca = 'piva';
        wr1.ragioneSociale= 'Test';
        wr1.provincia='RM';
        wr1.estero =false;
        String strWR = JSON.serialize(wr1);

        Test.setMock(HttpCalloutMock.class, new WGC_HttpRequestController_MockImpl());
        Test.startTest();
        CreateAccount.getInformationAccountFromRibes(strWR,strListAcc);
        
        Test.stopTest();
    }
    @isTest
    public static void testSaveAccountConMockDiverso(){
        WGC_AllDataFactory.createLagKey();          
        WGC_AllDataFactory.disattivaTrigger();
        List<Account> listAcc = WGC_AllDataFactory.createAccount(3,true);
        List<Contact> listContact = WGC_AllDataFactory.createContact(3,true);
        List<Comune__c> listComune = WGC_AllDataFactory.createComune(3,true);
        List<Ateco__c> listAteco = WGC_AllDataFactory.createAteco(3,true);
        // listAcc.get(0).Area__c = 'EE';
        listAcc.get(0).NaturaGiuridica__c = 'DI';
        listAcc.get(0).Origine__c='Ribes';
        listAcc.get(0).CF__c='BSINCL89C22E063U';
// System.debug('@ rea: '+listAcc.get(0).REA__c);
// System.debug('@ cciaa: '+listAcc.get(0).CCIAA__c);
// System.debug('@ area: '+listAcc.get(0).Area__c);
        update listAcc;

        Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(new List<String>{
      TestMockUtils.PAYLOAD_RIBES_INFORMAZIONIPG
    }));
    // Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_SET_ANAGRAFICA_LIGHT_PG));
    Test.startTest();
    CreateAccount.saveAccount(listAcc.get(0),null,'Referral','full',listContact.get(0));

    Test.stopTest();
    }


    @isTest
    public static void testSaveAccountConMockDiversoPolonia(){
        WGC_AllDataFactory.createLagKey();          
        WGC_AllDataFactory.disattivaTrigger();

        List<Account> listAcc = WGC_AllDataFactory.createAccount(3,true);
        List<Contact> listContact = WGC_AllDataFactory.createContact(3,true);
        List<Comune__c> listComune = WGC_AllDataFactory.createComune(3,true);
        List<Ateco__c> listAteco = WGC_AllDataFactory.createAteco(3,true);
        listAcc.get(0).NDGGruppo__c=null;
        listContact.get(0).CodCatastaleLocNascita__c='A759';
// System.debug('@ rea: '+listAcc.get(0).REA__c);
// System.debug('@ cciaa: '+listAcc.get(0).CCIAA__c);
// System.debug('@ area: '+listAcc.get(0).Area__c);

        Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(new List<String>{
      TestMockUtils.PAYLOAD_RIBES_INFORMAZIONIPG
    }));    
    // Test.setMock(HttpCalloutMock.class, TestMockUtils.creaMockRispostaOk(TestMockUtils.PAYLOAD_SET_ANAGRAFICA_LIGHT_PG));
    Test.startTest();
    CreateAccount.saveAccount(listAcc.get(0),null,'Referral','full',listContact.get(0));
    CreateAccount.saveAccount(listAcc.get(0),null,'Referral','light',listContact.get(0));
    // CreateAccount.saveAccount(listAcc.get(1),null,'Referral','light',listContact.get(0));
    // CreateAccount.saveAccount(listAcc.get(2),null,'Referral','full',listContact.get(0));
    Test.stopTest();
    }
    
    @isTest
    public static void saveAccount_SV(){
        List<Comune__c> listComune = WGC_AllDataFactory.createComune(3,true);
        List<Ateco__c> listAteco = WGC_AllDataFactory.createAteco(3,true);
		
        // SV insertAccount Account: Account:{Name="PANINOTECA PK - S.R.L.", NaturaGiuridica__c=SRL, ProvinciaCCIAA__c=ME, REA__c=188154, PIVA__c=02717290833, VAT__c=02717290833, CF__c=02717290833, Origine__c=Ribes, CodiceIstituto3N__c=881, DettaglioSettore__c=56102, ShippingStreet=VIA GIORDANO BRUNO 63, ShippingCity=MESSINA, ShippingState=ME, ShippingPostalCode=98123, ShippingStreetName__c=GIORDANO BRUNO, ShippingStreetNumber__c=63, ShippingStreetType__c=VIA, BillingStreet=VIA GIORDANO BRUNO 63, BillingCity=MESSINA, BillingPostalCode=98123, BillingState=ME, BillingStreetName__c=GIORDANO BRUNO, BillingStreetNumber__c=63, BillingStreetType__c=VIA, StatoAnagrafica__c=ATTIVA, RecordTypeId=01258000000FIjdAAG, TAG_Controllante__c=NB Inbound, WGC_Originator__c=Web, WGC_Originator_dettaglio__c=FORM_MPMI}
        // SV source: 
        // SV zIgnoreErrors: false
        // SV tipoCensimento: light
        // SV contactDI: null

        WGC_AllDataFactory.createLagKey();
        WGC_AllDataFactory.creaImpServ();

        Account a = new Account(Name='PANINOTECA PK - S.R.L.', NaturaGiuridica__c='SRL', ProvinciaCCIAA__c='ME', REA__c='188154', PIVA__c='02717290833', VAT__c='02717290833', CF__c='02717290833', Origine__c='Ribes', CodiceIstituto3N__c='881', DettaglioSettore__c='56102', ShippingStreet='VIA GIORDANO BRUNO 63', ShippingCity='MESSINA', ShippingState='ME', ShippingPostalCode='98123', ShippingStreetName__c='GIORDANO BRUNO', ShippingStreetNumber__c='63', ShippingStreetType__c='VIA', BillingStreet='VIA GIORDANO BRUNO 63', BillingCity='MESSINA', BillingPostalCode='98123', BillingState='ME', BillingStreetName__c='GIORDANO BRUNO', BillingStreetNumber__c='63', BillingStreetType__c='VIA', StatoAnagrafica__c='ATTIVA', RecordTypeId='01258000000FIjdAAG', TAG_Controllante__c='NB Inbound', WGC_Originator__c='Web', WGC_Originator_dettaglio__c='FORM_MPMI');
            
        Test.setMock(HttpCalloutMock.class, new WGC_HttpRequestController_MockImpl());
        Test.startTest();

        CreateAccount.saveAccount(a,null,'','light',null);
        
        Test.stopTest();
    }

    @isTest
    public static void saveAccount_SV2(){
        List<Comune__c> listComune = WGC_AllDataFactory.createComune(3,true);
        List<Ateco__c> listAteco = WGC_AllDataFactory.createAteco(3,true);
		
        // SV insertAccount Account: Account:{Name="PANINOTECA PK - S.R.L.", NaturaGiuridica__c=SRL, ProvinciaCCIAA__c=ME, REA__c=188154, PIVA__c=02717290833, VAT__c=02717290833, CF__c=02717290833, Origine__c=Ribes, CodiceIstituto3N__c=881, DettaglioSettore__c=56102, ShippingStreet=VIA GIORDANO BRUNO 63, ShippingCity=MESSINA, ShippingState=ME, ShippingPostalCode=98123, ShippingStreetName__c=GIORDANO BRUNO, ShippingStreetNumber__c=63, ShippingStreetType__c=VIA, BillingStreet=VIA GIORDANO BRUNO 63, BillingCity=MESSINA, BillingPostalCode=98123, BillingState=ME, BillingStreetName__c=GIORDANO BRUNO, BillingStreetNumber__c=63, BillingStreetType__c=VIA, StatoAnagrafica__c=ATTIVA, RecordTypeId=01258000000FIjdAAG, TAG_Controllante__c=NB Inbound, WGC_Originator__c=Web, WGC_Originator_dettaglio__c=FORM_MPMI}
        // SV source: 
        // SV zIgnoreErrors: false
        // SV tipoCensimento: light
        // SV contactDI: null

        WGC_AllDataFactory.createLagKey();
        WGC_AllDataFactory.creaImpServ();

        Account a = new Account(PIVA__c='12803211007', BillingStreetNumber__c='70', ShippingStreetName__c='DI TORRE ARGENTINA', BillingCity='ROMA', StatoAnagrafica__c='ATTIVA', ProvinciaCCIAA__c='RM', REA__c='1401327', Origine__c='Ribes', Name='PANINOTECA BOOM BOOM DI SILVANO ANTONIETTI', CF__c='NTNSVN56A06A132N', CodiceIstituto3N__c='881', NaturaGiuridica__c='DI', Phone=null, RecordTypeId='01258000000FIjdAAG', ShippingCountry='ITALIA', ShippingCity='ROMA', BillingPostalCode='00186', Ateco__c='56.10.2', VAT__c='12803211007', DettaglioSettore__c='56102', BillingStreetName__c='DI TORRE ARGENTINA', ShippingStreet='VIA DI TORRE ARGENTINA 70', StatoCensimento__c='Richiesta evasa', RAE__c='660', BillingStreetType__c='VIA', BillingCountry='ITALIA', BillingStreet='VIA DI TORRE ARGENTINA 70', ShippingPostalCode='00186', ShippingStreetNumber__c='70', ShippingState='RM', SAE__c='615', BillingState='RM', ShippingStreetType__c='VIA');
        Contact c = new Contact(CodCatastaleLocNascita__c='A132', FirstName='SILVANO', LuogoEmissioneDoc__c='ALBANO LAZIALE', DataEmissioneDoc__c= Date.newInstance(2009,05,21), DataScadenzaDoc__c=Date.newInstance(2029,05,21), Birthdate=Date.newInstance(1956,01,06), CI3N_CF__c='881-NTNSVN56A06A132N', TipoDocumentoId__c='1', LuogoNascita__c='ALBANO LAZIALE', CF__c='NTNSVN56A06A132N', CodiceIstituto3N__c='881', EnteEmitettenteDocumento__c='ALBANO LAZIALE', TAECode__c='984', Sesso__c='M', LastName='ANTONIETTI', SAE__c='600', NumeroDoc__c='AZ1029283');

        Test.setMock(HttpCalloutMock.class, new WGC_HttpRequestController_MockImpl());
        Test.startTest();

        CreateAccount.saveAccount(a,null,'','full',c);
        
        Test.stopTest();
    }
}