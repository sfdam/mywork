/**
* Progetto:         Banca IFIS
* Developers:        Stefano Brivio, Dario Mapelli, Michele Triaca
*/
public without sharing class WsAnagrafeUtils {
  private static String ORIGINE_CEDACRI = 'Cedacri';

  @TestVisible
  private static void throwError(Exception e) {
    if(e instanceof Ex.WsCalloutException) throw e;
    throw new Ex.AnagrafeDiGruppoException(
      'Errore richiesta integration layer (cedacri): ' +
      e.getMessage() +
      '. Informazioni aggiuntive: ' +
      e.getStackTraceString()
    );
  }

  /**
   * Interroga Cedacri (getDatiAnagraficaCedacri) per ricevere informazioni aggiornate di una Persona Fisica/Ditta,
   * gestendo il mapping tra i valori salvati in Cedacri e Salesforce.
   * Se su CRM nè l'ndg nè il cf sono popolati, ritorna l'oggetto.
   * Se su CRM l'ndg  non è popolato, ma il cf sì, viene eseguita una ricerca light per cercare l'ndg.
   * Se dopo la ricerca light non è stato trovato l'ndg, ritorna l'oggetto, altrimenti viene eseguita una ricerca full.
   */
  public static SObject mergeWithCedacri(SObject objToMerge) {
    try {
      Boolean isContact = objToMerge.getSObjectType() == Contact.SObjectType;

      String ndg = (String) objToMerge.get('NDGGruppo__c');
      String cf = (String) objToMerge.get('CF__c');
      //adione SDHDFNZ-94034
	  objToMerge.put('CF__c',  ((String) objToMerge.get('CF__c')).toUpperCase().trim() );

      if(String.isBlank(cf) && !isContact) cf = (String) objToMerge.get('PIVA__c');

      if(String.isBlank(ndg) && String.isBlank(cf)) return objToMerge;
      else if(String.isBlank(ndg)) {
        WsAnagrafe.SearchAnagraficaRes res = WsAnagrafe.searchAnagrafica(null, cf, null, null);
        WsAnagrafe.Anagrafica[] aL = res.getAnagrafica(isContact ? 'pf' : 'pg');
        if(aL.size() == 1) ndg = String.valueOf(aL[0].ndg);
      }

      if(String.isBlank(ndg)) return objToMerge;

      WsAnagrafe.DatiAnagraficiCedacri datiAnagrafici = WsAnagrafe.getAnagrafica(ndg, null).payload;
      WsAnagraficaBeanIn b = new WsAnagraficaBeanIn(objToMerge, datiAnagrafici);
      return b.getObj();
    } catch (Exception e) {
      throwError(e);
      return null;
    }
  }

  /**
   * Chiama Cedacri (censimentoLight) per fare il censimento light di una Persona Giuridica,
   * gestendo il mapping tra i valori di Salesforce e quelli richiesti dal servizio. Se l'operazione
   * non va a buon fine, logga il fallimento.
   * @param  accId id dell'Account da censire
   */
  @future(callout = true)
  public static void censimentoLightAsync(Id objId) {
    SObject o = WsAnagraficaBean.getEntity(objId);
    if(o.getSObjectType() == Account.SObjectType) censimentoLight((Account) o);
    else censimentoLight(null, (Contact) o);
  }

  public static String censimentoLight(Account acc) {
    return censimentoLight(acc, null);
  }

  public static String censimentoLight(Account acc, Contact c) {
    Logger.setTransactionContext(null, acc != null ? acc.Id : c.Id);
    try {
      WsAnagraficaBean b = new WsAnagraficaBean();
      if(acc == null) b.fillFrom(c);
      else b.fillFrom(acc, c);
      b.validate(false);

      WsAnagrafe.CensimentoLightRes response = WsAnagrafe.censimentoLight(b);
      return String.valueOf(response.payload.ndg);
    } catch(Ex.WSCalloutException e) {
      throw e;
    } catch(DMLException e) {
      if(!U.isAsync()) throwError(e);
      else Logger.log('ANAG_CensimentoLight', e.getMessage());
    } finally {
      Logger.endTransaction();
    }

    return null;
  }

  public static String censimentoFull(Id oId) {
    Logger.setTransactionContext(null, oId);
    try {
      WsAnagraficaBean b = new WsAnagraficaBean();
      b.fillFrom(oId);
      b.validate(true);

      //In caso di figure estere la convalida fallirà in automatico per ora
      if(b.shippingState == 'EE' || (String.isBlank(b.shippingState) && b.billingState == 'EE')) {
        throw new Ex.WSException('Impossibile censire/convalidare un\'anagrafica estera. Contattare il ' +
        'supporto tecnico per effettuare il censimento');
      }

      WsAnagrafe.CensimentoFullRes response = WsAnagrafe.censimentoFull(b);
      String ndg = String.valueOf(response.payload.ndg);
      SObject o = oId.getSobjectType().newSObject(oId);
      o.put('NDGGruppo__c', ndg);
      update o;
      return ndg;
    } catch(Ex.WSCalloutException e) {
      throw e;
    } catch(Ex.WSException e) {
      if(U.isAsync()) Logger.log('ANAG_CensimentoFull', e.getMessage());
      else throwError(e);
    } catch (DMLException e) {
      if(U.isAsync()) Logger.log('ANAG_CensimentoFull', e.getMessage());
      else throwError(e);
    } finally {
      Logger.endTransaction();
    }

    return null;
  }

  public static String WGC_censimentoFull(Account acc, Contact c) {
    System.debug('SV censimentoFull acc: ' + acc);
    System.debug('SV censimentoFull contact: ' + c);
    // Logger.setTransactionContext(null, acc != null ? acc.Id : c.Id);
    try {
      WsAnagraficaBean b = new WsAnagraficaBean();
      if(acc == null) b.fillFrom(c);
      else b.fillFrom(acc, c);
      b.validate(true);

      WsAnagrafe.CensimentoFullRes response = WsAnagrafe.censimentoFull(b);
      System.debug('SV censimentoFull response: ' + response);
      return String.valueOf(response.payload.ndg);
    } catch(Ex.WSCalloutException e) {
      throw e;
    } catch(Ex.WSException e) {
      if(U.isAsync()) Logger.log('ANAG_CensimentoFull', e.getMessage());
      else throwError(e);
    } catch (DMLException e) {
      if(U.isAsync()) Logger.log('ANAG_CensimentoFull', e.getMessage());
      else throwError(e);
    } finally {
      // Logger.endTransaction();
    }

    return null;
  }

  @future(callout = true)
  public static void variazioneAsync(Id idDaCensire) {
    variazione(idDaCensire);
  }

  public static void variazione(Id idDaCensire) {
    Logger.setTransactionContext(null, idDaCensire);
    try {
      WsAnagraficaBean b = new WsAnagraficaBean();
      b.fillFrom(idDaCensire);
      b.validate(true);

      if (idDaCensire.getSobjectType() == Account.SObjectType) {
        if (String.isBlank(b.ndg)) throw new Ex.AnagrafeDiGruppoException('Non si può effettuare una variazione anagrafica perchè il cliente non ha un NDG');
        if (String.isBlank(b.codiceFiscale)) throw new Ex.AnagrafeDiGruppoException('Non si può effettuare una variazione anagrafica perchè il cliente non ha un codice fiscale');
        if (String.isBlank(b.naturaGiuridica)) throw new Ex.AnagrafeDiGruppoException('Non si può effettuare una variazione anagrafica perchè il cliente non ha una natura giuridica');
      }

      //In caso di figure estere la convalida andrà verde in automatico per ora
      if(b.shippingState == 'EE' || (String.isBlank(b.shippingState) && b.billingState == 'EE')) return;

      WsAnagrafe.variazione(b);
    } catch (Ex.WsCalloutException e) {
      throwError(e);
    } catch (Exception e) {
      if(!U.isAsync()) throwError(e);
      else Logger.log('ANAG_Variazione', e.getMessage());
    }
  }

  public static String WGC_variazione(Account acc, Contact c) {
    // Logger.setTransactionContext(null, String.isBlank(acc.Id) ? c.Id : acc.Id);
    try {
      WsAnagraficaBean b = new WsAnagraficaBean();
      if(acc == null) b.fillFrom(c);
      else b.fillFrom(acc, c);
      b.validate(true);

        // if (String.isBlank(b.ndg)) throw new Ex.AnagrafeDiGruppoException('Non si può effettuare una variazione anagrafica perchè il cliente non ha un NDG');
        // if (String.isBlank(b.codiceFiscale)) throw new Ex.AnagrafeDiGruppoException('Non si può effettuare una variazione anagrafica perchè il cliente non ha un codice fiscale');
        // if (String.isBlank(b.naturaGiuridica)) throw new Ex.AnagrafeDiGruppoException('Non si può effettuare una variazione anagrafica perchè il cliente non ha una natura giuridica');

      //In caso di figure estere la convalida andrà verde in automatico per ora
      if(b.shippingState == 'EE' || (String.isBlank(b.shippingState) && b.billingState == 'EE')) return b.ndg;
      WsAnagrafe.VariazioneRes response = WsAnagrafe.variazione(b);
      System.debug('SV varazione response: ' + response);
      //M.N SDHDFNZ-78955
      if(acc != null)
	  	acc.NumberOfEmployees = (acc.NumberOfEmployees == null || acc.NumberOfEmployees == 0) ? null : Integer.valueOf(acc.NumberOfEmployees);
      //M.N.
      return b.ndg;

    } catch (Ex.WsCalloutException e) {
      Logger.log('ANAG_Variazione', e.getMessage());
      throwError(e);
    } catch (Exception e) {
      Logger.log('ANAG_Variazione', e.getMessage());
      throwError(e);
    }

    return null;
  }

  /**
   * Interroga Cedacri (gestioneCollNdg) per la rete dei contatti collegati
   * all'ndg indicato, sistema le relazioni AccountContactRelation su
   * Salesforce dei contatti gia' presenti, o inserisce i nuovi contatti
   * collegati chidendo informazioni a Cedacri (getAnagrafica)
   * @param  ndgPadre
   * @param  idPadre
   */
  @future(callout = true)
  public static void syncCollegamentiAsync(String ndgPadre, Id idPadre) {
    Logger.setTransactionContext(null, idPadre);
    try {
      String[] ndgElementiCollegati = WsAnagrafe.gestioneCollNdg(ndgPadre).getElementi(ndgPadre);
      if(ndgElementiCollegati.isEmpty()) return;

      Map<String, Contact> conToInsert = new Map<String, Contact>();
      Map<Id, AccountContactRelation> relsToInsert = new Map<Id, AccountContactRelation>();

      Map<String, SObject> contattiEsistenti = U.keyBy([SELECT
        Id,
        NDGGruppo__c
        FROM Contact
        WHERE NDGGruppo__c IN :ndgElementiCollegati
      ], 'NDGGruppo__c');

      Map<String, SObject> relsEsistenti = U.keyBy([SELECT
        AccountId,
        Contact.NDGGruppo__c
        FROM AccountContactRelation
        WHERE AccountId = :idPadre
      ], 'Contact.NDGGruppo__c');

      for (String elNdg : ndgElementiCollegati) {
        if (!contattiEsistenti.containsKey(elNdg)) {
          Contact c = (Contact) WsAnagrafeUtils.mergeWithCedacri(new Contact(NDGGruppo__c = elNdg, AccountId = idPadre));
          if (c.NaturaGiuridica__c == WsAnagrafe.NATURAGIURIDICA_PF) {
            conToInsert.put(c.NDGGruppo__c, c);
          }
        } else if(!relsEsistenti.containsKey(elNdg)) {
          Id cId = contattiEsistenti.get(elNdg).Id;
          relsToInsert.put(cId, new AccountContactRelation(AccountId = idPadre, ContactId = cId));
        }
      }
      insert relsToInsert.values();

      //gestioneCollNdg restituisce duplicati -> li filtro
      Database.SaveResult[] srList = Database.insert(conToInsert.values(), false);
      for (Database.SaveResult sr : srList) {
        if (!sr.isSuccess()) {
          //creo un log per ogni referente di cui fallisce l'insert
          Logger.log('ANAG_GestioneCollNdg', 'Inserimento Referente fallito: ' + sr.getErrors());
        }
      }
    } catch (Exception e) {
      Logger.log('ANAG_GestioneCollNdg', 'Richiesta/inserimento Referenti fallita: ' + e.getMessage() + '. ' + e.getStackTraceString());
    }
  }

  /**
   * Interroga Cedacri (searchAnagrafica) per informazioni relative alla Persona Giuridica indicata,
   * gestendo il mapping tra i valori di Salesforce e quelli ritornati dal servizio.
   * @param  denominazione ragione sociale dell'Account
   * @param  cf
   * @param  piva
   * @param  provinceCode
   * @return lista di anagrafiche corrispondenti trovate su Cedacri
   */
  public static List<Account> searchPG(String denominazione, String cf, String piva, String provinceCode) {
	return searchPG(denominazione, cf, piva, provinceCode, null);
  }

  public static List<Account> searchPG(String denominazione, String cf, String piva, String provinceCode, Long ndg) {
    try {
	  //ricerca su Cedacri
	  //adione CRM ID 80
      WsAnagrafe.SearchAnagraficaRes response = WsAnagrafe.searchAnagrafica(
        denominazione,
        String.isBlank(cf) ? piva : cf, 
		null,
        null,
		ndg
      );

      Id rtId = U.getRecordTypes('Account').get('Cliente').Id;

      Account[] foundAccounts = new List<Account>();
      for (WsAnagrafe.Anagrafica r : response.getAziende()) {
        if (r.isCointestazione()) continue;
        Account acc = new Account();
        acc.CodiceIstituto3N__c = ImpostazioniServizi__c.getInstance().CodiceIstituto3N__c;
        acc.Name = r.denominazione;
        acc.NDGGruppo__c = String.valueOf(r.ndg);
        acc.NaturaGiuridica__c = r.getFormaGiuridica();

        if (r.telefono != null) {
          acc.Phone = r.telefono.getNumeroCompleto();
        }
        acc.Email__c = r.email;

        if (r.residenzaLegale != null && r.residenzaLegale.indirizzo != null) {
          acc.BillingStreetName__c = r.residenzaLegale.indirizzo.nome;
          acc.BillingStreetNumber__c = r.residenzaLegale.indirizzo.numero;
          acc.BillingStreetType__c = r.residenzaLegale.indirizzo.tipo;
          acc.BillingCity = r.residenzaLegale.comune;
          acc.BillingState = r.residenzaLegale.provincia;
          acc.BillingPostalCode = String.valueOf(r.residenzaLegale.cap);
        }
        acc.BillingCountry = r.nazione;
		acc.BillingCountry__c = r.nazione;

        // acc.ShippingStreet = acc.BillingStreet;
        // acc.ShippingStreetName__c = acc.BillingStreetName__c;
        // acc.ShippingStreetNumber__c = acc.BillingStreetNumber__c;
        // acc.ShippingStreetType__c = acc.BillingStreetType__c;
        // acc.ShippingCity = acc.BillingCity;
        // acc.ShippingState = acc.BillingState;
        // acc.ShippingPostalCode = acc.BillingPostalCode;
        // acc.ShippingCountry = acc.BillingCountry;
        acc.CF__c = r.codiceFiscale;

        acc.Origine__c = WsAnagrafe.CEDACRI;
        acc.RecordTypeId = rtId;

        if (String.isBlank(provinceCode) || acc.BillingState == provinceCode) foundAccounts.add(acc);
      }
      return foundAccounts;
    } catch(Exception e) {
      throwError(e);
      return null;
    }
  }

  /**
   * Interroga Cedacri (searchAnagrafica) per ricevere informazioni aggiornate di una Persona Fisica, gestendo il
   * mapping tra i valori salvati in Cedacri e Salesforce
   */
  public static List<Contact> searchPF(String cf, String cognome, String nome) {
    try {
      WsAnagrafe.SearchAnagraficaRes response = WsAnagrafe.searchAnagrafica(null, cf, cognome, nome);

      Set<String> nomiComuni = new Set<String>();
      for (WsAnagrafe.Anagrafica r : response.getPersoneFisiche()) {
        if (String.isNotBlank(r.luogoDiNascita)) nomiComuni.add(r.luogoDiNascita);
      }

      Map<String, SObject> comuniMap = U.keyBy([SELECT
        Id,
        Name,
        CodiceCatastale__c,
        Cab__c
        FROM Comune__c
        WHERE Name IN :nomiComuni
        ORDER BY FlagStorico__c
      ], 'Name');

      List<Contact> foundContacts = new List<Contact>();
      for (WsAnagrafe.Anagrafica r : response.getPersoneFisiche()) {
        if (r.isCointestazione()) continue;
        Contact c = new Contact();
        c.NDGGruppo__c = String.valueOf(r.ndg);
        c.LastName = r.denominazione;
        c.CodiceIstituto3N__c = ImpostazioniServizi__c.getInstance().CodiceIstituto3N__c;
        if (r.telefono != null) {
          c.Phone = r.telefono.getNumeroCompleto();
        }
        c.MobilePhone = r.numeroCellulare;
        c.CF__c = r.codiceFiscale;
        c.Sesso__c = r.sesso;
        if (r.residenzaLegale != null && r.residenzaLegale.Indirizzo != null) {
          c.MailingStreetName__c = r.residenzaLegale.indirizzo.nome;
          c.MailingStreetNumber__c = r.residenzaLegale.indirizzo.numero;
          c.MailingStreetType__c = r.residenzaLegale.indirizzo.tipo;
          c.MailingCity = r.residenzaLegale.comune;
          c.MailingState = r.residenzaLegale.provincia;
          c.MailingPostalCode = String.valueOf(r.residenzaLegale.cap);
        }
        c.LuogoNascita__c = r.luogoDiNascita;
        String codiceCatastale = String.isNotBlank(r.luogoDiNascita) && comuniMap.containsKey(r.luogoDiNascita) ? (String) comuniMap.get(r.luogoDiNascita).get('CodiceCatastale__c') : null;
        c.CodCatastaleLocNascita__c = codiceCatastale;
        c.CABLocNascita__c = String.isNotBlank(r.luogoDiNascita) && comuniMap.containsKey(r.luogoDiNascita) ? (String) comuniMap.get(r.luogoDiNascita).get('Cab__c') : null;
        c.Birthdate = UDate.getDateValue(r.dataDiNascita);
        c.Email = r.email;
        c.Origine__c = ORIGINE_CEDACRI;
        foundContacts.add(c);
      }
      return foundContacts;
    } catch(Exception e) {
      throwError(e);
      return null;
    }
  }

  public static String getNdgCointestazione(String[] ndgs) {
    String tmp;
    String errorMessage;
    try {
      WsAnagrafe.GestioneCollNdgResponse response = WsAnagrafe.gestioneCollNdg(ndgs[0]);
      WsAnagrafe.ElementoNdg[] cointList = response.payload.getCointestazioneList();
      Set<String> ndgList = new Set<String>();
      for (WsAnagrafe.ElementoNdg el : cointList) {
        ndgList.add(String.valueOf(el.ndg));
      }
      if (ndgList.containsAll(ndgs)) {
        tmp = response.payload.getCointestazioneCapoReteNdg();
      }

      if (tmp == null) {
        response = WsAnagrafe.creaCointestazioneCollNdg(ndgs);
        tmp = response.payload.getCointestazioneCapoReteNdg();
      }

      return tmp;
    } catch (Exception e) {
      throwError(e);
      return null;
    }
  }

  @future(callout = true)
  public static void setRetiAnagraficheIfisAsync(Id accId) {
    Logger.setTransactionContext(null, accId);
    Account acc = [SELECT
      NDGGruppo__c,
      GestoreCliente__c,
      GestoreDebitore__c,
      Owner.NDGGruppo__c,
      PresentatoreNDGFormula__c
      FROM Account
      WHERE Id = :accId
    ];

    try {
      WsAnagrafe.setRetiAnagraficheIfis(
        acc.NDGGruppo__c,
        acc.GestoreCliente__c,
        acc.GestoreDebitore__c,
        acc.Owner.NDGGruppo__c,
        acc.PresentatoreNDGFormula__c
      );
    } catch(Ex.CedacriInputException e) {
      Logger.log(new Log__c(
        Source__c = 'ANAG_RetiAnagrafiche',
        ErorrMessage__c = 'setRetiAnagraficheIfis: gli NDG di Cliente e Settorista sono obbligatori',
        InputPayload__c = (
          '{"NDGCliente": "' +
          acc.NDGGruppo__c +
          '", "NDGSettorista": "' +
          acc.Owner.NDGGruppo__c +
          '"}'
        )
      ));
    } catch(Ex.WsCalloutException e) {
      if(!U.isAsync()) throwError(e);
    } catch(Exception e) {
      if(!U.isAsync()) throwError(e);
      else {
        Logger.log('ANAG_RetiAnagrafiche', e.getMessage() + '. ' + e.getStackTraceString());
      }
    }
  }

  public static void associaPfPgCollNdg(Id idAccount, Id idContact) {
    try {
      Account a = [SELECT NDGGruppo__c, NaturaGiuridica__c FROM Account WHERE Id = :idAccount];
      Contact c = [SELECT NDGGruppo__c FROM Contact WHERE Id = :idContact];

      NaturaGiuridicaTipoRete__mdt dettaglioNg = [SELECT
        TipoRete__c,
        CedenteCapoRete__c
        FROM NaturaGiuridicaTipoRete__mdt
        WHERE Label = :a.NaturaGiuridica__c
      ];

      WsAnagrafe.associaPfPgCollNdg(
        a.NDGGruppo__c,
        c.NDGGruppo__c,
        dettaglioNg.TipoRete__c,
        dettaglioNg.CedenteCapoRete__c
      );
    } catch (Exception e) {
      throwError(e);
    }
  }
}