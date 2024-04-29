/**
* Progetto:         Banca IFIS
* Sviluppata il:    05/10/2016
* Developer:        Zerbinati Francesco, Giuliani Luigi, Michele Triaca
*/

@isTest
private class ExtRichiediAssegnazioneTest {

  @testSetup
  static void dataSetup() {

    User dora = TestUtils.creaUtente('dora');
    User manente = TestUtils.creaUtente('mane');
    User zucca = TestUtils.creaUtente('zucca');
    User passerini = TestUtils.creaUtente('passe');
    User eloisa = TestUtils.creaUtente('eloisa');

    dora.ManagerId = passerini.Id;
    dora.Qualifica_Utente__c = 'Crediti Erariali';
    zucca.ManagerId = eloisa.Id;
    zucca.Qualifica_Utente__c = 'Crediti Erariali';
    manente.ManagerId = eloisa.Id;

    update dora;
    update zucca;
    update manente;

    TestUtils.impostaCS();
    // System.runAs(dora){
    // 	Account a = TestUtils.creaAccount('A',dora);
    // 	a.ApprovatoreFinStrut__c=dora.id;
    // 	update a;
    // }
      
    // System.runAs(zucca){
    // 	Account z = TestUtils.creaAccount('Z',zucca);
    // 	z.ApprovatoreFinStrut__c=eloisa.id;
    // 	update z;
    // }


    System.runAs(zucca){
    	Account a = TestUtils.creaAccount('A',zucca);
    	a.ApprovatoreFinStrut__c=zucca.id;
    	update a;
    }
      
    System.runAs(dora){
    	Account z = TestUtils.creaAccount('Z',dora);
    	z.ApprovatoreFinStrut__c=eloisa.id;
    	update z;
    }      
  }


  @isTest
  static void instance(){
    Account a = [SELECT Id,Name,OwnerId, Owner.IsActive, StatoAssegnazione__c, Richiedente__c FROM Account WHERE Name = 'A'];
    new ExtRichiediAssegnazione(new ApexPages.StandardController(a));
    //TODO assert...
  }

  @isTest
  static void testRichiedi() {

    Account a = [SELECT Id,Name,OwnerId, Owner.IsActive, StatoAssegnazione__c, Richiedente__c FROM Account WHERE Name = 'A'];
    User dora = [SELECT Id, Alias, IsActive FROM User WHERE Alias = 'dora'];
    User zucca = [SELECT Id, Alias, IsActive FROM User WHERE Alias = 'zucca'];
    UserRole ruoloFD = [SELECT Id, DeveloperName FROM UserRole WHERE developername = 'ResponsabileFiloDiretto'];
    UserRole ruoloOK = [SELECT Id, DeveloperName FROM UserRole WHERE developername = 'CommercialeMilano'];
    UserRole ruolodebitore = [SELECT Id, DeveloperName FROM UserRole WHERE developername = 'ResponsabileGestioneDebitori'];
    User admin = [SELECT id FROM User WHERE Alias = 'super'];
	
    System.debug('@@@ aaa ' + a);
    Test.startTest();

    // user già owner dell'account, setto owner manualmente perchè un trigger
    // potrebbe averlo modificato
    a.OwnerId = dora.Id;
    update a;

    // in questo caso sono già owner, quindi dovrebbe dare eccezione
    System.runAs(dora) {
      Boolean exceptionThrown = false;
      try {
        ExtRichiediAssegnazione.richiediAssegnazione(a.Id, 'TEST');
      } catch(Ex.WsException e) {
        //Non puoi richiedere l'assegnazione di un prospect di cui sei già responsabile
        exceptionThrown = true;
      }
      System.assert(exceptionThrown);
    }

    // in questo caso è di utente default, quindi assegnazione subito
    /*
    a.OwnerId =  UtenzeDefault__c.getInstance().IdUtente__c;
    update a;
	*/
     
    System.debug('dora: ' + dora.Id);
    System.runAs(admin) {
      Account b = [SELECT Id,Name,OwnerId, Owner.IsActive, StatoAssegnazione__c FROM Account WHERE Name = 'A'];
      System.debug('@@@ b ' + b);
      ExtRichiediAssegnazione.richiediAssegnazione(a.Id, 'TEST');
      a = [SELECT Id,Name,OwnerId, Owner.IsActive, StatoAssegnazione__c FROM Account WHERE Name = 'A'];
    
      /*
      System.assertEquals(null, a.StatoAssegnazione__c);
      System.assertEquals(dora.Id, a.OwnerId);
		*/
        
    }

    a.OwnerId = dora.Id;
    a.RecordTypeId = U.getRecordTypes('Account').get('Prospect').Id;
    a.StatoAssegnazione__c = null;
    update a;

    System.runAs(admin) {
      zucca.UserRoleID = ruoloFD.id;
      update zucca;
            
      a.OwnerId =  UtenzeDefault__c.getInstance().IdUtente__c;
      update a;
    }
    System.runAs(zucca) {
      a = [SELECT Id,Name,OwnerId, Owner.IsActive, StatoAssegnazione__c FROM Account WHERE Name = 'A'];
      // in questo caso è di utente default, quindi assegnazione subito
	
      System.debug('@@@ zzz ' + a);
      ExtRichiediAssegnazione.richiediAssegnazione(a.Id, 'TEST');
      //a = [SELECT Id,Name,OwnerId, Owner.IsActive, StatoAssegnazione__c FROM Account WHERE Name = 'Z'];
      System.assertEquals(null, a.StatoAssegnazione__c);
    }

    Test.stopTest();
  }

