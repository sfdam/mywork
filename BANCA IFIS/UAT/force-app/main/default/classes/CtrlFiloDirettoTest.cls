/**
* Progetto:         Banca IFIS
* Sviluppata il:    14/12/2016
* Developer:        Zerbinati Francesco
*/

@isTest
public with sharing class CtrlFiloDirettoTest {

  public static String CONTATTO_CF = 'AAAAA';
  @testSetup
  static void dataSetup() {
    Funzionalita__c f = Funzionalita__c.getInstance();
    f.DisabilitaCreazioneCTDopoInsertAcc__c = true;
    f.ControlloCodiceFiscale__c = false;
    upsert f;

    TestUtils.impostaCS();

    //dora è responsabile filo diretto, maria è una commerciale
    User dora = TestUtils.creaUtente('dora');
    User maria = TestUtils.creautente('maria');
    maria.Email = 'test@test.com';
    dora.Email = 'test2@test.com';
    maria.Filiale__c = '0';
    dora.Filiale__c = '0';
    maria.ManagerId = dora.id;

    UserRole ruoloFD = [SELECT Id, DeveloperName FROM UserRole WHERE developername = 'ResponsabileFiloDiretto'];
    UserRole ruoloCommerciale = [SELECT Id, DeveloperName FROM UserRole WHERE developername = 'CommercialeAncona'];
    System.runAs(new User(Id = UserInfo.getUserId())) {
      dora.UserRoleId = ruoloFD.Id;
      maria.UserRoleId = ruoloCommerciale.Id;
      update dora;
      update maria;
    }

    Account a = TestUtils.creaAccount('FDaccount', dora);
    Account b = TestUtils.creaAccount('FDaccount', maria);
    Contact c = TestUtils.creaReferente(a, CONTATTO_CF);
    Test.startTest();
    TestUtils.creaTask(a, 'Prova Diretto', 'ContattoTelefonicoDiretto');
    TestUtils.creaTask(a, 'Prova Diretto 2', 'ContattoTelefonicoDiretto');
    TestUtils.creaTask(a, 'Prova Indiretto', 'ContattoTelefonicoIndiretto');
    Testutils.creaTask(b, 'Prova Diretto 3', 'ContattoTelefonicoDiretto');
    Comune__c com = Testutils.creaComune('MILANO', 'MILANO', '20155');
    Testutils.creaAssegnazioneAnagrafica(maria, com);

    TestUtils.creaEvento(a, c, 'Visita commerciale', 'VisitaCommerciale');
    Test.stopTest();
    //TestUtils.creaEvento(a,c, 'Visita per lista', 'FactoringIndirettoVisitaPerLista');

    Impostazioni__c impostazioni = new Impostazioni__c(
      MailFiloDiretto__c = 'test@test.com',
      MailCCNFiloDiretto__c = 'test@test.com',
      Id_Covisian__c = '0054H000006mQupQAE,0053G000000V6yoQAC'
    );
    insert impostazioni;
  }

  @isTest
  static void testFetchTasks() {
    //trova solo i task di tipo ContattoTelefonicoDiretto dell'account di dora, che è responsabile di filo diretto
    Test.startTest();
    List<Task> lista = CtrlFiloDiretto.fetchTasks('*', false, false, '');
    Test.stopTest();

    System.assertEquals(2, lista.size());
  }

  @isTest
  static void testCreateTask() {
    Contact c = [SELECT Id FROM Contact WHERE CF__c = :CONTATTO_CF];

    Test.startTest();
    CtrlFiloDiretto.createTask(c.Id);
    Test.stopTest();
  }

  @isTest
  static void testAssignTask() {
    Task t = [SELECT Id FROM Task WHERE Subject = 'Prova Diretto'];
    Test.startTest();
    Id ownerId = CtrlFiloDiretto.assignTask(t);
    Test.stopTest();
    System.assertEquals(ownerId, UserInfo.getUserId());
    t = [SELECT Id, NonContattareFinoA__c FROM Task WHERE Subject = 'Prova Diretto'];
    System.assertNotEquals(t.NonContattareFinoA__c, null);
  }

  @isTest
  static void testFetchEvents() {
    List<User> users = [SELECT Id From User WHERE Email IN ('test@test.com', 'test2@test.com') LIMIT 10];
    List<Id> userIds = U.toList(U.getSet(users, 'Id'));
    Test.startTest();
    List<Event> lista = CtrlFiloDiretto.fetchEvents(Date.today().format(), userIds);
    System.assertEquals(1, lista.size());
    Test.stopTest();
  }

  @isTest
  static void testFetchContact() {
    Contact c = [SELECT Id FROM Contact LIMIT 1];
    Test.startTest();
    CtrlFiloDiretto.fetchContact(c.Id);
    Test.stopTest();
  }

  @isTest
  static void testFetchAccount() {
    Account a = [SELECT Id FROM Account LIMIT 1];
    Test.startTest();
    CtrlFiloDiretto.fetchAccount(a.Id);
    Test.stopTest();
  }

  @isTest
  static void testGetMatriceEsiti() {
    Test.startTest();
    CtrlFiloDiretto.getMatriceEsiti();
    Test.stopTest();
  }

  /*@isTest
  static void testEsitaTask() {
    WGC_AlldataFactory.disattivaTrigger();
    // TEST SU: record type ContattoTelefonicoDiretto, con i seguenti esiti: (dovrebbe dare fine)
    Task t = [SELECT Id, RecordTypeDevName__c, EsitoLivello1__c, EsitoLivello2__c, CommentiEsito__c, Status, whatId FROM Task WHERE Subject = 'Prova Diretto'];
    // Task t =WGC_AlldataFactory.createTask(1,false).get(0);
    System.debug('@task --> '+t);
    t.EsitoLivello1__c = 'Azienda fuori target';
    t.EsitoLivello2__c = 'Azienda non gradita';
    t.CommentiEsito__c = 'Commenti';

    Test.startTest();
    String azione = CtrlFiloDiretto.esitaTask(t);
    Test.stopTest();
    System.assertEquals(azione, 'FINE');
  }*/

  @isTest
  public static void test_esitaTask(){
    WGC_AlldataFactory.createUtenzaDefault();

    Task t =WGC_AlldataFactory.createTask(1,true).get(0);
    t.EsitoLivello1__c = 'Azienda fuori target';
    // t.EsitoLivello2__c = 'Azienda non gradita';
    t.TipoAttivita__c='Sviluppo Diretto';
    t.CommentiEsito__c = 'Commenti';
    t.OwnerId = UserInfo.getUserId();
    Test.startTest();
    CtrlFiloDiretto.esitaTask(t);
    Test.stopTest();




  }

  @isTest
  static void testOwnersEvento() {
    Account a = [SELECT Id FROM Account LIMIT 1];
    Test.startTest();
    //solo owner
    Map<String, User[]> mapExpected = CtrlFiloDiretto.ownersEvento(a.Id, 'MILANO'); // sicuramente sarà da fixare
    System.debug(mapExpected);
    System.assertEquals(1, mapExpected.get('Titolari').size());
    //owner + assegnazione anagrafica in base a CAP
    a.RecordTypeId = U.getRecordTypes('Account').get('Prospect').Id;
    a.ShippingPostalCode = '12345';
    update a;
    mapExpected = CtrlFiloDiretto.ownersEvento(a.Id, 'MILANO');

    System.assertEquals(2, mapExpected.values().size());
    System.assertEquals(1, mapExpected.get('Assegnazione territoriale').size());
    Test.stopTest();
  }

  @isTest
  static void testCreaEvento() {
    User maria = [SELECT Id, UserRoleId, UserRole.Developername FROM USER WHERE Alias = 'maria'];
    User dora = [SELECT Id, UserRoleId, UserRole.Developername FROM USER WHERE Alias = 'dora'];

    System.debug('maria ' + maria + 'user role name ' + maria.UserRole.Developername);
    Contact c = [SELECT Id, AccountId FROM Contact WHERE FirstName = 'Referente'];
    Event e = new Event();
    e.OwnerId = maria.Id;
    e.StartDateTime = Datetime.now();
    e.EndDateTime = Datetime.now().addHours(2);
    e.Subject = 'Test';
    e.WhoId = c.Id;
    e.WhatId = c.AccountId;
    e.Description = 'Descrizione test';
    Test.startTest();
    CtrlFiloDiretto.creaEvento(e);
    Test.stopTest();
  }

  /*@isTest
  static void testRiprogrammaTask() {
    Task t = [SELECT Id FROM Task WHERE Subject = 'Prova Diretto'];
    t.DataRicontatto__c = Date.today();
    Test.startTest();
    // CtrlFiloDiretto.riprogrammaTask(t);
    Test.stopTest();
  }*/

  

}