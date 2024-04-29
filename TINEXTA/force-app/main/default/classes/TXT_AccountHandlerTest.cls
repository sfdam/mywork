@isTest
private class TXT_AccountHandlerTest {

    @TestSetup
    static void makeData(){
        List<Account> testAccList = TestDataFactory.createAccounts(1);
        testAccList.get(0).Forma_giuridica__c = 'PERSONA FISICA';
        insert testAccList;
    }

    @isTest
    private static void searchAccountByCFTest(){
        System.debug('searchAccountByCFTest Start');
        Account testAcc = [SELECT Codice_Fiscale__c FROM Account WHERE Forma_giuridica__c = 'PERSONA FISICA' LIMIT 1];

        Test.startTest();
            List<Account> accList = TXT_AccountHandler.searchAccountByCF(testAcc.Codice_Fiscale__c);
        Test.stopTest();

        System.assertEquals(true, accList.size() > 0, 'searchAccountByCFTest');
        System.debug('searchAccountByCFTest End');
    }

    @isTest
    private static void searchAccountByPIVATest(){
        System.debug('searchAccountByPIVATest Start');
        Account testAcc = [SELECT Partita_iva__c FROM Account LIMIT 1];

        Test.startTest();
            List<Account> accList = TXT_AccountHandler.searchAccountByCFPIVA(testAcc.Partita_iva__c);
        Test.stopTest();

        System.assertEquals(true, accList.size() > 0, 'searchAccountByPIVATest');
        System.debug('searchAccountByPIVATest End');
    }

    @isTest
    private static void searchAccountByNameTest(){
        System.debug('searchAccountByNameTest Start');
        Account testAcc = [SELECT Name FROM Account LIMIT 1];

        Test.startTest();
            List<Account> accList = TXT_AccountHandler.searchAccountByName(testAcc.Name);
        Test.stopTest();

        System.assertEquals(true, accList.size() > 0, 'searchAccountByNameTest');
        System.debug('searchAccountByNameTest End');
    }

    @isTest
    private static void searchAccountByIdTest(){
        System.debug('searchAccountByIdTest Start');
        Account testAcc = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
            List<Account> accList = TXT_AccountHandler.searchAccountById(testAcc.Id);
        Test.stopTest();

        System.assertEquals(true, accList.size() > 0, 'searchAccountByIdTest');
        System.debug('searchAccountByIdTest End');
    }

    @isTest
    private static void insertAccountTest(){
        System.debug('insertAccountTest Start');
        String name = 'NameForInsertAccountMethod###true';
        String partitaIva = '01234567890';
        String codiceFiscale = '01234567890';
        String ragioneSociale = 'Test test SpA';
        String cciaa = 'ba###7890';
        String naturaGiuridica = '';
        String via = '';
        String citta = '';
        String provincia = '';
        String cap = '';
        String paese = 'AUSTRIA';
        Date dataBilancio = Date.today();
        Double acquistiTotali = 0.0;
        Date dataCessazione = Date.today();
        String annoRilevazioneAddetti = '';
        Date dataInizioAttivita = Date.today();
        Double annualRevenue = 0.0;
        String livelloAttenzioneNegativita = '';
        Double capitaleSociale = 0.0;
        Double creditiVsClienti = 0.0;
        Double risultatoOperativoLordo = 0.0;
        String phone = '3001234567';
        String email = '';
        Double totalePatrimonioNetto = 0.0;
        String fax = '';
        Double utilePerdita = 0.0;
        String statoAttivita = '';
        String fatturato = '';
        String rating = '';
        String dipendenti = '';
        String codiceAteco = '';
        String descrizioneAteco = '';
        Boolean clienteEstero = true;

        TXT_AccountHandler.AccountWrapper acc = new TXT_AccountHandler.AccountWrapper();
        acc.name = name;
        acc.partitaIva = partitaIva;
        acc.codiceFiscale = codiceFiscale;
        acc.ragioneSociale = ragioneSociale;
        acc.cciaa = cciaa;
        acc.naturaGiuridica = naturaGiuridica;
        acc.via = via;
        acc.citta = citta;
        acc.provincia = provincia;
        acc.cap = cap;
        acc.paese = paese;
        acc.dataBilancio = dataBilancio;
        acc.acquistiTotali = acquistiTotali;
        acc.dataCessazione = dataCessazione;
        acc.annoRilevazioneAddetti = annoRilevazioneAddetti;
        acc.dataInizioAttivita = dataInizioAttivita;
        acc.annualRevenue = annualRevenue;
        acc.livelloAttenzioneNegativita = livelloAttenzioneNegativita;
        acc.capitaleSociale = capitaleSociale;
        acc.creditiVsClienti = creditiVsClienti;
        acc.risultatoOperativoLordo = risultatoOperativoLordo;
        acc.phone = phone;
        acc.email = email;
        acc.totalePatrimonioNetto = totalePatrimonioNetto;
        acc.fax = fax;
        acc.utilePerdita = utilePerdita;
        acc.statoAttivita = statoAttivita;
        acc.fatturato = fatturato;
        acc.rating = rating;
        acc.dipendenti = dipendenti;
        acc.codiceAteco = codiceAteco;
        acc.descrizioneAteco = descrizioneAteco;
        acc.clienteEstero = clienteEstero;
        acc.erroreMonitoraggio = false;


        Test.startTest();
            // TXT_AccountHandler.insertAccount(name, partitaIva, codiceFiscale, ragioneSociale,
            //                                 cciaa, naturaGiuridica, via, citta, provincia, cap,
            //                                 paese, dataBilancio, acquistiTotali, dataCessazione,
            //                                 annoRilevazioneAddetti, dataInizioAttivita, annualRevenue,
            //                                 livelloAttenzioneNegativita, capitaleSociale, creditiVsClienti,
            //                                 risultatoOperativoLordo, phone, email, totalePatrimonioNetto,
            //                                 fax, utilePerdita, statoAttivita, fatturato, rating,
            //                                 dipendenti, codiceAteco, descrizioneAteco);

            TXT_AccountHandler.insertAccount(acc);
        Test.stopTest();

        List<Account> accTestList = [SELECT id FROM Account WHERE name = 'NameForInsertAccountMethod'];
        System.assertEquals(true, accTestList.size() > 0, 'insertAccountTest');
        System.debug('insertAccountTest End');
    }

