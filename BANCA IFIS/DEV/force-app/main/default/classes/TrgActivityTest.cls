/**
* Progetto:         Banca IFIS
* Sviluppata il:    12/12/2016
* Developer:        Zerbinati Francesco
*/

@isTest
public with sharing class TrgActivityTest {
  @testSetup
  static void dataSetup() {
    TestUtils.impostaCS();

    User dora = TestUtils.creaUtente('dora');
    User maria = TestUtils.creautente('maria');
    User daniela = TestUtils.creautente('daniela');
    User angela = TestUtils.creautente('angela');

    User admin = [SELECT Id FROM User WHERE Alias = 'super'];
    UserRole ruoloFD = [SELECT Id, DeveloperName FROM UserRole WHERE developername = 'OperatoreFiloDiretto'];
    UserRole ruoloCommerciale = [SELECT Id, DeveloperName FROM UserRole WHERE developername = 'CommercialeAncona'];
    UserRole ruoloDebitori = [SELECT Id, DeveloperName FROM UserRole WHERE developername = 'GestoreDebitori'];

    System.runAs(admin) {
      dora.UserRoleId = ruoloFD.Id;
      angela.UserRoleId = ruoloFD.Id;
      maria.UserRoleId = ruoloCommerciale.Id;
      daniela.UserRoleId = ruoloDebitori.Id;


      update dora;
      update angela;
      update maria;
      update daniela;
    }

    Account a = TestUtils.creaAccountFD('A',dora);
    Account b = TestUtils.creaAccount('B', daniela);
    Account accDan = TestUtils.creaAccountDEB('C', daniela);
    
    Contact c = TestUtils.creaReferente(a);
    update c;

	System.runAs(dora) {
    Task t = TestUtils.creaTask(a,'Prova Diretto','ContattoTelefonicoDiretto');
    t.WhoId = c.id;
    update t;
	}

    TestUtils.creaTask(a,'Prova Indiretto','ContattoTelefonicoIndiretto');

    Test.startTest();
    TestUtils.creaTask(b,'t1','ContattoTelefonicoDiretto');
    TestUtils.creaTask(b,'t2','ContattoTelefonicoDiretto');
    TestUtils.creaTask(a,'t3','ContattoTelefonicoIndiretto');

    TestUtils.creaEvento(a,c, 'Visita commerciale', 'VisitaCommerciale');
    Test.stopTest();
    //TestUtils.creaEvento(a,c, 'Visita per lista', 'FactoringIndirettoVisitaPerLista');

    insert new Impostazioni__c(Id_Covisian__c = '0054H000006mQupQAE,0053G000000V6yoQAC', MailNPL__c = 'test@test.com', MailRendimax__c = 'test@test.com');

  }

  @isTest
  static void testFlagFuoriMagazzinoDiretto() {
    Task t = [SELECT Id FROM Task WHERE Subject = 'Prova Diretto'];
    t.TipoAttivita__c='Sviluppo Diretto';
    t.OwnerId = UserInfo.getUserId();
    settaEsiti(t, new List<String> {'Azienda irreperibile','Informazioni errate'});
      
    //Account a = [SELECT Id, FuoriMagazzino__c FROM Account WHERE Name = 'A'];
    //System.assertEquals(true,a.FuoriMagazzino__c);
  }


  @isTest
  static void testInvioEmailRendimax() {
    Task t = [SELECT Id FROM Task WHERE Subject = 'Prova Diretto'];
    t.TipoAttivita__c='Sviluppo Diretto';
    t.OwnerId = UserInfo.getUserId();
    settaEsiti(t,new List<String> {'Azienda in target','Esigenza fuori target', 'Prodotti richiesti', 'Apertura C/Deposito'});
  }

  @isTest
  static void testInvioEmailNpl() {
    Task t = [SELECT Id FROM Task WHERE Subject = 'Prova Diretto'];
    t.TipoAttivita__c='Sviluppo Diretto';
    t.OwnerId = UserInfo.getUserId();
    settaEsiti(t,new List<String> {'Azienda in target','Esigenza fuori target', 'Tipologia credito', 'Crediti deteriorati / in contenzioso'});
  }

  @isTest
  static void testInvioEmailReferente() {
    Task t = [SELECT Id FROM Task WHERE Subject = 'Prova Diretto'];
    t.TipoAttivita__c='Sviluppo Diretto';
    t.OwnerId = UserInfo.getUserId();
    settaEsiti(t,new List<String> {'Azienda irreperibile','No interlocutore corretto'});
  }

  @isTest
  static void testCreazioneTaskRicontatto() {
      Test.startTest();
    Task t = [SELECT Id,WGC_Macro_Esito__c FROM Task WHERE Subject = 'Prova Indiretto'];


    // t.EsitoLivello1__c = 'Azienda da risentire';
    // t.EsitoLivello2__c = 'Recall fissata in agenda';
    // t.EsitoLivello1__c='Gestione rapporto';
    t.EsitoLivello1__c='Da risentire';
    t.EsitoLivello2__c='Filtro';
    t.DataRicontatto__c = Date.today().addMonths(1);
    // t.WGC_Macro_Esito__c ='Neutro';
    t.TipoAttivita__c='Sviluppo Diretto';
    t.CommentiEsito__c = 'Commento test';
    t.OwnerId = UserInfo.getUserId();
    System.debug('@Task: '+JSON.serialize(t));
    update t;

    Task[] newt = [SELECT Id, OwnerId FROM Task WHERE Subject = :Label.RicontattoTelefonico];

    System.assertNotEquals(0,newt.size());
    Test.stopTest();
  }

  @isTest
  static void testFlagFuoriMagazzinoVCommerciale() {
    Event e = [SELECT Id FROM Event LIMIT 1];
    e.TipoAttivita__c='Sviluppo Diretto';
    e.OwnerId = UserInfo.getUserId();
    settaEsiti(e, new List<String> {'Azienda fuori target','Esigenza fuori target','Prodotti richiesti','Finan. A Fondo Perduto / Agevolato'});
    //Account a = [SELECT Id, FuoriMagazzino__c FROM Account WHERE Name = 'A'];
    //System.assertEquals(false,a.FuoriMagazzino__c);
  }

//TODO: attendere che luigi metta dentro la visita per lista
/*
  @isTest
  static void testFlagFuoriMagazzinoVPerLista() {
    Event e = [SELECT Id FROM Event WHERE Subject = 'Visita per lista'];
    settaEsiti(e, new List<String> {'Lista cedenti ricevuta','Inserita lista cedenti'});

    Account a = [SELECT Id, FuoriMagazzino__c FROM Account WHERE Name = 'A'];
    System.assertEquals(true,a.FuoriMagazzino__c);
  }
*/


  @isTest
  static void testControlloCancellazioneActivity() {
    Test.startTest();
    Boolean exceptionThrown = false;
    Event e = [SELECT Id FROM Event LIMIT 1];
    Task t = [SELECT Id FROM Task WHERE Subject = 'Prova Diretto'];
    Task t2 = [SELECT Id FROM Task WHERE Subject = 'Prova Indiretto'];

    User dora = [SELECT id, Alias FROM User WHERE Alias = 'dora'];
    User maria = [SELECT id, Alias FROM User WHERE Alias = 'maria'];
    User daniela = [SELECT id, Alias FROM User WHERE Alias = 'daniela'];
    User admin = [SELECT Id FROM User WHERE Alias = 'super'];

    //ORA SONO MARIA: (operatore commerciale) test task non chiuso  --> non dovrebbe poterlo cancellare perchè operatore commerciale
    update t;
    System.runAs(maria) {
      try {
        delete t;
      } catch (DmlException ex) {
        exceptionThrown = true;
      }
      System.assert(exceptionThrown);

      exceptionThrown = false;
      //SONO ANCORA MARIA --> provo  la stessa cosa ma con l'evento
      try {
        delete e;
      } catch (DmlException ex) {
        exceptionThrown = true;
      }
      System.assert(exceptionThrown);
      //SONO ANCORA MARIA --> ora divento owner dell'evento ma non posso comunque cancellarlo (sono commerciale)
      exceptionThrown = false;
      System.runAs(admin) {
        e.OwnerId = maria.id;
        update e;
      }
      try {
        delete e;
      } catch (DmlException ex) {
        System.debug(ex.getDmlMessage(0));
            exceptionThrown = true;
      }
      System.assert(exceptionThrown);
    }

    exceptionThrown = false;
    //ORA SONO DANIELA: (operatore commerciale) test task non chiuso  --> non dovrebbe poterlo cancellare perchè operatore commerciale
    update t;
    System.runAs(daniela) {
      try {
        delete t;
      } catch (DmlException ex) {
            exceptionThrown = true;
      }
      System.assert(exceptionThrown);
    }
    exceptionThrown = false;

    //SONO ANCORA DORA: (operatore filo diretto) test task Aperto --> deve poterlo eliminare
    System.runAs(dora) {
      try {
        delete t2;
      } catch (DmlException ex) {
            exceptionThrown = true;
      }
      System.assert(!exceptionThrown);
    }
    Test.stopTest();
  }
  
    /*
  @isTest
  static void testControlloCambioOwnerTask() {
    Task tDirettoDora = [SELECT Id FROM Task WHERE Subject = 'Prova Diretto'];
    Task tIndirettoDora = [SELECT Id FROM Task WHERE Subject = 'Prova Indiretto'];

    User dora = [SELECT id, Alias FROM User WHERE Alias = 'dora'];
    User maria = [SELECT id, Alias FROM User WHERE Alias = 'maria'];
    User daniela = [SELECT id, Alias FROM User WHERE Alias = 'daniela'];
    User angela = [SELECT id, Alias FROM User WHERE Alias = 'angela'];

    Test.startTest();

    // sono Dora, di  filo diretto, e provo ad esitare un task di Daniela di tipo CT Indiretto. L'owner non deve cambiare!.
    System.runAs(dora) {
      Task t3 = [SELECT Id, What.Name, Owner.Name FROM Task WHERE Subject = 't3'];
      System.debug('@@@ t3 ' + JSON.serialize(t3)); 
      t3.TipoAttivita__c='Sviluppo Diretto';
      t3.EsitoLivello1__c = 'Azienda non interessata';
      t3.EsitoLivello2__c = 'Debitore non collaborativo';
      t3.CommentiEsito__c = 'Commenti';
      t3.OwnerId = dora.Id;
      t3.Status = 'Chiuso';
      update t3;
      Task expectedTask = [SELECT Id, OwnerId FROM Task WHERE Subject = 't3'];
      //controllo che il task sia rimasto a Daniela
      System.assertEquals(daniela.id, expectedTask.OwnerId);

      //sono sempre Dora, stavolta esito un task di tipo CT diretto. Il task deve diventare mio
      Task t2 = [SELECT Id FROM Task WHERE Subject = 't2'];
      t2.TipoAttivita__c='Sviluppo Diretto';
      t2.EsitoLivello1__c = 'Azienda irreperibile';
      t2.EsitoLivello2__c = 'Informazioni errate';
      t2.CommentiEsito__c = 'Commenti';
      t2.OwnerId = angela.Id;
      t2.Status = 'Chiuso';
      update t2;
      expectedTask = [SELECT Id, OwnerId FROM Task WHERE Subject = 't2'];
      //controllo che il task abbia cambiato owner (deve diventare di dora)
      System.assertEquals(dora.id, expectedTask.OwnerId);
    }
    Test.stopTest();

  }
*/

  @isTest
  static void testBloccaEsitoSeFiloDiretto() {
    // TODO TEST
    try {
      TrgActivity.bloccaEsitoSeFiloDiretto(new Task[]{null, null});
    } catch (Exception e) {
    }
  }

  @isTest static void testGestisciSegnalazioni(){
    Test.startTest();
    User daniela = [SELECT id, Alias FROM User WHERE Alias = 'daniela'];
    Account c = [SELECT Id, OwnerId FROM Account WHERE Name = 'C'];
      Task a = TestUtils.creaTask(c, 't4', 'Segnalazione');
	  List<Task> tasks = [SELECT Id FROM Task WHERE WhatId = :a.WhatId];  
    Test.stopTest();
  }



  /*** metodo di appoggio ***/

  static void settaEsiti(SObject t, List<String> esiti) {
    Test.startTest();
    for(Integer i = 0; i < esiti.size(); i++){
      t.put('EsitoLivello'+ (i+1) + '__c', esiti[i]);
    }
    t.put('CommentiEsito__c', 'Commento test');
    update t;

    Test.stopTest();
  }
}