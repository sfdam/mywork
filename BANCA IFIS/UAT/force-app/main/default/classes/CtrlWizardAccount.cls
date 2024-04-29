/**
* Progetto:         Banca IFIS
* Sviluppata il:    22/12/2016
* Developer:        Zerbinati Francesco, Michele Triaca
*/
public with sharing class CtrlWizardAccount {
  private static final String ORIGINE_CRM = 'CRM';
  private static final String CANALE_DIRETTO = '2';
  private static final String CANALE_INDIRETTO = '4';
  private static final String CANALE_WEB = '5';
  private static final String SOTTOCANALE_NVERDE = '101';
  public static final String CI3N_FACTORING = '881';
  public static final String CI3N_POLONIA = '889';

  public CtrlWizardAccount() {}
  public CtrlWizardAccount(ApexPages.StandardController ctrl) {}
  public CtrlWizardAccount(CtrlFiloDiretto ctrl) {}

  public class InputObj {
	//adione CRM ID 80
	String ndg;
    String pivaOrCf;
    String ragioneSociale;
    String provincia;
    String tipoDiRicerca;
    Boolean estero;

	public InputObj(String pivaOrCf, String ragioneSociale, String provincia, String tipoDiRicerca, Boolean estero) {
      this.pivaOrCf = pivaOrCf;
      this.ragioneSociale = ragioneSociale;
      this.provincia = provincia;
      this.tipoDiRicerca = tipoDiRicerca;
      this.estero = estero;
    }
	
	public InputObj(String ndg, String pivaOrCf, String ragioneSociale, String provincia, String tipoDiRicerca, Boolean estero) {
	  //adione CRM ID 80
	  this.ndg = ndg;
      this.pivaOrCf = pivaOrCf;
      this.ragioneSociale = ragioneSociale;
      this.provincia = provincia;
      this.tipoDiRicerca = tipoDiRicerca;
      this.estero = estero;
	}
  }

  /**
   * Restituisce true nel caso in cui la ricerca Account venga eseguita sull'istanza di Cedacri polacca
   */
  @RemoteAction
  public static Boolean isPolandSearch() {
    return ImpostazioniServizi__c.getInstance().CodiceIstituto3N__c == CI3N_POLONIA;
  }

  @RemoteAction
  public static List<Account> searchAnagrafica(InputObj inputObj, String platform) {
	//adione CRM ID 80
    Boolean searchByName = inputObj.tipoDiRicerca != 'piva' && inputObj.tipoDiRicerca != 'ndg';
    //String paramSearch = searchByName ? inputObj.ragioneSociale : inputObj.pivaOrCf;
	String paramSearch;
	if(searchByName) {
		paramSearch = inputObj.ragioneSociale;
	} else if (inputObj.tipoDiRicerca == 'piva') {
		paramSearch = inputObj.pivaOrCf;
	} else {
		paramSearch = inputObj.ndg;
	}
    paramSearch = paramSearch.trim();
    String provinceCode;
    if(isPolandSearch()) provinceCode = '';
    else if(inputObj.estero) provinceCode = 'EE';
    else provinceCode = inputObj.provincia;
    //Validazioni
    if (!searchByName && (String.isBlank(paramSearch) || paramSearch.length() < 3) ||
        searchByName && ((String.isBlank(paramSearch) || paramSearch.length() < 3 ))) {
      throw new Ex.WSException(Label.ErroreStringa3Caratteri);
    }
	//adione CRM ID 80
	Long ndgLong = null;
	if (inputObj.tipoDiRicerca == 'ndg') {
		ndgLong = Long.valueOf(inputObj.ndg);
	}

    try {
      List<Account> account = new List<Account>();
	  //ricerca su CRM, Cedacri per NDG
	  //adione CRM ID 80
      if (platform == 'CEDACRI') {
		//prima cerco NDG su CRM 
		account = searchAnagraficaSFDC_NDG(''+ndgLong);
		//se non trovo nulla allora cerco su Cedacri
		if (account.size() <= 0)
	  	  account = WsAnagrafeUtils.searchPG('', '', '', '', ndgLong);
	  }
      if (platform == 'SFDC') account = searchAnagraficaSFDC(paramSearch, provinceCode, searchByName);
	  //A.M. Sostituzione Infoprovider RIBES -> CERVED
      if (platform == 'CERVED' && !inputObj.estero && !isPolandSearch()) account = searchAnagraficaRibes(
        inputObj.tipoDiRicerca == 'piva' ? '' : inputObj.ragioneSociale,
        inputObj.tipoDiRicerca == 'piva' ? inputObj.pivaOrCf : '',
        provinceCode
      );
      if (platform == 'ANDG') account = WsAnagrafeUtils.searchPG(
        inputObj.tipoDiRicerca == 'piva' ? '' : inputObj.ragioneSociale,
        inputObj.tipoDiRicerca == 'piva' ? inputObj.pivaOrCf : '',
        inputObj.tipoDiRicerca == 'piva' ? inputObj.pivaOrCf : '',
        provinceCode
      );
      return account;
    } catch (DmlException err) {
      System.debug(err);
      throw new Ex.WSException(Label.ErroreRecuperoAnagrafiche, err);
    }
  }

  /**
   * Cerca su Cedacri i referenti corrispondenti
   * @param  cf      codice fiscale del referente da cercare
   * @param  cognome cognome del referente da cercare
   * @param  nome    nome del referente da cercare
   * @return         lista di referenti trovati
   */
  @RemoteAction
  public static List<Contact> searchContattiANDG(String cf, String cognome, String nome) {
    return WsAnagrafeUtils.searchPF(cf, cognome, nome);
  }

  /**
   * Cerca su Salesforce i referenti corrispondenti
   * @param  cf      codice fiscale del referente da cercare
   * @param  cognome cognome del referente da cercare
   * @param  nome    nome del referente da cercare
   * @return         lista di referenti trovati
   */
  @RemoteAction
  public static List<Contact> searchContattiSFDC(String cf, String cognome, String nome) {
    String ci3n = ImpostazioniServizi__c.getInstance().CodiceIstituto3N__c;
    //TODO QUERY RICERCA MIGLIORE
    String query = QueryBuilder.newInstance('Contact', WsAnagraficaBean.REQUIRED_CONTACT_FIELDS, new String[]{
      'AccountId',
      'Account.Name',
      'CodiceIstituto3N__c',
      'NDGGruppo__c',
      'PEP__c',
      'PEPTipoCarica__c',
      'StatoFastFinance__c'
    }).beginFilter()
      .beginOr()
        .beginAnd()
          .add('FirstName', QBOp.QLIKE, '%' + nome + '%', String.isNotBlank(nome))
          .add('LastName', QBOp.QLIKE, '%' + cognome + '%', String.isNotBlank(cognome))
        .end()
        .add('CF__c', QBOp.QEQUAL, cf)
      .end()
      .add('IsReferenteCampagna__c', QBOp.QEQUAL, false)
      .add('CodiceIstituto3N__c', QBOp.QEQUAL, ci3n, ci3n == CI3N_FACTORING)
      .add('NDGGruppo__c', QBOp.QNOT_EQUAL, '', true)
    .endFilter()
    .getQuery();

    System.debug('QUERY: ' + query);

    List<Contact> cL = Database.query(query);
    U.massSet(cL, 'Origine__c', ORIGINE_CRM);
    return cL;
  }

  /**
   * Cerca su Salesforce i referenti corrispondenti
   * @param  cf      codice fiscale del referente da cercare
   * @param  cognome cognome del referente da cercare
   * @param  nome    nome del referente da cercare
   * @return         lista di referenti trovati
   */
  @RemoteAction
  public static List<Contact> WGC_searchContattiSFDC_filoDiretto(String cf, String cognome, String nome) {
    String ci3n = ImpostazioniServizi__c.getInstance().CodiceIstituto3N__c;
    //TODO QUERY RICERCA MIGLIORE
    String query = QueryBuilder.newInstance('Contact', WsAnagraficaBean.REQUIRED_CONTACT_FIELDS, new String[]{
      'AccountId',
      'Account.Name',
      'CodiceIstituto3N__c',
      'NDGGruppo__c',
      'PEP__c',
      'PEPTipoCarica__c',
      'StatoFastFinance__c'
    }).beginFilter()
      .beginOr()
        .beginAnd()
          .add('FirstName', QBOp.QLIKE, '%' + nome + '%', String.isNotBlank(nome))
          .add('LastName', QBOp.QLIKE, '%' + cognome + '%', String.isNotBlank(cognome))
        .end()
        .add('CF__c', QBOp.QEQUAL, cf)
      .end()
    .endFilter()
    .getQuery();

    System.debug('QUERY: ' + query);

    List<Contact> cL = Database.query(query);
    U.massSet(cL, 'Origine__c', ORIGINE_CRM);
    return cL;
  }

  public static void truncateAccount (Account inputAccount) {
    UtilAnagrafiche.truncateInSObject(inputAccount, new String[]{
      'Name',
      'RagioneSociale__c'
    }, 80);

    UtilAnagrafiche.truncateInSObject(inputAccount, new String[]{
      'BillingStreetName__c',
      'BillingState',
      'BillingCountry',
      'ShippingStreetName__c',
      'ShippingState',
      'ShippingCountry'
    }, 24);
  }

  @RemoteAction
  public static Account setupAccount(Account inputAccount) {
    Account res = inputAccount;
    Logger.setTransactionContext(null, inputAccount.Id);
    if (
      (String.isBlank(res.NDGGruppo__c) || String.isBlank(res.Id)) &&
      (String.isNotBlank(res.CF__c) || String.isNotBlank(res.PIVA__c))
    ) {
      res = (Account) WsAnagrafeUtils.mergeWithCedacri(res);
      if(String.isNotBlank(res.NDGGruppo__c)) {
        res.Origine__c = res.Id != null ? ORIGINE_CRM : WsAnagrafe.CEDACRI;
      }
    }

    if (res.Origine__c == WsRestRibes.RIBES) {
      WsRestRibesUtils ribesUtils = new WsRestRibesUtils();
      res = ribesUtils.updateDatiAnagraficiRibesPg(res);
    }

    return res;
  }

  //zIgnoreErrors: mantenere z per ordinamento parametri
  @RemoteAction
  public static Id insertAccount(String inputAccount, String source, Boolean zIgnoreErrors) {
    return CtrlWizardAccount.insertAccount(inputAccount, source, zIgnoreErrors, null);
  }

  public static Id insertAccount(String inputAcc, String source, Boolean zIgnoreErrors, Map<String, Object> additionalFields) {
    Account inputAccount = (Account)JSON.deserialize(inputAcc, Account.class);
    Logger.setTransactionContext(null, inputAccount.Id);

    // troncamenti a 24 caratteri
    truncateAccount(inputAccount);

    // se inserimento nuovo account da modale, setto owner a utente default
    Id defaultOwner = UtenzeDefault__c.getInstance().IdUtente__c;
    if(inputAccount.Id == null && (source == 'woInserimentoDebitori' || source == 'woInserimentoGaranti')) {
      inputAccount.OwnerId = defaultOwner;
    }

    String canaleSviluppo = (inputAccount.Id != null) ? [SELECT CanaleSviluppo__c FROM Account WHERE Id = :inputAccount.Id].CanaleSviluppo__c : '';

    System.SavePoint sp;

    // Per i prospect il canale è 2 => Diretto, a meno che source non valga fdInbound.
    // In quel caso è web / numero verde e valorizzo anche la data ultima importazione da web.
    if (source == 'fdInbound') {
      inputAccount.CanaleSviluppo__c = CANALE_WEB;
      inputAccount.Sottocanale__c = SOTTOCANALE_NVERDE;
      inputAccount.DataUltimaImportazioneDaWeb__c = Datetime.now();
    } else if (canaleSviluppo != CANALE_WEB && canaleSviluppo != CANALE_INDIRETTO) {
    // Se il canale = web o indiretto, non lo modifico.
      inputAccount.CanaleSviluppo__c = CANALE_DIRETTO;
    }

    // TODO QUESTA PARTE VA RIVISTA (inizio)
    Contact[] referentiRibes = new Contact[]{};
    if (inputAccount.Origine__c == WsRestRibes.RIBES) {
      //se c'è un errore nel recupero dei referenti Ribes, l'account deve comunque essere inserito,
      //per cui non lancio eccezioni, ma creo solo un Log__c
      try {
        referentiRibes = new WsRestRibesUtils().getContacts(inputAccount.Id, inputAccount.REA__c, inputAccount.ProvinciaCCIAA__c);
      } catch(Exception e) {}
    }

    Contact diContact;
    if (inputAccount.NaturaGiuridica__c == 'DI') {
      if (inputAccount.Origine__c == WsRestRibes.RIBES) {
        Integer diIndex = null;
        for (Integer i = 0; i < referentiRibes.size(); i++) {
          if (referentiRibes[i].CF__c == inputAccount.CF__c) {
            diIndex = i;
            break;
          }
        }
        if (diIndex != null) {
          diContact = referentiRibes.remove(diIndex);
        } else {
          throw new Ex.WSException(Label.ErroreRecuperoDIRibes);
        }
      } else if (inputAccount.Origine__c != WsAnagrafe.CEDACRI && inputAccount.Area__c != 'EE') {
        diContact = setupDIContact(inputAccount);
      }
    }
    // TODO QUESTA PARTE VA RIVISTA (fine)

    //censimento light account sincrono
    if (source != 'fdInbound' && String.isBlank(inputAccount.NDGGruppo__c) && !isPolandSearch()) {
      try {
        inputAccount.NDGGruppo__c = WsAnagrafeUtils.censimentoLight(inputAccount, diContact);
      } catch (Exception e) {
        // Se mi sto registrando a TiAnticipo e il censimento non ha buon fine, proseguo
        if (!zIgnoreErrors) throw e;
      }
    }

    //inserimento account in CRM
    sp = Database.setSavePoint();
    try {
      if (additionalFields != null) {
        for (String field : U.toList(additionalFields.keySet())) {
            inputAccount.put(field, additionalFields.get(field));
          }
      }
      upsert inputAccount;
      //inserimento DI
      if (diContact != null) {
        diContact.AccountId = inputAccount.Id;
        TrgContact.skipCheckCodiceFiscale = true;
        upsert diContact CI3N_CF__c; // TODO POLONIA: sistemare upsert
      }
      Logger.setTransactionContext(null, inputAccount.Id);
    } catch (DmlException e) {
      Database.rollback(sp);
      Logger.log('ANAG_CensimentoLight', e.getDmlMessage(0) + ' - ' + e.getStackTraceString());
      throw new Ex.WSException(Label.ErroreInserimentoAccCont + ' ' + e.getDmlMessage(0), e);
    }

    //inserimento referenti ribes
    if (!referentiRibes.isEmpty()) {
      try {
        U.massSet(referentiRibes, 'AccountId', inputAccount.Id);
        insert referentiRibes;
      } catch (DMLException e) {
        Logger.log('RIBES_ReferentiRibes', e.getDmlMessage(0) + ' - ' + e.getStackTraceString());
      }
    }

    //FUTURE
    if (String.isNotEmpty(inputAccount.NDGGruppo__c) && inputAccount.Origine__c == WsAnagrafe.CEDACRI) {
      WsAnagrafeUtils.syncCollegamentiAsync(inputAccount.NDGGruppo__c, inputAccount.Id);
    }
    //END FUTURE

    return inputAccount.Id;
  }

  @TestVisible
  public static Contact setupDIContact(Account acc) {
    // if (String.isNotBlank(acc.BillingCity)) {
    //   Comune__c[] cL = [SELECT Id, Name, Cap__c FROM Comune__c WHERE Name = :acc.BillingCity ORDER BY FlagStorico__c];
    //   if (!cl.isEmpty()) {
    //     acc.BillingPostalCode = cL[0].Cap__c;
    //     acc.ShippingPostalCode = cL[0].Cap__c;
    //     acc.BillingCountry = 'ITALIA';
    //     acc.ShippingCountry = 'ITALIA';
    //   }
    // }

    Contact c = new Contact();
    UtilCodiceFiscale u = new UtilCodiceFiscale();
    UtilCodiceFiscale.ContactInfo reversedInfo = u.reverseCodiceFiscale(acc.CF__c, acc.Name); // TODO INTERNATIONAL: modificare
    c.FirstName = reversedInfo.firstName;
    c.LastName = String.isNotBlank(reversedInfo.lastName) ? reversedInfo.lastName : acc.Name;
    c.Birthdate = reversedInfo.birthDate;
    c.Sesso__c = reversedInfo.sesso;
    c.CodCatastaleLocNascita__c = reversedInfo.codiceCatastale;
    Comune__c[] comuniCompatibili = [SELECT
      Id,
      Name,
      Cap__c
      FROM Comune__c
      WHERE CodiceCatastale__c = :c.CodCatastaleLocNascita__c
      ORDER BY FlagStorico__c
    ];
    if (!comuniCompatibili.isEmpty()) c.LuogoNascita__c = comuniCompatibili[0].Name;
    //adione SDHDFNZ-94034
    c.CF__c = (acc.CF__c).toUpperCase().trim();
    c.CodiceIstituto3N__c = ImpostazioniServizi__c.getInstance().CodiceIstituto3N__c;
    c.CI3N_CF__c = c.CodiceIstituto3N__c + '-' + c.CF__c;
    c.Email = acc.Email__c;

    c.MailingStreet = acc.BillingStreet;
    c.MailingStreetName__c = acc.BillingStreetName__c;
    c.MailingStreetNumber__c = acc.BillingStreetNumber__c;
    c.MailingStreetType__c = acc.BillingStreetType__c;
    c.MailingCity = acc.BillingCity;
    c.MailingState = acc.BillingState;
    c.MailingCountry = 'ITALIA';
    c.MailingPostalCode = acc.BillingPostalCode;

    return c;
  }

  @TestVisible
  public static Contact WGC_setupDIContact(Account acc) {

    Contact c = new Contact();
    UtilCodiceFiscale u = new UtilCodiceFiscale();
    UtilCodiceFiscale.ContactInfo reversedInfo = u.reverseCodiceFiscale(acc.CF__c.toUpperCase(), acc.Name); // TODO INTERNATIONAL: modificare
    c.FirstName = reversedInfo.firstName;
    c.LastName = reversedInfo.lastName;
    c.Birthdate = reversedInfo.birthDate;
    c.Sesso__c = reversedInfo.sesso;
    c.CodCatastaleLocNascita__c = reversedInfo.codiceCatastale;
    Comune__c[] comuniCompatibili = [SELECT
      Id,
      Name,
      Cap__c
      FROM Comune__c
      WHERE CodiceCatastale__c = :c.CodCatastaleLocNascita__c
      ORDER BY FlagStorico__c
    ];
    if (!comuniCompatibili.isEmpty()) c.LuogoNascita__c = comuniCompatibili[0].Name;
      //adione SDHDFNZ-94034
    c.CF__c = (acc.CF__c).toUpperCase().trim();
    c.CodiceIstituto3N__c = ImpostazioniServizi__c.getInstance().CodiceIstituto3N__c;
    c.CI3N_CF__c = c.CodiceIstituto3N__c + '-' + c.CF__c;
    // c.Email = acc.Email__c;
    c.SAE__c = '600';

    return c;
  }

  @TestVisible
  private static Contact compliteDIContact(Account acc, Contact cnt, Contact cntRibes, Contact cntIniziale) {
    System.debug('SV compliteDIContact Account: ' + acc);
    System.debug('SV compliteDIContact Contact: ' + cnt);
    System.debug('SV compliteDIContact Contact Docu: ' + cntIniziale);

    Comune__c[] cL = [SELECT Id, Name, Cap__c FROM Comune__c WHERE Name = :acc.BillingCity ORDER BY FlagStorico__c];

    if (String.isNotBlank(acc.BillingCity)) {
      if (!cl.isEmpty()) {
        acc.BillingPostalCode = cL[0].Cap__c;
        acc.BillingCountry = 'ITALIA';
      }
    }

    if (String.isNotBlank(acc.ShippingCity)) {
      if (!cl.isEmpty()) {
        acc.ShippingPostalCode = cL[0].Cap__c;
        acc.ShippingCountry = 'ITALIA';
      }
    }

    Contact c = cnt;
    UtilCodiceFiscale u = new UtilCodiceFiscale();
    UtilCodiceFiscale.ContactInfo reversedInfo = u.reverseCodiceFiscale(acc.CF__c, acc.Name);
    System.debug('SV REVERSE CF: ' + reversedInfo);

    if(String.isBlank(c.FirstName)){
      if(cntRibes != null && String.isNotBlank(cntRibes.FirstName)){
        c.FirstName = cntRibes.FirstName;
      } else {
        c.FirstName = reversedInfo.firstName;
      }
    }
    if(String.isBlank(c.LastName)){
      if(cntRibes != null && String.isNotBlank(cntRibes.LastName)){
        c.LastName = cntRibes.LastName;
      } else {
        c.LastName = String.isNotBlank(reversedInfo.lastName) ? reversedInfo.lastName : acc.Name;
      }
    }

    if(String.isBlank(c.ProvinciaNascita__c)){
      String provinciaNascita;
        List<Comune__c> com = new List<Comune__c>();
        System.debug('SV reversedInfo.codiceCatastale: ' + reversedInfo.codiceCatastale);
      if(String.isNotBlank(reversedInfo.codiceCatastale)){
        com = [ SELECT Id, Name, Cap__c, Provincia__c FROM Comune__c WHERE CodiceCatastale__c =: reversedInfo.codiceCatastale LIMIT 1 ];
          if(com.size() > 0){
              provinciaNascita = com[0].Provincia__c;
          }
      }
      c.ProvinciaNascita__c = String.isNotBlank(provinciaNascita) ? provinciaNascita : acc.BillingState__c;
    }
  
  //A.M. Aggiunta Info non presenti a FE
    if (c.CodCatastaleLocNascita__c == null)
       c.CodCatastaleLocNascita__c = reversedInfo.codiceCatastale;

    c.Email = acc.Email__c;

    c.MailingStreet = acc.BillingStreet;
    c.MailingStreetName__c = acc.BillingStreetName__c;
    c.MailingStreetNumber__c = acc.BillingStreetNumber__c;
    c.MailingStreetType__c = acc.BillingStreetType__c;
    c.MailingCity = acc.BillingCity;
    c.MailingState = acc.BillingState;
    c.MailingCountry = acc.BillingCountry;
    c.MailingPostalCode = acc.BillingPostalCode;


    // GESTIONE DOCUMENTO CONTATTO
    if (cntIniziale != null){
      if(String.isNotBlank(cntIniziale.TipoDocumentoId__c)){
        c.TipoDocumentoId__c = cntIniziale.TipoDocumentoId__c;
      }

      if(String.isNotBlank(cntIniziale.NumeroDoc__c)){
        c.NumeroDoc__c = cntIniziale.NumeroDoc__c;
      }

      if(cntIniziale.DataEmissioneDoc__c != null){
        c.DataEmissioneDoc__c = cntIniziale.DataEmissioneDoc__c;
      }

      if(cntIniziale.DataScadenzaDoc__c != null){
        c.DataScadenzaDoc__c = cntIniziale.DataScadenzaDoc__c;
      }

      if(String.isNotBlank(cntIniziale.LuogoEmissioneDoc__c)){
        c.LuogoEmissioneDoc__c = cntIniziale.LuogoEmissioneDoc__c;
      }
    }

	//A.M. Aggiugnere controllo CF vedi TrgContact.checkCodiceFiscale 
	System.debug('@@@ ChecCF Input: ' + acc.CF__c + ' - ' + c);
	Boolean cfOk = u.checkCF(acc.CF__c, c);
	System.debug('@@@ ChecCF Output: ' + cfOk);
	if (!cfOk)
	  throw new Ex.WSException('Codice Fiscale non coerente con i dati anagrafici inseriti');

    return c;
  }

  @TestVisible
  private static Contact ContactVerifyResidenza(Account acc, Contact cnt) {
    System.debug('SV compliteDIContact Account: ' + acc);
    System.debug('SV compliteDIContact Contact: ' + cnt);

    if (String.isNotBlank(acc.BillingCity)) {
      Comune__c[] cL = [SELECT Id, Name, Cap__c FROM Comune__c WHERE Name = :acc.BillingCity ORDER BY FlagStorico__c];
      if (!cl.isEmpty()) {
        acc.BillingPostalCode = cL[0].Cap__c;
        acc.ShippingPostalCode = cL[0].Cap__c;
        acc.BillingCountry = 'ITALIA';
        acc.ShippingCountry = 'ITALIA';
      }
    }

    Contact c = cnt;

    if(String.isBlank(c.MailingStreetType__c)){
      c.MailingStreetType__c = 'VIA';
    }

    if(String.isBlank(c.MailingStreet) && String.isNotBlank(c.MailingStreetName__c)){
      c.MailingStreet = (c.MailingStreetName__c.contains(c.MailingStreetType__c)) ? c.MailingStreetName__c + ' ' + c.MailingStreetNumber__c : c.MailingStreetType__c + ' ' + c.MailingStreetName__c + ' ' + c.MailingStreetNumber__c;
    }

    if (String.isNotBlank(c.MailingPostalCode) && String.isNotBlank(c.MailingState)) {
      Comune__c[] cL = [SELECT Id, Name, Cap__c FROM Comune__c WHERE Provincia__c =: c.MailingState AND Cap__c =: c.MailingPostalCode ORDER BY FlagStorico__c];
      if (!cl.isEmpty()) {
        c.MailingCity = cL[0].Name;
        c.MailingCity__c = cL[0].Name;
      }
    } else {
      if(String.isBlank(c.MailingState)){
        c.MailingState = acc.BillingState;
        c.MailingState__c = acc.BillingState;
      }

      if(String.isBlank(c.MailingPostalCode)){
        c.MailingPostalCode = acc.BillingPostalCode;
        c.MailingPostalCode__c = acc.BillingPostalCode;
      }

      if(String.isBlank(c.MailingCity)){
        c.MailingCity = acc.BillingCity;
        c.MailingCity__c = acc.BillingCity;
      }
    }

    c.MailingCountry = 'ITALIA';
    c.MailingCountry__c = 'ITALIA';

    if(String.isBlank(c.MailingStreet) || String.isBlank(c.MailingStreetName__c) || String.isBlank(c.MailingStreetNumber__c) ||
       String.isBlank(c.MailingStreetType__c) || String.isBlank(c.MailingCity) || String.isBlank(c.MailingState) ||
       String.isBlank(c.MailingPostalCode)){
      c.MailingStreet = acc.BillingStreet;
      c.MailingStreetName__c = acc.BillingStreetName__c;
      c.MailingStreetNumber__c = acc.BillingStreetNumber__c;
      c.MailingStreetType__c = acc.BillingStreetType__c;
      c.MailingCity = acc.BillingCity;
      c.MailingState = acc.BillingState;
      c.MailingPostalCode = acc.BillingPostalCode;
    } 

    UtilAnagrafiche.truncateInSObject(c, new String[]{
      'MailingStreetName__c',
      'MailingStreetNumber__c',
      'MailingCity',
      'MailingCity__c',
      'MailingState',
      'MailingState__c',
      'MailingPostalCode',
      'MailingPostalCode__c'
    }, 24);
    
    return c;
  }

  @RemoteAction
  public static Boolean insertContacts(List<Contact> inputContacts) {
    System.debug('SV insert Contact');
    System.debug(inputContacts);
    try {
      insert inputContacts;
      return true;
    } catch (DmlException err) {
      throw new Ex.WSException(err.getDmlMessage(0), err);
    }
  }

  @RemoteAction
  public static Id upsertContact(Contact c, AccountContactRelation[] r, String source) {
    System.debug(c);
    System.SavePoint sp = Database.setSavePoint();

    try {
      upsert c;
      Set<Id> accIds = U.getIdSet(r, 'AccountId');

      delete [SELECT Id FROM AccountContactRelation WHERE ContactId = :c.Id AND IsDirect = FALSE AND AccountId NOT IN :accIds];
      Map<String, SObject> accId2acr = U.keyBy([SELECT Id, AccountId, Roles FROM AccountContactRelation WHERE ContactId = :c.Id], 'AccountId');
      Integer i = 0;
      while (i < r.size()) {
        AccountContactRelation acr = r[i];
        if (String.isEmpty(acr.AccountId)) {
          r.remove(i);
        } else {
          acr.ContactId = c.Id;
          if (accId2acr.containsKey(acr.AccountId)) {
            acr.Id = accId2acr.get(acr.AccountId).Id;
          }
          i++;
        }
      }
      if (!r.isEmpty()) upsert r;

      // Nel caso di filo diretto chiamata inbound, il canale dell'account principale va impostato a web
      // con sottocanale 101 (numero verde), se questo non è già web (5) o indiretto (4)
      if (source == 'fdInbound') {
        Account a = [SELECT Id, CanaleSviluppo__c, Sottocanale__c FROM Account WHERE Id = :c.AccountId];
        if (a.CanaleSviluppo__c != CANALE_WEB && a.CanaleSviluppo__c != CANALE_INDIRETTO) {
          a.CanaleSviluppo__c = CANALE_WEB;
          a.Sottocanale__c = SOTTOCANALE_NVERDE;
          update a;
        }
      }
    } catch (DmlException e) {
      Database.rollback(sp);
      throw new Ex.WSException(e.getDmlMessage(0), e);
    }

    // se l'upsert e' andata a buon fine allineo i dati su Cedacri (censendo o aggiornando l'anagrafica)
    if (source != 'fdInbound' && !isPolandSearch()) {
      if (String.isBlank(c.NDGGruppo__c))
        WsAnagrafeUtils.censimentoLightAsync(c.id);
      else
        WsAnagrafeUtils.variazioneAsync(c.id);
    }
    return c.Id;
  }

  @RemoteAction
  public static Id WGC_upsertContact(Contact c, Account acc, AccountContactRelation[] r, String source, String tipoCensimento) {
    System.debug('SV upsert Contact');
    System.debug(c);
    System.debug(acc);
    System.debug(r);
    System.debug(source);
    System.debug(tipoCensimento);

    String ndgAccount = acc.NDGGruppo__c;
    System.debug(ndgAccount);

    try {
      System.debug(c.NDGGruppo__c);
      System.debug('SV isPolandSearch: ' + isPolandSearch());
      if(!isPolandSearch()){ // CENSIMENTO - AVVIENE SOLO SE NON SEI IFIS FINANCE (889)
        if (String.isBlank(c.NDGGruppo__c)){
          if(tipoCensimento == 'light'){
            c.NDGGruppo__c = WsAnagrafeUtils.censimentoLight(NULL, c);
            // WsRestPefMutui.allineaKnet((String) c.NDGGruppo__c);
          } else {
            c.NDGGruppo__c = WsAnagrafeUtils.WGC_censimentoFull(NULL, c);
            // WsRestPefMutui.allineaKnet((String) c.NDGGruppo__c);
          }
        } else {
            c.NDGGruppo__c = WsAnagrafeUtils.WGC_variazione(NULL, c);
        }
      }

    } catch (Exception e) {

      if(tipoCensimento == 'light'){
        Logger.log('REF_CensimentoLight', e.getMessage() + ' - ' + e.getStackTraceString());
      } else {
        Logger.log('REF_CensimentoFull',  e.getMessage() + ' - ' + e.getStackTraceString());
      }
        // inputAccount.StatoCensimento__c = 'Errore durante censimento';
        // inputAccount.DettaglioCensimento__c = 'Errore censimento ' + tipoCensimento + ': ' +  e.getMessage();
        // throw e;
        throw new Ex.WSException(e.getMessage(), e);

    }

      if (!System.isFuture()) { //il metodo allinea KNET è future e non possiamo chiamarlo da un altro future (p.e. TiAnticipo)
          if(!System.isBatch()){ //FUTURE
              System.debug('SV NON BATCH');
              WsRestPefMutui.syncAllineaKnet((String) c.NDGGruppo__c);
              
          } else {
              System.debug('SV BATCH');
              if(String.isNotEmpty(c.NDGGruppo__c)) {
                  WsRestPefMutui.AllineaKnetResponse resKnetContact = WsRestPefMutui.allineaKnet((String) c.NDGGruppo__c);
                  System.debug('SV KNET RESPONSE CONTACT: ' + resKnetContact);
              }
              
          }
      }

    System.SavePoint sp = null;
    if(!Test.isRunningTest()) sp = Database.setSavePoint();
    try {
        TrgContact.skipCheckCodiceFiscale = true;
        upsert c CI3N_CF__c;
        Set<Id> accIds = U.getIdSet(r, 'AccountId');

        delete [SELECT Id FROM AccountContactRelation WHERE ContactId = :c.Id AND IsDirect = FALSE AND AccountId NOT IN :accIds];
        Map<String, SObject> accId2acr = U.keyBy([SELECT Id, AccountId, WGC_Ruolo__c FROM AccountContactRelation WHERE ContactId = :c.Id], 'AccountId');
        Integer i = 0;
        while (i < r.size()) {
          AccountContactRelation acr = r[i];
          if (String.isEmpty(acr.AccountId)) {
            r.remove(i);
          } else {
            acr.ContactId = c.Id;
            if (accId2acr.containsKey(acr.AccountId)) {
              acr.Id = accId2acr.get(acr.AccountId).Id;
            }
            i++;
          }
        }
        if (!r.isEmpty()) upsert r;

      // Nel caso di filo diretto chiamata inbound, il canale dell'account principale va impostato a web
      // con sottocanale 101 (numero verde), se questo non è già web (5) o indiretto (4)
      if (source == 'fdInbound') {
        Account a = [SELECT Id, CanaleSviluppo__c, Sottocanale__c FROM Account WHERE Id = :c.AccountId];
        if (a.CanaleSviluppo__c != CANALE_WEB && a.CanaleSviluppo__c != CANALE_INDIRETTO) {
          a.CanaleSviluppo__c = CANALE_WEB;
          a.Sottocanale__c = SOTTOCANALE_NVERDE;
          update a;
        }
      }
    } catch (DmlException e) {
      if(!Test.isRunningTest()) Database.rollback(sp);
      throw new Ex.WSException(e.getDmlMessage(0), e);
    }

    //FUTURE KNET
    //  WsRestPefMutui.syncAllineaKnet((String) c.NDGGruppo__c);
    //END FUTURE

    return c.Id;
  }

  /**
   * Cerca Account collegati al Referente
   * @param c: id del Referente
   * @param ndg: ndg del Referente, se presente
   * @return AccountContactRelation[]: lista di AccountContactRelation già presenti su Salesforce
   * o su Cedacri (di cui ho l'accountId su Salesforce)
   */
  @RemoteAction
  public static AccountContactRelation[] getRelations(String contactId, String contactNdg) {

    AccountContactRelation[] acrInSalesforceList = new List<AccountContactRelation>();
    Map<String, SObject> acrInSalesforceMap = new Map<String, SObject>();
    Id cId = String.isBlank(contactId) ? null : (Id) contactId;

    // se ho l'ID del Referente cerco su Salesforce relazioni Account-Referente gia' esistenti..
    if (cId != null) {
      acrInSalesforceList = [SELECT
        AccountId,
        ContactId,
        Roles,
        IsDirect
        FROM AccountContactRelation
        WHERE ContactId = :cId
        ORDER BY CreatedDate ASC
      ];
      acrInSalesforceMap = U.keyBy(acrInSalesforceList, 'AccountId');
    }

    // ..se ho l'NDG cerco su Cedacri eventuali account collegati al Referente..
    if (!String.isBlank(contactNdg)) {
      try {
        WsAnagrafe.GestioneCollNdgResponse response = WsAnagrafe.GestioneCollNdg(contactNdg);
        String[] ndgCollegati = new List<String>();
        List<Account> accountIds = new List<Account>();

        for (WsAnagrafe.ElementoNdg elemento : response.payload.elementi) {
          if (elemento.Ndg != Long.valueOf(contactNdg)) ndgCollegati.add(String.valueOf(elemento.Ndg));
        }

        if (!ndgCollegati.isEmpty()) accountIds = [
          SELECT Id
          FROM Account
          WHERE NDGGruppo__c IN :ndgCollegati
          AND CodiceIstituto3N__c = :ImpostazioniServizi__c.getInstance().CodiceIstituto3N__c
        ];

        // ..che aggiungo alla lista di AccountContactRelation, se presenti su Salesforce
        for (Account acc : accountIds) {
          if (!acrInSalesforceMap.containsKey(acc.Id)) {
            AccountContactRelation acr = new AccountContactRelation(AccountId = acc.Id);
            acrInSalesforceList.add(acr);
          }
        }
      } catch (Exception e) {
        throw new Ex.AnagrafeDiGruppoException(Label.ErroreRichiestaCedacri +  ': ' + e + e.getStackTraceString());
      }
    }
    return acrInSalesforceList;
  }

  @RemoteAction
  public static Contact getContatto(String contactId) {
    return (Contact) Database.query(
      QueryBuilder.newInstance(
        'Contact',
        WsAnagraficaBean.REQUIRED_CONTACT_FIELDS,
        new String[] {
          'AccountId',
          'StatoFastFinance__c',
          'PEP__c',
          'PEPTipoCarica__c'
        }
      ).withId(contactId).getQuery()
    );
  }

  /*** METODI DI UTILITY PER IL RECUPERO ANAGRAFICHE **/
  public static List<Account> searchAnagraficaSFDC(String paramSearch, String provinceCode, Boolean searchByName) {
    String ci3n = ImpostazioniServizi__c.getInstance().CodiceIstituto3N__c;
    List<Account> accountSFDC = Database.query(
      QueryBuilder.newInstance('Account', WsAnagraficaBean.REQUIRED_ACCOUNT_FIELDS, new String[]{
        'RecordType.Name',
        'Origine__c',
        'CodiceIstituto3N__c',
        'Phone',
        'Website',
        'EmailPEC__c',
        'StatoCensimento__c',
        'RAE__c' //adione-crm20
      }).beginFilter()
        .beginOr()
          .add('PIVA__c', QBOp.QLIKE, '%' + paramSearch + '%', !searchByName)
          .add('CF__c', QBOp.QLIKE, '%' + paramSearch + '%', !searchByName)
		  .add('NDGGruppo__c', QBOp.QLIKE, '%' + paramSearch + '%', !searchByName) //adione CRM ID 80
        .end()
        .add('Name', QBOp.QLIKE, '%' + paramSearch + '%', searchByName)
        .add('CodiceIstituto3N__c', QBOp.QEQUAL, ci3n, ci3n == CI3N_FACTORING)
        .add('BillingState', QBOp.QEQUAL, provinceCode, String.isNotBlank(provinceCode))
      .endFilter()
      .setLimit(100)
      .getQuery()
    );

    // ho memorizzato origine vera, ma qua voglio mostrare CRM?
    U.massSet(accountSFDC, 'Origine__c', ORIGINE_CRM);
    return accountSFDC;
  }

  public static List<Account> searchAnagraficaSFDC_NDG(String ndg) {
    String ci3n = ImpostazioniServizi__c.getInstance().CodiceIstituto3N__c;
    List<Account> accountSFDC = Database.query(
      QueryBuilder.newInstance('Account', WsAnagraficaBean.REQUIRED_ACCOUNT_FIELDS, new String[]{
        'RecordType.Name',
        'Origine__c',
        'CodiceIstituto3N__c',
        'Phone',
        'Website',
        'EmailPEC__c',
        'StatoCensimento__c',
        'RAE__c' //adione-crm20
      }).beginFilter()
		.add('NDGGruppo__c', QBOp.QLIKE, ndg, true) //adione CRM ID 80
        .add('CodiceIstituto3N__c', QBOp.QEQUAL, ci3n, ci3n == CI3N_FACTORING)
      .endFilter()
      .setLimit(100)
      .getQuery()
    );

    // ho memorizzato origine vera, ma qua voglio mostrare CRM?
    U.massSet(accountSFDC, 'Origine__c', ORIGINE_CRM);
    return accountSFDC;
  }

  public static List<Account> searchAnagraficaRibes(String denominazione, String cf, String provinceCode) {
    List<Account> foundAccount = new List<Account>();

    WsRestRibes.GetListaAziendeResponse res = WsRestRibes.getListaAziende(denominazione, cf, provinceCode);
    for (WsRestRibes.Impresa r : res.getAziende(provinceCode)) {
      //TODO: check mapping
      //MISSING!
      //a.BillingIstatCode__c = r.ISTATCodeMunicipality;
      //

      Account a = new Account(
        Name = r.denominazione,
        NaturaGiuridica__c = r.getFormaGiuridica(),
        ProvinciaCCIAA__c = r.cciaa,
        REA__c = r.nRea,
        PIVA__c = r.pIva,
        VAT__c = r.pIva,
        //adione SDHDFNZ-94034
		CF__c = r.codFisc.toUpperCase().trim(),
        Origine__c = WsRestRibes.RIBES,
        CodiceIstituto3N__c = ImpostazioniServizi__c.getInstance().CodiceIstituto3N__c
      );

      if (r.ateco07 != null) {
        a.DettaglioSettore__c = r.ateco07.cod;
		a.Ateco__c = r.ateco07.cod;
      }

      // if (r.indirizzo != null) {
      //   a.ShippingStreet = String.join(new String[]{
      //     r.indirizzo.toponimo,
      //     r.indirizzo.via,
      //     r.indirizzo.nCivico
      //   }, ' ');

      //   a.ShippingCity = r.indirizzo.comune;
      //   if (r.indirizzo.provincia != null) {
      //     a.ShippingState = r.indirizzo.provincia.content;
      //   }
      //   a.ShippingPostalCode = r.indirizzo.cap;
      //   a.ShippingStreetName__c = r.indirizzo.via;
      //   a.ShippingStreetNumber__c = r.indirizzo.nCivico;
      //   a.ShippingStreetType__c = r.indirizzo.toponimo;

      //   a.BillingStreet = a.ShippingStreet;
      //   a.BillingCity = a.ShippingCity;
      //   a.BillingPostalCode = a.ShippingPostalCode;
      //   a.BillingState = a.ShippingState;
      //   a.BillingStreetName__c = a.ShippingStreetName__c;
      //   a.BillingStreetNumber__c = a.ShippingStreetNumber__c;
      //   a.BillingStreetType__c = a.ShippingStreetType__c;
      // }

      if (r.indirizzo != null) {
          
        a.BillingStreet = String.join(new String[]{
          r.indirizzo.toponimo,
          r.indirizzo.via,
          r.indirizzo.nCivico
        }, ' ');

        a.BillingCity = r.indirizzo.comune;
        if (r.indirizzo.provincia != null) {
          a.BillingState = r.indirizzo.provincia.content;
		  if (a.BillingState != null && a.BillingState != 'EE') {
			a.BillingCountry = 'ITALIA';
			a.BillingCountry__c = 'ITALIA';
			}
        }
        a.BillingPostalCode = r.indirizzo.cap;
        a.BillingStreetName__c = r.indirizzo.via;
        a.BillingStreetNumber__c = r.indirizzo.nCivico;
        a.BillingStreetType__c = r.indirizzo.toponimo;
      }

      if (r.statoAttivitaR != null) {
        a.StatoAnagrafica__c = r.statoAttivitaR.content;
      }

      // Rimosso il settaggio del recordType in prospect per le Anagrafiche censite da Ribes
      a.RecordTypeId = U.getRecordTypes('Account').get('Cliente').Id;

      foundAccount.add(a);
    }

    System.debug('SV foundAccount: ' + foundAccount);

    return foundAccount;
  }

  @RemoteAction
  public static Contact cwaFetchContact(Contact c) {
    // Logger.setTransactionContext(null, c.Id);
    try {
      return (Contact) WsAnagrafeUtils.mergeWithCedacri(c);
    } catch (Exception e) {
      throw new Ex.WSException(Label.ErroreRecuperoAnagCedacri + ' ' + e.getMessage(), e);
    }
  }

  @RemoteAction
  public static Ateco__c[] fetchAteco() {
    return [SELECT
      Cedacri__c,
      Descrizione__c,
      RAE__c
      FROM Ateco__c
      ORDER BY Descrizione__c
    ];
  }

  @RemoteAction
  public static NaturaGiuridicaSAE__mdt[] fetchRelazioneNgSae() {
    return [SELECT
      Label,
      SAE__c,
      AtecoRichiesto__c,
      RaeRichiesto__c,
      SedeLegale__c
      FROM NaturaGiuridicaSAE__mdt
    ];
  }

  @RemoteAction
  public static List<Map<String,Object>> getRiepilogoAccountTeam(Id accountId) {
    List<Map<String,Object>> result = new List<Map<String, Object>>();
    AccountTeamMember[] atmList = [SELECT Id,
      UserId,
      User.Name,
      toLabel(TeamMemberRole)
      FROM AccountTeamMember
      WHERE AccountId = :accountId];

    if (atmList.size() != 0) {
      for (AccountTeamMember atm : atmList) {
        result.add(new Map<String, Object> {
          'icona' => 'action-user',
          'id' => atm.Id,
          'nome' => atm.User.Name,
          'ruolo' => atm.TeamMemberRole
        });
      }
    }
    return result;
  }

  @RemoteAction
  public static Map<String, Map<String, Object>> getFieldSets(String fieldSetList, Id sObjectId, String sObjectName) {
    Boolean considerAllFieldSets = String.isBlank(fieldSetList) || fieldSetList.equals('*');
    Set<String> fsSet = new Set<String>();
    Map<String, Schema.FieldSet> fsMap = Schema.getGlobalDescribe().get(sObjectName).getDescribe().FieldSets.getMap();
    Map<String, Map<String, Object>> result = new Map<String, Map<String, Object>>();
    Set<String> fields = new Set<String>();
    fsSet = (considerAllFieldSets) ? fsMap.keySet() : U.toSet(fieldSetList.split(';'));

    // prendo da CRM i valori dei campi contenuti nei fieldSet specificati per l'account corrente
    for (String fieldSetName : U.toList(fsSet)) {
      for(Schema.FieldSetMember f : fsMap.get(fieldSetName.trim()).getFields()) fields.add(f.getFieldPath());
    }
    String query = 'SELECT ' + String.join(U.toList(fields), ', ') + ' FROM ' + sObjectName + ' WHERE Id = :sObjectId';
    // Account a = (Account) Database.query(query)[0];
    SObject sObj = Database.query(query)[0];

    // costruisco la mappa
    for (String fieldSetName : U.toList(fsSet)) {
      Map<String, Object> fieldValues = new Map<String, Object>();
      for (Schema.FieldSetMember f : fsMap.get(fieldSetName).getFields()) {
        fieldValues.put(f.getFieldPath(), (sObj.get(f.getFieldPath()) == null) ? '' : sObj.get(f.getFieldPath()));
      }
      result.put(fsMap.get(fieldSetName).getLabel(), fieldValues);
    }
    return result;
  }

  @RemoteAction
  public static Id upsertObject(String obj, String objName) {
    SObject objToUpsert = (SObject) JSON.deserialize(obj, Type.forName(objName));
    upsert objToUpsert;
    return (Id) objToUpsert.get('Id');
  }

  /**
   * Metodo che verifica che l'utente corrente abbia un profilo tra quelli specificati dal parametro 'profileList'.
   * @param  profileList  lista dei profili accettati, separati da ';',
                          se popolato con valore '*' vengono considerati tutti i profili,
                          se popolato con valore 'AdminsOnly' o vuoto vengono considerati solo i profili degli amministratori
   * @return              true, se l'utente corrente è tra i profili specificati; false altrimenti
   */
  @RemoteAction
  public static Boolean renderModifica(String profileList) {
    Boolean considerAllProfiles = profileList.equals('*');
    Boolean considerAdminsOnly = String.isBlank(profileList) || profileList.equals('AdminsOnly');
    Set<String> profileSet = new Set<String>{'System Administrator', 'Amministratore del sistema'};
    if (!considerAllProfiles && !considerAdminsOnly) profileSet.addAll(U.toSet(profileList.split(';')));

    String profileQuery = QueryBuilder.newInstance('Profile', new String[] {'Id'})
      .beginFilter()
        .add('Name', QBOp.QIN, profileSet, !considerAllProfiles)
        .endFilter()
      .getQuery();

    return U.getIdSet(Database.query(profileQuery), 'Id').contains(UserInfo.getProfileId());
  }

  /*
  * TEN SV - Aggiunto la possibilità di effettuare un censimento full o light a secondo della scelta tipoCensimento
  */
  @RemoteAction
  public static Id WGC_insertAccount(Account inputAccount, String source, Boolean zIgnoreErrors,  String tipoCensimento, Contact contactDI) {
    System.debug('SV insertAccount Account: ' + inputAccount);
    System.debug('SV source: ' + source);
    System.debug('SV zIgnoreErrors: ' + zIgnoreErrors);
    System.debug('SV tipoCensimento: ' + tipoCensimento);
    System.debug('SV contactDI: ' + contactDI);
    Logger.setTransactionContext(null, inputAccount.Id);

    // troncamenti a 24 caratteri
    truncateAccount(inputAccount);

    // se inserimento nuovo account da modale, setto owner a utente default
    // Id defaultOwner = UtenzeDefault__c.getInstance().IdUtente__c;
    // if(inputAccount.Id == null && (source == 'woInserimentoDebitori' || source == 'woInserimentoGaranti')) {
    //   inputAccount.OwnerId = defaultOwner;
    // }

    String canaleSviluppo = (inputAccount.Id != null) ? [SELECT CanaleSviluppo__c FROM Account WHERE Id = :inputAccount.Id].CanaleSviluppo__c : '';

    // Per i prospect il canale è 2 => Diretto, a meno che source non valga fdInbound.
    // In quel caso è web / numero verde e valorizzo anche la data ultima importazione da web.
    if (source == 'fdInbound') {
      inputAccount.CanaleSviluppo__c = CANALE_WEB;
      inputAccount.Sottocanale__c = SOTTOCANALE_NVERDE;
      inputAccount.DataUltimaImportazioneDaWeb__c = Datetime.now();
    } else if (canaleSviluppo != CANALE_WEB && canaleSviluppo != CANALE_INDIRETTO) {
    // Se il canale = web o indiretto, non lo modifico.
      inputAccount.CanaleSviluppo__c = CANALE_DIRETTO;
    }

    // TODO QUESTA PARTE VA RIVISTA (inizio)
    Contact[] referentiRibes = new Contact[]{};
    if (inputAccount.Origine__c == WsRestRibes.RIBES) {
      //se c'è un errore nel recupero dei referenti Ribes, l'account deve comunque essere inserito,
      //per cui non lancio eccezioni, ma creo solo un Log__c
      try {
        referentiRibes = new WsRestRibesUtils().getContacts(inputAccount.Id, inputAccount.REA__c, inputAccount.ProvinciaCCIAA__c);
      } catch(Exception e) {}
    }

    System.debug('SV referentiRibes before: ' + referentiRibes);
    System.debug('SV inputAccount.Origine__c: ' + inputAccount.Origine__c);
    System.debug('SV inputAccount.Area__c: ' + inputAccount.Area__c);
      
    // A.M. -> START
    Boolean insertReteDI = false;
    // A.M. -> END  
    Contact diContact;
    if (inputAccount.NaturaGiuridica__c == 'DI' && tipoCensimento != 'variazione' ) {
	  //A.M.

      if (inputAccount.Origine__c == WsRestRibes.RIBES) {
        Integer diIndex = null;
        if(System.isBatch()){
          tipoCensimento = 'light';
        }
        for (Integer i = 0; i < referentiRibes.size(); i++) {
          if (referentiRibes[i].CF__c == inputAccount.CF__c) {
            diIndex = i;
            break;
          }
        }
        System.debug('@@@ diIndex: ' + diIndex);
		System.debug('@@@ contactDI: ' + contactDI);
        if (diIndex != null) {
          Contact contattoRimosso = referentiRibes.remove(diIndex);
          if (contactDI != null){
            Contact contactDocu = new Contact(TipoDocumentoId__c = contactDI.TipoDocumentoId__c, NumeroDoc__c = contactDI.NumeroDoc__c, DataEmissioneDoc__c = contactDI.DataEmissioneDoc__c, DataScadenzaDoc__c = contactDI.DataScadenzaDoc__c, LuogoEmissioneDoc__c = contactDI.LuogoEmissioneDoc__c);
            diContact = CtrlWizardAccount.cwaFetchContact(contactDI);
            diContact = compliteDIContact(inputAccount, diContact, contattoRimosso, contactDocu);
          } else {
            diContact = compliteDIContact(inputAccount, contattoRimosso, null, null);
          }
        } else {
		//A.M. Gestione del contatto della DI nel caso in cui non ci sia il referente tra i dati dell'Infoprovider
		  if (contactDI != null){
            Contact contactDocu = new Contact(TipoDocumentoId__c = contactDI.TipoDocumentoId__c, NumeroDoc__c = contactDI.NumeroDoc__c, DataEmissioneDoc__c = contactDI.DataEmissioneDoc__c, DataScadenzaDoc__c = contactDI.DataScadenzaDoc__c, LuogoEmissioneDoc__c = contactDI.LuogoEmissioneDoc__c);
            diContact = CtrlWizardAccount.cwaFetchContact(contactDI);
            diContact = compliteDIContact(inputAccount, diContact, null, contactDocu);
          } else {
            throw new Ex.WSException(Label.ErroreRecuperoDIRibes);
          }
        }
      } else if (inputAccount.Area__c != 'EE') {
        if (contactDI != null){
          Contact contactDocu = new Contact(TipoDocumentoId__c = contactDI.TipoDocumentoId__c, NumeroDoc__c = contactDI.NumeroDoc__c, DataEmissioneDoc__c = contactDI.DataEmissioneDoc__c, DataScadenzaDoc__c = contactDI.DataScadenzaDoc__c, LuogoEmissioneDoc__c = contactDI.LuogoEmissioneDoc__c);
          diContact = CtrlWizardAccount.cwaFetchContact(contactDI);
          diContact = compliteDIContact(inputAccount, diContact, null, contactDocu);
        }
      }
    }
    // TODO QUESTA PARTE VA RIVISTA (fine)

    System.debug('SV referentiRibes after: ' + referentiRibes);

    //censimento light o full account sincrono
    /*
      *
      */
      System.debug('SV diContact: ' + diContact);
      System.debug('SV inputAccount.NDGGruppo__c: ' + inputAccount.NDGGruppo__c);
      try {
        /*
         * TEN - SV: Viene eseguito il censimento Light o Full a secondo di quello scelto nella modale 
         * in questa fase viene staccato l'ndg per l'anagrafica se non presente altrimente verra eseguito 
         * semplicemente una variazione.
         * Inoltre viene verificato se è presente un diContact (presente se si tratta di ditta individuale)
         * in tal caso anche in questo caso sarà eseguito un censimento o una variazione a seconda in base che sia
         * presente o no l'ndg
         *
         */
        // if (source != 'fdInbound' && String.isBlank(inputAccount.NDGGruppo__c) && !isPolandSearch())

        if(!isPolandSearch()){ // CENSIMENTO - AVVIENE SOLO SE NON SEI IFIS FINANCE (889)
          if (String.isBlank(inputAccount.NDGGruppo__c)){
            if(tipoCensimento == 'light'){
              inputAccount.NDGGruppo__c = WsAnagrafeUtils.censimentoLight(inputAccount, diContact);              
			  inputAccount.NDGGruppo__c = WsAnagrafeUtils.WGC_variazione(inputAccount, diContact);
			  inputAccount.StatoCensimento__c = CtrlCensimento.CENSIMENTO_OK;
            } else {
              inputAccount.NDGGruppo__c = WsAnagrafeUtils.WGC_censimentoFull(inputAccount, diContact);
              inputAccount.StatoCensimento__c = CtrlCensimento.CENSIMENTO_FULL_OK;
            }
          } else {
            if(!System.isBatch()){
              inputAccount.NDGGruppo__c = WsAnagrafeUtils.WGC_variazione(inputAccount, diContact);
            }
          }

          if (diContact != null) {
            if (String.isBlank(diContact.NDGGruppo__c)){
                if(tipoCensimento == 'light'){
                  diContact.NDGGruppo__c = WsAnagrafeUtils.censimentoLight(null, diContact);
                  diContact.StatoCensimento__c = CtrlCensimento.CENSIMENTO_OK;
                  // WsRestPefMutui.allineaKnet((String) diContact.NDGGruppo__c);
                } else {
                  diContact.NDGGruppo__c = WsAnagrafeUtils.WGC_censimentoFull(null, diContact);
                  diContact.StatoCensimento__c = CtrlCensimento.CENSIMENTO_FULL_OK;
                }
                // A.M. -> START
                WsAnagrafe.GestioneCollNdgResponse response = WsAnagrafe.associaPfPgCollNdg(inputAccount.NDGGruppo__c, diContact.NDGGruppo__c, 'TITOP', false);
                insertReteDI = true;
                // A.M. -> END
            } else {
              if(!System.isBatch()){
                diContact.NDGGruppo__c = WsAnagrafeUtils.WGC_variazione(null, diContact);
              }
            }
          }

          // TEN - SV PRESUNTO ERRORE DOVUTO ALL CONTATTO NON FULL 

          if (!referentiRibes.isEmpty()) {
            for (Integer i = 0; i < referentiRibes.size(); i++) {
              referentiRibes[i] = CtrlWizardAccount.cwaFetchContact(referentiRibes[i]);
              
              referentiRibes[i] = ContactVerifyResidenza(inputAccount, referentiRibes[i]);
              referentiRibes[i].TAECode__c = '984';

              System.debug('referentiRibes[i]: ' + referentiRibes[i]);
              if(String.isBlank(referentiRibes[i].NDGGruppo__c)){
                referentiRibes[i].NDGGruppo__c = WsAnagrafeUtils.censimentoLight(null, referentiRibes[i]);
              }

              // System.debug('SV GestioneCollNdgResponse inputAccount.NDGGruppo__c: ' + inputAccount.NDGGruppo__c);
              // System.debug('SV GestioneCollNdgResponse referentiRibes[i].NDGGruppo__c: ' + referentiRibes[i].NDGGruppo__c);

              // WsAnagrafe.GestioneCollNdgResponse response = WsAnagrafe.associaPfPgCollNdg(inputAccount.NDGGruppo__c, referentiRibes[i].NDGGruppo__c, 'TITEF', true);
              // System.debug('SV response GestioneCollNdgResponse: ' + response);

              referentiRibes[i].StatoCensimento__c = CtrlCensimento.CENSIMENTO_OK;
            }
          }
        } else {
          System.debug('IL CENSIMENTO SU CEDACRI NON AVVIENE - IFIS FINANCE');
        }

      } catch (Exception e) {
        // Se mi sto registrando a TiAnticipo e il censimento non ha buon fine, proseguo
        if (!zIgnoreErrors) throw e;

        if (tipoCensimento == 'light') {
          Logger.log('ANAG_CensimentoLight', e.getMessage() + ' - ' + e.getStackTraceString());
        } else if (tipoCensimento == 'variazione') {
          Logger.log('ANAG_Variazione', e.getMessage() + ' - ' + e.getStackTraceString());
        } else {
          Logger.log('ANAG_CensimentoFull',  e.getMessage() + ' - ' + e.getStackTraceString());
        }
        // inputAccount.StatoCensimento__c = 'Errore durante censimento';
        // inputAccount.DettaglioCensimento__c = 'Errore censimento ' + tipoCensimento + ': ' +  e.getMessage();

      }

    if(!System.isBatch()){ //FUTURE
      System.debug('SV NON BATCH');
      if (String.isNotEmpty(inputAccount.NDGGruppo__c) && inputAccount.Origine__c == WsAnagrafe.CEDACRI) {
        WsAnagrafeUtils.syncCollegamentiAsync(inputAccount.NDGGruppo__c, inputAccount.Id);
      }

      WsRestPefMutui.syncAllineaKnet((String) inputAccount.NDGGruppo__c);
      if (diContact != null) {
        WsRestPefMutui.syncAllineaKnet((String) diContact.NDGGruppo__c);
      }

      if (!referentiRibes.isEmpty()) {
        for (Integer i = 0; i < referentiRibes.size(); i++) {
          WsRestPefMutui.syncAllineaKnet((String) referentiRibes[i].NDGGruppo__c);
        }
      }
    } else { //END FUTURE
      System.debug('SV BATCH');

      if (String.isNotEmpty(inputAccount.NDGGruppo__c) && inputAccount.Origine__c == WsAnagrafe.CEDACRI) {
        //ToDo

      }

      if (String.isNotEmpty(inputAccount.NDGGruppo__c)) {
        WsRestPefMutui.AllineaKnetResponse resKnetAccount = WsRestPefMutui.allineaKnet((String) inputAccount.NDGGruppo__c);
        System.debug('SV KNET RESPONSE: ' + resKnetAccount);
      }
        
      if (diContact != null && String.isNotEmpty(diContact.NDGGruppo__c)) {
        WsRestPefMutui.AllineaKnetResponse resKnetContact = WsRestPefMutui.allineaKnet((String) diContact.NDGGruppo__c);
        System.debug('SV KNET RESPONSE DI: ' + resKnetContact);
      }

      if (!referentiRibes.isEmpty()) {
        for (Integer i = 0; i < referentiRibes.size(); i++) {
          if(String.isNotEmpty(referentiRibes[i].NDGGruppo__c)){
            WsRestPefMutui.AllineaKnetResponse resKnetContactRibes = WsRestPefMutui.allineaKnet((String) referentiRibes[i].NDGGruppo__c);
            System.debug('SV KNET RESPONSE RIBES CONTACT: ' + resKnetContactRibes);
          }
        }
      }

    }

    //inserimento account in CRM
    System.SavePoint sp = null;
    if(!Test.isRunningTest()) sp = Database.setSavePoint();
    try {
      upsert inputAccount;
      //inserimento DI
      if (diContact != null) {
        diContact.AccountId = inputAccount.Id;
        TrgContact.skipCheckCodiceFiscale = true;
        System.debug('SV BEFOR UPDATE CONTACTDI: ' + diContact);
        if(!System.isBatch()){
              upsert diContact CI3N_CF__c;
          } else {
              if(diContact.CI3N_NDGGruppo__c != null){
              	upsert diContact CI3N_NDGGruppo__c;
              } else {
                upsert diContact;
              }
          }
          // A.M. -> START
          if (insertReteDI==true) {
              List<AccountContactRelation> accContaRelaList = [SELECT WGC_Ruolo__c FROM AccountContactRelation WHERE WGC_NDG_Account__c =: inputAccount.NDGGruppo__c AND WGC_NDG_Referente__c =: diContact.NDGGruppo__c];
              if (!accContaRelaList.isEmpty()){
                  for(AccountContactRelation accConRel : accContaRelaList){
			          accConRel.WGC_Ruolo__c = 'U';
                  }
                  UPDATE accContaRelaList; 
              }
          }
          // A.M. -> END
      }
      Logger.setTransactionContext(null, inputAccount.Id);
    } catch (DmlException e) {
      if(!Test.isRunningTest()) Database.rollback(sp);
      if(tipoCensimento == 'light'){
        Logger.log('ANAG_CensimentoLight', e.getDmlMessage(0) + ' - ' + e.getStackTraceString());
      } else {
        Logger.log('ANAG_CensimentoFull',  e.getDmlMessage(0) + ' - ' + e.getStackTraceString());
      }
      throw new Ex.WSException(Label.ErroreInserimentoAccCont + ' ' + e.getDmlMessage(0), e);
    }

    //inserimento referenti ribes
    if (!referentiRibes.isEmpty()) {

      try {
        U.massSet(referentiRibes, 'AccountId', inputAccount.Id);
        System.debug('SV referentiRibes salvatoaggio: ' + referentiRibes);
        insert referentiRibes;
      } catch (DMLException e) {
        Logger.log('RIBES_ReferentiRibes', e.getDmlMessage(0) + ' - ' + e.getStackTraceString());
      }
    }

    if(!System.isBatch()){ //FUTURE
      System.debug('SV NON BATCH');
      if (String.isNotEmpty(inputAccount.NDGGruppo__c) && inputAccount.Origine__c == WsAnagrafe.CEDACRI) {
        WsAnagrafeUtils.syncCollegamentiAsync(inputAccount.NDGGruppo__c, inputAccount.Id);
      }
    }

    return inputAccount.Id;
  }
}