    @isTest
    private static void insertAccountTest2(){
        System.debug('insertAccountTest Start');
        String name = 'NameForInsertAccountMethod###true';
        String partitaIva = '01234567890';
        String codiceFiscale = '01234567890';
        String ragioneSociale = 'Test test SpA';
        String cciaa = 'ba###7890';
        String naturaGiuridica = '';
        String via = '';
        String citta = '';
        String provincia = '';
        String cap = '';
        String paese = 'ITALIA';
        Date dataBilancio = Date.today();
        Double acquistiTotali = 0.0;
        Date dataCessazione = Date.today();
        String annoRilevazioneAddetti = '';
        Date dataInizioAttivita = Date.today();
        Double annualRevenue = 0.0;
        String livelloAttenzioneNegativita = '';
        Double capitaleSociale = 0.0;
        Double creditiVsClienti = 0.0;
        Double risultatoOperativoLordo = 0.0;
        String phone = '3001234567';
        String email = '';
        Double totalePatrimonioNetto = 0.0;
        String fax = '';
        Double utilePerdita = 0.0;
        String statoAttivita = '';
        String fatturato = '';
        String rating = '';
        String dipendenti = '';
        String codiceAteco = '';
        String descrizioneAteco = '';
        Boolean clienteEstero = false;

        TXT_AccountHandler.AccountWrapper acc = new TXT_AccountHandler.AccountWrapper();
        acc.name = name;
        acc.partitaIva = partitaIva;
        acc.codiceFiscale = codiceFiscale;
        acc.ragioneSociale = ragioneSociale;
        acc.cciaa = cciaa;
        acc.naturaGiuridica = naturaGiuridica;
        acc.via = via;
        acc.citta = citta;
        acc.provincia = provincia;
        acc.cap = cap;
        acc.paese = paese;
        acc.dataBilancio = dataBilancio;
        acc.acquistiTotali = acquistiTotali;
        acc.dataCessazione = dataCessazione;
        acc.annoRilevazioneAddetti = annoRilevazioneAddetti;
        acc.dataInizioAttivita = dataInizioAttivita;
        acc.annualRevenue = annualRevenue;
        acc.livelloAttenzioneNegativita = livelloAttenzioneNegativita;
        acc.capitaleSociale = capitaleSociale;
        acc.creditiVsClienti = creditiVsClienti;
        acc.risultatoOperativoLordo = risultatoOperativoLordo;
        acc.phone = phone;
        acc.email = email;
        acc.totalePatrimonioNetto = totalePatrimonioNetto;
        acc.fax = fax;
        acc.utilePerdita = utilePerdita;
        acc.statoAttivita = statoAttivita;
        acc.fatturato = fatturato;
        acc.rating = rating;
        acc.dipendenti = dipendenti;
        acc.codiceAteco = codiceAteco;
        acc.descrizioneAteco = descrizioneAteco;
        acc.clienteEstero = clienteEstero;
        acc.erroreMonitoraggio = false;

        Test.startTest();
            // TXT_AccountHandler.insertAccount(name, partitaIva, codiceFiscale, ragioneSociale,
            //                                 cciaa, naturaGiuridica, via, citta, provincia, cap,
            //                                 paese, dataBilancio, acquistiTotali, dataCessazione,
            //                                 annoRilevazioneAddetti, dataInizioAttivita, annualRevenue,
            //                                 livelloAttenzioneNegativita, capitaleSociale, creditiVsClienti,
            //                                 risultatoOperativoLordo, phone, email, totalePatrimonioNetto,
            //                                 fax, utilePerdita, statoAttivita, fatturato, rating,
            //                                 dipendenti, codiceAteco, descrizioneAteco);
            TXT_AccountHandler.insertAccount(acc);
        Test.stopTest();

        List<Account> accTestList = [SELECT id FROM Account WHERE name = 'NameForInsertAccountMethod'];
        System.assertEquals(true, accTestList.size() > 0, 'insertAccountTest');
        System.debug('insertAccountTest End');
    }