  @isTest
  static void testRichiedi2() {

    Account a = [SELECT Id,Name,OwnerId, Owner.IsActive, StatoAssegnazione__c, Richiedente__c FROM Account WHERE Name = 'A'];
    Account z = [SELECT Id,Name,OwnerId, Owner.IsActive, StatoAssegnazione__c, Richiedente__c FROM Account WHERE Name = 'Z'];
    User dora = [SELECT Id, Alias, IsActive FROM User WHERE Alias = 'dora'];
    User zucca = [SELECT Id, Alias, IsActive FROM User WHERE Alias = 'zucca'];
    UserRole ruoloFD = [SELECT Id, DeveloperName FROM UserRole WHERE developername = 'ResponsabileFiloDiretto'];
    UserRole ruoloOK = [SELECT Id, DeveloperName FROM UserRole WHERE developername = 'CommercialeMilano'];
    UserRole ruolodebitore = [SELECT Id, DeveloperName FROM UserRole WHERE developername = 'ResponsabileGestioneDebitori'];
    User admin = [SELECT id FROM User WHERE Alias = 'super'];

    Test.startTest();

    System.runAs(admin) {
      zucca.UserRoleID = ruoloOK.id;
      update zucca;
      a.StatoAssegnazione__c = null;
      a.OwnerId = dora.Id;
      update a;
    }

    System.runAs(admin) {
      zucca.UserRoleID = ruoloOK.id;
      update zucca;
      z.StatoAssegnazione__c = null;
      z.OwnerId = zucca.Id;
      update z;
    }
    System.runAs(admin) {
      a = [SELECT Id,Name,OwnerId, Owner.IsActive, StatoAssegnazione__c, Richiedente__c FROM Account WHERE Name = 'A'];
      // in questo caso è di utente default, quindi assegnazione subito
      /*
      a.OwnerId =  UtenzeDefault__c.getInstance().IdUtente__c;
      update a;
		*/
        
      ExtRichiediAssegnazione.richiediAssegnazione(a.Id, 'TEST');
      //a = [SELECT Id,Name,OwnerId, Owner.IsActive, StatoAssegnazione__c, Richiedente__c FROM Account WHERE Name = 'Z'];
      //System.assertEquals(zucca.id, a.StatoAssegnazione__c);
      //System.assertEquals(zucca.id, a.Richiedente__c);
    }

    Test.stopTest();

  }


  @isTest
  static void testRichiedi3() {

    Account a = [SELECT Id,Name,OwnerId, Owner.IsActive, StatoAssegnazione__c, Richiedente__c FROM Account WHERE Name = 'A'];
    User dora = [SELECT Id, Alias, IsActive FROM User WHERE Alias = 'dora'];
    User zucca = [SELECT Id, Alias, IsActive FROM User WHERE Alias = 'zucca'];
    UserRole ruoloOK = [SELECT Id, DeveloperName FROM UserRole WHERE developername = 'CommercialeMilano'];
    User admin = [SELECT id FROM User WHERE Alias = 'super'];

    Test.startTest();

    System.runAs(admin) {
      zucca.UserRoleID = ruoloOK.id;
      update zucca;
      a.StatoAssegnazione__c = null;
      a.OwnerId = dora.Id;
      a.RecordTypeId = U.getRecordTypes('Account').get('Cliente').Id;
      update a;
    }


    System.runAs(admin) {
      a = [SELECT Id,Name,OwnerId, Owner.IsActive, StatoAssegnazione__c FROM Account WHERE Name = 'A'];
      // in questo caso è di utente default, quindi assegnazione subito
      /*
      a.OwnerId =  UtenzeDefault__c.getInstance().IdUtente__c;
      update a;
		*/
        
      ExtRichiediAssegnazione.richiediAssegnazione(a.Id, 'TEST');
      
      System.assertEquals(null, a.StatoAssegnazione__c);
    }

    Test.stopTest();

  }

  @isTest
  static void testRichiedi4() {

    Account a = [SELECT Id,Name,OwnerId, Owner.IsActive, StatoAssegnazione__c, Richiedente__c FROM Account WHERE Name = 'A'];
    User zucca = [SELECT Id, Alias, IsActive FROM User WHERE Alias = 'zucca'];
    UserRole ruolodebitore = [SELECT Id, DeveloperName FROM UserRole WHERE developername = 'ResponsabileGestioneDebitori'];
    User admin = [SELECT id FROM User WHERE Alias = 'super'];

    System.runAs(admin) {
      zucca.UserRoleID = ruolodebitore.id;
      update zucca;
      a.StatoAssegnazione__c = null;
      update a;
    }
    System.runAs(zucca) {
      Boolean exceptionThrown = false;
      try {
        ExtRichiediAssegnazione.richiediAssegnazione(a.Id, 'TEST');
      } catch(Ex.WsException e) {
        //Non puoi richiedere l'assegnazione con il tuo ruolo
        exceptionThrown = true;
      }
      System.assert(exceptionThrown);
    }
  }

}