    @isTest
    private static void insertAccountTest3(){
        System.debug('insertAccountTest Start');
        String name = 'NameForInsertAccountMethod###true';
        // String partitaIva = '01234567890';
        String partitaIva;
        String codiceFiscale = '01234567890';
        String ragioneSociale = 'Test test SpA';
        String cciaa = 'ba###7890';
        String naturaGiuridica = '';
        String via = '';
        String citta = '';
        String provincia = '';
        String cap = '';
        String paese = 'ITALIA';
        Date dataBilancio = Date.today();
        Double acquistiTotali = 0.0;
        Date dataCessazione = Date.today();
        String annoRilevazioneAddetti = '';
        Date dataInizioAttivita = Date.today();
        Double annualRevenue = 0.0;
        String livelloAttenzioneNegativita = '';
        Double capitaleSociale = 0.0;
        Double creditiVsClienti = 0.0;
        Double risultatoOperativoLordo = 0.0;
        String phone = '3001234567';
        String email = '';
        Double totalePatrimonioNetto = 0.0;
        String fax = '';
        Double utilePerdita = 0.0;
        String statoAttivita = '';
        String fatturato = '';
        String rating = '';
        String dipendenti = '';
        String codiceAteco = '';
        String descrizioneAteco = '';
        Boolean clienteEstero = false;

        TXT_AccountHandler.AccountWrapper acc = new TXT_AccountHandler.AccountWrapper();
        acc.name = name;
        acc.partitaIva = partitaIva;
        acc.codiceFiscale = codiceFiscale;
        acc.ragioneSociale = ragioneSociale;
        acc.cciaa = cciaa;
        acc.naturaGiuridica = naturaGiuridica;
        acc.via = via;
        acc.citta = citta;
        acc.provincia = provincia;
        acc.cap = cap;
        acc.paese = paese;
        acc.dataBilancio = dataBilancio;
        acc.acquistiTotali = acquistiTotali;
        acc.dataCessazione = dataCessazione;
        acc.annoRilevazioneAddetti = annoRilevazioneAddetti;
        acc.dataInizioAttivita = dataInizioAttivita;
        acc.annualRevenue = annualRevenue;
        acc.livelloAttenzioneNegativita = livelloAttenzioneNegativita;
        acc.capitaleSociale = capitaleSociale;
        acc.creditiVsClienti = creditiVsClienti;
        acc.risultatoOperativoLordo = risultatoOperativoLordo;
        acc.phone = phone;
        acc.email = email;
        acc.totalePatrimonioNetto = totalePatrimonioNetto;
        acc.fax = fax;
        acc.utilePerdita = utilePerdita;
        acc.statoAttivita = statoAttivita;
        acc.fatturato = fatturato;
        acc.rating = rating;
        acc.dipendenti = dipendenti;
        acc.codiceAteco = codiceAteco;
        acc.descrizioneAteco = descrizioneAteco;
        acc.clienteEstero = clienteEstero;
        acc.erroreMonitoraggio = false;

        Test.startTest();
            // TXT_AccountHandler.insertAccount(name, partitaIva, codiceFiscale, ragioneSociale,
            //                                 cciaa, naturaGiuridica, via, citta, provincia, cap,
            //                                 paese, dataBilancio, acquistiTotali, dataCessazione,
            //                                 annoRilevazioneAddetti, dataInizioAttivita, annualRevenue,
            //                                 livelloAttenzioneNegativita, capitaleSociale, creditiVsClienti,
            //                                 risultatoOperativoLordo, phone, email, totalePatrimonioNetto,
            //                                 fax, utilePerdita, statoAttivita, fatturato, rating,
            //                                 dipendenti, codiceAteco, descrizioneAteco);
            TXT_AccountHandler.insertAccount(acc);
            TXT_AccountHandler.insertAccount(acc);
        Test.stopTest();

        List<Account> accTestList = [SELECT id FROM Account WHERE name = 'NameForInsertAccountMethod'];
        System.assertEquals(true, accTestList.size() > 0, 'insertAccountTest');
        System.debug('insertAccountTest End');
    }

    @isTest
    static void test_isOverrideActionAccount(){


        Test.startTest();
            TXT_AccountHandler.isOverrideActionAccount();
            TXT_AccountHandler t = new TXT_AccountHandler();
        Test.stopTest();
    }

}