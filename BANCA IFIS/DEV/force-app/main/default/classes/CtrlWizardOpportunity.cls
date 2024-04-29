/**
* Progetto:         Banca IFIS
* Sviluppata il:    22/12/2016
* Developer:        Zerbinati Francesco, Michele Triaca
*/

public with sharing class CtrlWizardOpportunity {
  public static final String ERROR_CONFIGURAZIONE_NC = 'Questa configurazione non è stata prevista. Contatta la Direzione Commerciale per maggiori informazioni.';
  public static final String ERROR_CONFIGURAZIONE_NV = 'Questa configurazione non è supportata. Configura su Nuova Vendita.';
  public static final String ERROR_CONFIGURAZIONE = 'Questa configurazione non esiste.';
  public static final Set<String> PARAMS_SINGLE_VALUE_ON_DEROGA = new Set<String>{'C163','C162','C166','C167','D104','D163'};
  public CtrlWizardOpportunity(ApexPages.StandardController ctrl) {}

  public class WoPayload {
    @AuraEnabled public Id opportunityId;
    @AuraEnabled public Boolean tiAnticipo; // TODO TIANTICIPO
    @AuraEnabled public Id[] referenti;
    @AuraEnabled public WoProdotto[] pfi;
    @AuraEnabled public WoProdotto[] pb;
    @AuraEnabled public WoProdotto[] linee;
    @AuraEnabled public Boolean fd;
    @AuraEnabled public Boolean confirming;
    @AuraEnabled public Boolean valutazionePortafoglio;
    @AuraEnabled public WoDebitore[] debitori;
    @AuraEnabled public WoDebitore[] valutazioniPortafoglio;
    @AuraEnabled public WoJoinLineaAttore[] joinLineaAttore;
    @AuraEnabled public WoJoinGaranziaGarante[] joinGaranziaGarante;
    @AuraEnabled public WoParametro[] configurazioneLinee;
    @AuraEnabled public WoIcarManuale[] configurazioneIcarManuali;
    @AuraEnabled public WoParametro[] parametriAggiuntivi;
    @AuraEnabled public User userInfo;
    
    @AuraEnabled public Boolean factfisc;
    //SM - Banca Corporate - aggiungo un nodo del payload per gestire in maniera differente i prodotti di bc
    @AuraEnabled public WoProdotto[] pbc;
    //SM - Corporate Estero 
    @AuraEnabled public WoProdotto[] pbce;
    //A.M. - Flag per gestione prodotti Bonus Edilizi
    @AuraEnabled public Boolean BonusEdil;   
  }

  public class WoJoinGaranziaGarante {
    @AuraEnabled public String garante;
    @AuraEnabled public String garanzia;
    @AuraEnabled public Decimal percentualeGaranzia;
  }

  // è la linea
  public class WoProdotto {
    @AuraEnabled public String id;
    @AuraEnabled public String tipo;
    @AuraEnabled public Decimal importo;
    @AuraEnabled public Decimal durata;
    @AuraEnabled public Decimal quotaProsoluto;
    @AuraEnabled public Decimal durataMaxCredito;
    @AuraEnabled public Decimal durataDilazione;
    @AuraEnabled public Boolean anatocismo; // addebito interessi conto
    @AuraEnabled public Decimal giorniFree;
    @AuraEnabled public String finalitaMutuo;
    @AuraEnabled public String mercato;
    @AuraEnabled public String divisa;
    @AuraEnabled public Boolean lineaAtd;
    @AuraEnabled public Boolean lineaProsoluto;
    @AuraEnabled public String icar;
    @AuraEnabled public String icarAutomaticiATD;
    @AuraEnabled public String atdSingola;
    @AuraEnabled public Boolean icarManuali;

    @AuraEnabled public String codice;
    @AuraEnabled public String icona;
    @AuraEnabled public String nome;
    @AuraEnabled public Boolean associazioneDebitori;

    @AuraEnabled public Boolean isRevisione;
    @AuraEnabled public String docsOperCede;
    // @AuraEnabled public Boolean estero;
    // @AuraEnabled public Boolean contropartePrivato;
    @AuraEnabled public Integer ggDilazione;
    @AuraEnabled public Boolean valutazionePortafoglio;
    @AuraEnabled public String codiceUnivoco;

    // MB - TEN: AGGIUNTI CAMPI PER GESTIONE INFO MUTUI POLIZZE CPI
    @AuraEnabled public Boolean polizzaCPI;
    @AuraEnabled public Boolean fundingBEI;
    @AuraEnabled public Decimal importoOperazione;
    @AuraEnabled public Decimal numeroAssicurati;
    @AuraEnabled public Decimal percAssicurazioneSingoli;
    @AuraEnabled public Decimal importoPolizza;
    @AuraEnabled public Decimal importoPolizzaSuRata;

    @AuraEnabled public Boolean hasCrediti;

    //SM - TEN: AGGIUNTI CAMPI PER GESTIONE BANCA CORPORATE
    @AuraEnabled public String tipologiaConto;
    @AuraEnabled public String utilizzoCC;
    @AuraEnabled public String CCSelezionato;
    @AuraEnabled public Boolean fido;

    //SM - TEN: AGGIUNTI CAMPI PER GESTIONE CORPORATE ESTERO
    //Sono compresi anche i campi utilizzoCC && CCSelezionato come per Banca Corporate
    @AuraEnabled public Decimal durataGG;
    @AuraEnabled public String finalitaExport;
    @AuraEnabled public String listaDocumenti;
    @AuraEnabled public String tipologiaImpExp;
    @AuraEnabled public String affidamento;
    @AuraEnabled public String tipoGaranzia;

    //SM - TEN: CR 212 Gestione Pre-ammortamento
    @AuraEnabled public Boolean preAmmortamento;
    @AuraEnabled public Decimal durataPreAmmortamento;
    @AuraEnabled public Decimal durataAmmortamento;

  }

  public class WoDebitore {
    @AuraEnabled public String id;
    @AuraEnabled public String account;
    @AuraEnabled public String piva;
    @AuraEnabled public String tipo;
    @AuraEnabled public String rsociale;
    @AuraEnabled public Decimal dmc;
    @AuraEnabled public Decimal dcp; // di cui prosoluto
    @AuraEnabled public Decimal durataNominale;
    @AuraEnabled public Decimal fatturato;
    @AuraEnabled public Decimal plafond;
    @AuraEnabled public Boolean prosoluto;
    @AuraEnabled public String divisa;
    @AuraEnabled public Boolean aNotifica;
    @AuraEnabled public Boolean maturity;
    @AuraEnabled public String qualita;
    @AuraEnabled public String mercato;
    @AuraEnabled public String servizio;

    //Opzioni acquisto
    @AuraEnabled public Boolean cessioneContinuativa;
    @AuraEnabled public Boolean notificaLIR;
    @AuraEnabled public String momento;
    @AuraEnabled public Boolean rotativita;
    @AuraEnabled public String anticipazione; // Si, No , ''
    @AuraEnabled public String prosolutoATD; // Prosoluto, Prosolvendo, ''

    @AuraEnabled public Boolean proceduraSemplificata;
    @AuraEnabled public Boolean operazioneIAS;
    @AuraEnabled public Boolean previstaLIR;
    @AuraEnabled public Boolean estero;
    @AuraEnabled public Boolean contropartePrivato;
    
    @AuraEnabled public Boolean isFactFisc;
  }

  public class WoJoinLineaAttore {
    @AuraEnabled public String[] servizi;
    @AuraEnabled public String[] linee;
    @AuraEnabled public String debitore;
    //SM-CART-REVI
    @AuraEnabled public String codTipoCar;
  }

  public class WoAdeguataVerifica {
    @AuraEnabled public Id opportunityId;
    @AuraEnabled public Id[] referenti;
    @AuraEnabled public String[] ruoloReferenti;
    @AuraEnabled public String[] tipologiaTitEffReferenti;
    @AuraEnabled public WoAv[] advL;
    @AuraEnabled public WoIndirizzo indirizzo;
    @AuraEnabled public Account account;
  }

  public class WoAv {
    @AuraEnabled public String categoria;
    @AuraEnabled public String[] adv;
    @AuraEnabled public String[] origineFondi;
    @AuraEnabled public String naturaScopoContinuativo;
    @AuraEnabled public Boolean origineFondiObbligatoria;
    @AuraEnabled public String origineFondiAltro;
  }

  public class WoIndirizzo {
    @AuraEnabled public String tipo;
    @AuraEnabled public String streetType;
    @AuraEnabled public String streetNumber;
    @AuraEnabled public String streetName;
    @AuraEnabled public String city;
    @AuraEnabled public String cap;
    @AuraEnabled public String state;
    @AuraEnabled public String country;
  }

  public class  WoParametro {
    @AuraEnabled public String id;
    @AuraEnabled public String codice;
    @AuraEnabled public String valore;
    @AuraEnabled public String defaultval;
    @AuraEnabled public String tipo;

    @AuraEnabled public String linea;
    @AuraEnabled public String attore;

    @AuraEnabled public String valorePEF38;
    @AuraEnabled public String valorePrgPEF38;

    @AuraEnabled public Boolean isFixedValue;
  }

  public class  WoConfigurazioneParametro {

    @AuraEnabled public String id;
    @AuraEnabled public String nome;
    @AuraEnabled public String codice;
    @AuraEnabled public String tipologia;
    @AuraEnabled public String linea;
    @AuraEnabled public String tipo;
    @AuraEnabled public Boolean readonly;
    @AuraEnabled public Boolean obbligatorio;

    @AuraEnabled public String regolaConvalida;
    @AuraEnabled public String messaggioConvalida;

    @AuraEnabled public String sezione;
    @AuraEnabled public String sottosezione;
    @AuraEnabled public Decimal ordine;
    @AuraEnabled public String dominioVal;
    @AuraEnabled public String dominioFormula;
    @AuraEnabled public String defaultval;
    @AuraEnabled public String defaultFormula;

    @AuraEnabled public Boolean derogaFidoDiCoppia;
    @AuraEnabled public String formulaControllo;
    @AuraEnabled public Boolean soloDeroga;

    @AuraEnabled public Integer precisioneDecimali;
    @AuraEnabled public Decimal limiteKNET;
  }

  public class WoIcarManuale {
    @AuraEnabled public String debitore;
    @AuraEnabled public String ragioneSociale;
    @AuraEnabled public String linea;
    @AuraEnabled public IcarManuale[] icarManuali;
  }

  /*** CLASSI DI APPOGGIO ***/

  public class CodiceATD {
    @AuraEnabled public String linea;
    @AuraEnabled public String lineaAcquisto;
    @AuraEnabled public String fidoDiCoppiaATD;
    @AuraEnabled public String tipo;
    @AuraEnabled public Boolean singola;
    @AuraEnabled public Boolean icarAutomatici;

    @AuraEnabled public Boolean proceduraSemplificata;
    @AuraEnabled public Boolean operazioneIAS;
    @AuraEnabled public Boolean previstaLIR;
    @AuraEnabled public String documentiOperativitaCedente;
  }

  public class IcarManuale {
    @AuraEnabled public String id;
    @AuraEnabled public String annoFatturatoDa;
    @AuraEnabled public String annoFatturatoA;
    @AuraEnabled public String numeroFatturaDa;
    @AuraEnabled public String numeroFatturaA;
    @AuraEnabled public Long dataEmissioneDa;
    @AuraEnabled public Long dataEmissioneA;
  }

  /*** METODI DI UTILITY ***/

  public static Boolean hasProdottoInOpp(String prodCode, Id oppId) {
    List<Linea__c> prodotti = [SELECT
      Id
      FROM Linea__c
      WHERE Prodotto__r.CodiceUnivoco__c = :prodCode
      AND Opportunity__c = :oppId
    ];
    return !prodotti.isEmpty();
  }

  /*** METODI REMOTE ACTION ***/

  @RemoteAction
  public static Boolean setWizardCompletato (String oppId, Boolean wizardCompleto) {
    Opportunity opp = new Opportunity(Id = oppId);
    opp.WizardCompletato__c = wizardCompleto;

    update opp;

    return true;
  }

  @RemoteAction
  public static String[] getDiviseDisponibili () {
    String divise = Impostazioni__c.getInstance().DiviseDisponibili__c;
    return String.isBlank(divise) ? new String[]{} : divise.split(';');
  }

  @RemoteAction
  public static String[] getParamPropagabili () {
    String param = Impostazioni__c.getInstance().ParamPropagWiz__c;
    return String.isBlank(param) ? new String[]{} : param.split(';');
  }

  @RemoteAction
  public static WSRestRibesUtils.EventiNegativiPlain getInformazioniPopupDebitore (String accountId) {
    WSRestRibesUtils.EventiNegativiPlain res = WSRestRibesUtils.getEventiNegativiSintetico(accountId);
    return res;
  }

  @RemoteAction
  public static Id getInformazioniPopupDebitorePDF (String accountId) {
    Id id = WSRestRibesUtils.getEventiNegativiAnalitico(accountId);
    return id;
  }

  /**
   * Aggiorna i consensi privacy di Account ed Esecutore.
   * Se è la prima volta che vengono inseriti o se sono modificati, imposta "ConsensiPrivacyModificati__c" a true
   * Se è specificato anche l'id dell'opportunità o della cessione, popola i campi
   * "ConsensiPrivacyCompilatiAzienda__c" e "ConsensiPrivacyCompilatiEsecutore__c" dell'opportunità stessa o associata
   * @param  obj     Account o Contact
   * @param  oppCess id dell'opportunità o cessione
   * @return         true, se tutto andato a buon fine
   */
  @RemoteAction
  public static Boolean updatePrivacy (SObject obj, String oppCess) {
    String oName = obj.Id.getSobjectType().getDescribe().getName();
    String oppCessName = String.isNotBlank(oppCess) ? ((Id) oppCess).getSobjectType().getDescribe().getName() : null;
    SObject objToUpdate = Schema.getGlobalDescribe().get(oName).newSObject();
    Boolean objModified = false;
    Opportunity opp;

    String[] privacyFields = new String[]{
      'ConsensoAllaProfilazione__c',
      'ConsensoAttivitaPromRicercheMercato__c',
      'ConsensoAttivitaPromozionaleTerzi__c',
      'ConsensoProdottiBancaRicercheMercato__c',
      'ConsensoProdottiSocietaTerze__c',
      'ConsensoSoloModalitaTradizionali__c'
    };

    SObject objOld = (SObject) Database.query(QueryBuilder.newInstance(oName, privacyFields, new String[]{'Id', 'DataInserimentoConsensi__c'}).withId(obj.Id).getQuery());

    if (String.isNotBlank(oppCess))
      opp = (Opportunity) Database.query(
        QueryBuilder.newInstance('Opportunity', new String[] {
          'Id',
          'ConsensiPrivacyCompilatiAzienda__c',
          'ConsensiPrivacyCompilatiEsecutore__c',
          'Cessione__r.ConsensiPrivacyDaMostrareAzienda__c',
          'Cessione__r.ConsensiPrivacyDaMostrareEsecutore__c'
        })
        .beginFilter()
          .add('Id', QBOp.QEQUAL, oppCess, oppCessName == 'Opportunity')
          .add('Cessione__c', QBOp.QEQUAL, oppCess, oppCessName == 'Cessione__c')
        .endFilter()
        .getQuery()
      );

    try {
      for (String pField : privacyFields) {
        objToUpdate.put(pField, obj.get(pField));
        if (objOld.get(pField) != obj.get(pField)) objModified = true;
      }
      objToUpdate.Id = obj.Id;
      objToUpdate.put('DataInserimentoConsensi__c', Datetime.now());
      objToUpdate.put('PresaVisionePrivacy__c', true);
      if (objModified || objOld.get('DataInserimentoConsensi__c') == null) objToUpdate.put('ConsensiPrivacyModificati__c', true);
      update objToUpdate;

      SObject newObj = Database.query('SELECT ConsensiPrivacyDaCaricare__c FROM ' + oName + ' WHERE Id = \'' + objToUpdate.get('Id') + '\'');

      if ( opp != null && oName == 'Account') {
        UWS.updateObjs(new Opportunity[]{ new Opportunity(Id = opp.Id, ConsensiPrivacyCompilatiAzienda__c = true)}, true);
        if (oppCessName == 'Cessione__c') update new Cessione__c(Id = oppCess, ConsensiPrivacyDaMostrareAzienda__c = (Boolean) newObj.get('ConsensiPrivacyDaCaricare__c'));
      }
      if ( opp != null && oName == 'Contact') {
        UWS.updateObjs(new Opportunity[]{ new Opportunity(Id = opp.Id, ConsensiPrivacyCompilatiEsecutore__c = true)}, true);
        if (oppCessName == 'Cessione__c') update new Cessione__c(Id = oppCess, ConsensiPrivacyDaMostrareEsecutore__c = (Boolean) newObj.get('ConsensiPrivacyDaCaricare__c'));
      }

      return true;
    } catch(DmlException e) {
      throw new Ex.WSException(e.getDmlMessage(0), e);
    }
  }

  @RemoteAction
  public static Opportunity fetchPrivacyCompilata(String idCessione) {
    return [SELECT Id, ConsensiPrivacyCompilatiAzienda__c, ConsensiPrivacyCompilatiEsecutore__c FROM Opportunity WHERE Cessione__c = :idCessione];
  }

  @RemoteAction
  public static Id fetchAttorePrivacy(String objType, Id oppId) {
    if (objType == 'Account') return [SELECT AccountId FROM Opportunity WHERE Id = :oppId].AccountId;
    if (objType == 'Contact') {
      NDGLinea__c[] esecutori = [SELECT Contact__c FROM NDGLinea__c WHERE Tipo__c = 'Esecutore adeguata verifica' AND Opportunita__c = :oppId];
      return (esecutori.isEmpty()) ? null : esecutori[0].Contact__c;
    }
    return null;
  }

  @RemoteAction
  public static Boolean updateNoteIstruttoria(Opportunity opp) {
    try {
      update opp;
      return true;
    } catch(DmlException e) {
      throw new Ex.WSException(e.getDmlMessage(0), e);
    }
  }

  @RemoteAction
  public static List<NDGLinea__c> editFatca(Id opportunityId) {
    return [SELECT
      Id,
      Contact__c,
      Trust__c,
      ValoriTrust__c,
      TipoTrust__c,
      ReferenteFatca__c,
      ResidenzaFiscale1__c,
      ResidenzaFiscale2__c,
      ResidenzaFiscale3__c,
      ResidenzaFiscale4__c,
      CodiceFiscaleResidenzaFiscale1__c,
      CodiceFiscaleResidenzaFiscale2__c,
      CodiceFiscaleResidenzaFiscale3__c,
      CodiceFiscaleResidenzaFiscale4__c
      FROM NDGLinea__c
      WHERE Opportunita__c = :opportunityId
      AND ReferenteFatca__c = true
    ];
  }

  @RemoteAction
  public static List<Map<String,Object>> getRiepilogoInfoCr(Id opportunityId) {
    List<Map<String,Object>> result = new List<Map<String, Object>>();
    NDGLinea__c[] attori = [SELECT Id,
                            Account__r.Name,
                            Contact__r.Name,
                            DataRichiestaCR__c,
                            Tipo__c
                            FROM NDGLinea__c
                            WHERE Opportunita__c = :opportunityId
                            AND Tipo__c = 'Debitore'];
    Opportunity opp = [SELECT AccountId,
                       Account.Name,
                       Account.NaturaGiuridica__c,
                       Account.CF__c,
                       Account.NDGGruppo__c,
                       Account.CodiceIstituto3N__c,
                       DataRichiestaCR__c
                       FROM Opportunity
                       WHERE Id = :opportunityId];
    String dataRichiestaCRopp = opp.DataRichiestaCR__c != null ? ((Datetime) opp.DataRichiestaCR__c).format('dd/MM/YYYY') : null;

    if (opp.Account.NaturaGiuridica__c == 'DI' && String.isNotBlank(opp.Account.CF__c)) {
      Contact[] c = [
        SELECT Id,
        Name
        FROM Contact
        WHERE CF__c = :opp.Account.CF__c
        AND NDGGruppo__c != :opp.Account.NDGGruppo__c
        AND CodiceIstituto3N__c = :opp.Account.CodiceIstituto3N__c
      ];
      if (c.size() != 0) {
        result.add(new Map<String, Object> {
          'icona' => 'standard-contact',
          'id' => c[0].Id,
          'nome' => c[0].Name,
          'dataRichiestaCR' => dataRichiestaCRopp,
          'tipo' => 'Referente'
        });
      }
    }

    result.add(new Map<String, Object> {
      'icona' => 'standard-account',
      'id' => opp.AccountId,
      'nome' => opp.Account.Name,
      'dataRichiestaCR' => dataRichiestaCRopp,
      'tipo' => 'Cedente'
    });

    if (attori.size() == 0) return result;

    for (NDGLinea__c attore : attori) {
      String icona;
      String nome;
      String dataRichiestaCR = attore.DataRichiestaCR__c != null ? ((Datetime) attore.DataRichiestaCR__c).format('dd/MM/YYYY') : null;
      if (String.isBlank(attore.Account__r.Name)) {
        icona = 'standard-contact';
        nome = attore.Contact__r.Name;
      } else {
        icona = 'standard-account';
        nome = attore.Account__r.Name;
      }
      result.add(new Map<String, Object> {
        'icona' => icona,
        'id' => attore.Id,
        'nome' => nome,
        'dataRichiestaCR' => dataRichiestaCR,
        'tipo' => attore.Tipo__c
      });
    }
    return result;
  }

  @RemoteAction
  public static List<Map<String,Object>> getRiepilogoOpportunita(Id opportunityId) {
    Map<String, SObject> linee = U.keyBy([SELECT Id,
      Importo__c,
      Prodotto__r.Icona__c,
      Prodotto__r.Name,
      Prodotto__r.CodiceUnivoco__c,
      DivisaNew__c,
      LineaProsoluto__c,
      NumeroDebitori__c,
      toLabel(Stato__c),
      (SELECT
        Valore__c
        FROM PConfigurati__r
        WHERE Codice__c = 'SF6'
        AND Valore__c != NULL
      )
      FROM Linea__c
      WHERE Opportunity__c = :opportunityId
    ], 'Id');

    Map<String, SObject> valPortafoglioMap = U.keyBy([SELECT Linea__c
    FROM JoinLineaDebitore__c
    WHERE Linea__c IN :linee.keySet()
    AND Debitore__r.Tipo__c = 'Valutazione portafoglio'
    ], 'Linea__c');

    List<Map<String,Object>> ret = new List<Map<String, Object>>();

    Boolean fido = false;
    for(SObject s : linee.values()) {
      Linea__c l = (Linea__c) s;
      if(l.Prodotto__r.CodiceUnivoco__c == K.CODPROD_FIDO) fido = true;
    }

    for(SObject s : linee.values()) {
      Linea__c l = (Linea__c) s;
      if(l.Prodotto__r.CodiceUnivoco__c == K.CODPROD_IFIS_IMPRESA && fido) continue;

      String tipoDebitori = 'N/A';
      if(l.NumeroDebitori__c > 0) tipoDebitori = String.valueOf(l.NumeroDebitori__c);
      if(valPortafoglioMap.containsKey(l.Id)) tipoDebitori = 'Valutazione portafoglio';

      ret.add(new Map<String, Object>{
        'id' => l.Id,
        'icona' => l.Prodotto__r.Icona__c,
        'tipoLinea' => l.Prodotto__r.Name,
        'importo' => (l.PConfigurati__r.isEmpty() ? (Object) l.Importo__c : (Object) l.PConfigurati__r[0].Valore__c),
        'divisa' => l.DivisaNew__c,
        'ricon' => 'N/A',
        'prosoluto' => l.LineaProsoluto__c,
        'deb' => (Object) tipoDebitori,
        'statoLinea' => l.Stato__c
      });

    }

    return ret;
  }

  @RemoteAction
  public static Boolean updateFatca(String fatcaString) {
    Map<String, Object> fatca = (Map<String, Object>) JSON.deserializeUntyped(fatcaString);
    Map<String, Object> infoAzienda = (Map<String, Object>)fatca.get('infoAzienda');
    Account azienda = new Account(Id = (String)infoAzienda.get('Id'));
    List<Object> referenti = (List<Object>)fatca.get('referenti');
    System.SavePoint sp = Database.setSavePoint();
    try {
      azienda.RegimeTrasparenzaFiscale__c = (String) infoAzienda.get('RegimeTrasparenzaFiscale__c');
      azienda.USPerson__c = (String) infoAzienda.get('USPerson__c');
      azienda.SpecifiedUSPerson__c = (String) infoAzienda.get('SpecifiedUSPerson__c');
      azienda.FiscalmenteResidenteSoloStatiUniti__c = (String) infoAzienda.get('FiscalmenteResidenteSoloStatiUniti__c');
      azienda.IstituzioneFinanziaria__c = (String) infoAzienda.get('IstituzioneFinanziaria__c');
      azienda.ValoriFiscalmenteResidenteSoloUSA__c = (String) infoAzienda.get('ValoriFiscalmenteResidenteSoloUSA__c');
      azienda.ValoriActiveNFFEActiveNFE__c = (String) infoAzienda.get('ValoriActiveNFFEActiveNFE__c');
      azienda.AltroFiscalmenteResidenteSoloUSA__c = (String) infoAzienda.get('AltroFiscalmenteResidenteSoloUSA__c');
      azienda.ResidenzaFiscale1__c = (String) infoAzienda.get('ResidenzaFiscale1__c');
      azienda.ResidenzaFiscale2__c = (String) infoAzienda.get('ResidenzaFiscale2__c');
      azienda.ResidenzaFiscale3__c = (String) infoAzienda.get('ResidenzaFiscale3__c');
      azienda.ResidenzaFiscale4__c = (String) infoAzienda.get('ResidenzaFiscale4__c');
      azienda.CodiceFiscaleResidenzaFiscale1__c = (String) infoAzienda.get('CodiceFiscaleResidenzaFiscale1__c');
      azienda.CodiceFiscaleResidenzaFiscale2__c = (String) infoAzienda.get('CodiceFiscaleResidenzaFiscale2__c');
      azienda.CodiceFiscaleResidenzaFiscale3__c = (String) infoAzienda.get('CodiceFiscaleResidenzaFiscale3__c');
      azienda.CodiceFiscaleResidenzaFiscale4__c = (String) infoAzienda.get('CodiceFiscaleResidenzaFiscale4__c');
      azienda.CostituzioneStreetName__c = (String) infoAzienda.get('CostituzioneStreetName__c');
      azienda.CostituzioneStreetType__c = (String) infoAzienda.get('CostituzioneStreetType__c');
      azienda.CostituzioneStreetNumber__c = (String) infoAzienda.get('CostituzioneStreetNumber__c');
      azienda.CostituzioneCity__c = (String) infoAzienda.get('CostituzioneCity__c');
      azienda.CostituzionePostalCode__c = (String) infoAzienda.get('CostituzionePostalCode__c');
      azienda.CostituzioneState__c = (String) infoAzienda.get('CostituzioneState__c');
      azienda.CostituzioneCountry__c = (String) infoAzienda.get('CostituzioneCountry__c');
      update azienda;


      NDGLinea__c[] ndgLinee = new NDGLinea__c[]{};
      Contact[] contatti = new Contact[]{};
      delete [SELECT Id FROM NDGLinea__c WHERE Opportunita__c = :(String)fatca.get('opportunityId') AND ReferenteFatca__c = true];
      Map<String, Object> referente;
      for(Integer i = 0; i < referenti.size(); i++) {
        referente = (Map<String, Object>) referenti.get(i);
        if((Boolean) referente.get('ReferenteFatca__c') == true) {
          ndgLinee.add(new NDGLinea__c(
            Contact__c = (String) referente.get('Id'),
            Opportunita__c = (String) fatca.get('opportunityId'),
            RecordTypeId = U.getRecordTypes('NDGLinea__c').get('Referente').Id,
            //Tipo__c = 'Titolare effettivo adeguata verifica'
            Trust__c = (String) referente.get('Trust__c'),
            ValoriTrust__c = (String) referente.get('ValoriTrust__c'),
            TipoTrust__c = (String) referente.get('TipoTrust__c'),
            ReferenteFatca__c = (Boolean) referente.get('ReferenteFatca__c'),
            ResidenzaFiscale1__c = (String) referente.get('ResidenzaFiscale1__c'),
            ResidenzaFiscale2__c = (String) referente.get('ResidenzaFiscale2__c'),
            ResidenzaFiscale3__c = (String) referente.get('ResidenzaFiscale3__c'),
            ResidenzaFiscale4__c = (String) referente.get('ResidenzaFiscale4__c'),
            CodiceFiscaleResidenzaFiscale1__c = (String) referente.get('CodiceFiscaleResidenzaFiscale1__c'),
            CodiceFiscaleResidenzaFiscale2__c = (String) referente.get('CodiceFiscaleResidenzaFiscale2__c'),
            CodiceFiscaleResidenzaFiscale3__c = (String) referente.get('CodiceFiscaleResidenzaFiscale3__c'),
            CodiceFiscaleResidenzaFiscale4__c = (String) referente.get('CodiceFiscaleResidenzaFiscale4__c')
          ));
          contatti.add(new Contact(
            Id = (String) referente.get('Id'),
            FirstName = (String) referente.get('FirstName'),
            LastName = (String) referente.get('LastName'),
            CF__c = (String) referente.get('CF__c'),
            LuogoNascita__c = (String) referente.get('LuogoNascita__c'),
            MailingStreetType__c = (String) referente.get('MailingStreetType__c'),
            MailingStreetNumber__c = (String) referente.get('MailingStreetNumber__c'),
            MailingStreetName__c = (String) referente.get('MailingStreetName__c'),
            MailingCity = (String) referente.get('MailingCity'),
            MailingState = (String) referente.get('MailingState'),
            MailingCountry = (String) referente.get('MailingCountry'),
            MailingPostalCode = (String) referente.get('MailingPostalCode'),
            Sesso__c = (String) referente.get('Sesso__c'),
            CodCatastaleLocNascita__c = (String) referente.get('CodCatastaleLocNascita__c'),
            Birthdate = Date.valueOf(DateTime.newInstance((Long) referente.get('Birthdate')))
          ));
        }
      }
      upsert ndgLinee;
      upsert contatti;
      update new Opportunity(
        Id = (String) fatca.get('opportunityId'),
        DataCompilazioneFatca__c = Datetime.now()
      );
    }catch(DmlException e) {
      Database.rollback(sp);
      throw new Ex.WSException(e.getDmlMessage(0), e);
    }
    return true;
  }

  @RemoteAction
  public static WoAdeguataVerifica editAdeguataVerifica(Id opportunityId) {
    WoAdeguataVerifica wav = new WoAdeguataVerifica();
    wav.referenti = new String[]{};
    wav.ruoloReferenti = new String[]{};
    wav.tipologiaTitEffReferenti = new String[]{};

    NDGLinea__c[] ndgL = [SELECT
      Id,
      Contact__c,
      Contact__r.PEP__c,
      Tipo__c,
      TipologiaTitolareEffettivo__c
      FROM NDGLinea__c
      WHERE Opportunita__c = :opportunityId
      AND Tipo__c IN ('Titolare effettivo adeguata verifica', 'Esecutore adeguata verifica')
    ];
    Boolean origineFondiObbligatoria = U.getSet(ndgL, 'Contact__r.PEP__c').contains('true');

    Map<String, NDGLinea__c[]> ndgMap = U.groupBy(ndgL, 'Contact__c');
    for(String cId : ndgMap.keySet()) {
      wav.referenti.add(cId);
      if(ndgMap.get(cId).size() > 1) {
        wav.ruoloReferenti.add('Titolare effettivo ed esecutore');
        for (NDGLinea__c attore : ndgMap.get(cId)) {
          if (attore.Tipo__c == 'Titolare effettivo adeguata verifica') {
            wav.tipologiaTitEffReferenti.add(attore.TipologiaTitolareEffettivo__c);
            break;
          }
        }
      } else if(ndgMap.get(cId)[0].Tipo__c == 'Titolare effettivo adeguata verifica') {
        wav.ruoloReferenti.add('Titolare effettivo');
        wav.tipologiaTitEffReferenti.add(ndgMap.get(cId)[0].TipologiaTitolareEffettivo__c);
      } else if(ndgMap.get(cId)[0].Tipo__c == 'Esecutore adeguata verifica') {
        wav.ruoloReferenti.add('Esecutore');
        wav.tipologiaTitEffReferenti.add('');
      }
    }

    AdeguataVerifica__c[] av = [SELECT
      ScopoFD11__c,
      ScopoFD12__c,
      ScopoFD13__c,
      ScopoFD14__c,
      ScopoFD15__c,
      ScopoFD16__c,
      ScopoFD17__c,
      ScopoFD18__c,
      ScopoFD19__c,
      NaturaRapportoContinuativoFD__c,
      TipoIndirizzo__c,
      CorrispondenzaStreetName__c,
      CorrispondenzaStreetNumber__c,
      CorrispondenzaStreetType__c,
      CorrispondenzaCountry__c,
      CorrispondenzaState__c,
      CorrispondenzaCity__c,
      CorrispondenzaCAP__c,
      OrigineFondi1__c,
      OrigineFondi2__c,
      OrigineFondi3__c,
      OrigineFondi4__c,
      OrigineFondiAltro__c
      FROM AdeguataVerifica__c WHERE Opportunita__c = :opportunityId
    ];

    if(av.isEmpty()) return wav;

    wav.advL = new WoAv[]{};
    WoAv flags = new WoAv();
    flags.categoria = 'FactDir';
    flags.naturaScopoContinuativo = av[0].NaturaRapportoContinuativoFD__c;
    flags.origineFondiObbligatoria = origineFondiObbligatoria;
    flags.origineFondiAltro = av[0].OrigineFondiAltro__c;
    flags.adv = new String[]{};
    for(Integer i = 11; i <= 19; i++) {
      if(av[0].get('ScopoFD' + i + '__c') == true) {
        flags.adv.add(String.valueOf(i));
      }
    }
    flags.origineFondi = new String[]{};
    for(Integer i = 1; i <= 4; i++) {
      if(av[0].get('OrigineFondi' + i + '__c') == true) {
        flags.origineFondi.add(String.valueOf(i));
      }
    }

    WoIndirizzo indir = new WoIndirizzo();
    indir.tipo = av[0].TipoIndirizzo__c;
    indir.streetType = av[0].CorrispondenzaStreetType__c;
    indir.streetName = av[0].CorrispondenzaStreetName__c;
    indir.streetNumber = av[0].CorrispondenzaStreetNumber__c;
    indir.city = av[0].CorrispondenzaCity__c;
    indir.state = av[0].CorrispondenzaState__c;
    indir.cap = av[0].CorrispondenzaCAP__c;
    indir.country = av[0].CorrispondenzaCountry__c;

    wav.indirizzo = indir;


    wav.advL.add(flags);
    return wav;
  }

  @RemoteAction
  public static Account getAccountData(String accountId) {
    return [SELECT
      Id,
      Name,
      Phone,
      Fax,
      Email__c,
      EmailPEC__c,
      EmailPECFatturaElettronica__c,
      CodiceDestinatario__c,
      BillingStreet,
      BillingStreetName__c,
      BillingStreetNumber__c,
      BillingStreetType__c,
      BillingCity,
      BillingState,
      BillingCountry,
      BillingPostalCode,
      ShippingStreet,
      ShippingStreetName__c,
      ShippingStreetType__c,
      ShippingStreetNumber__c,
      ShippingCity,
      ShippingState,
      ShippingCountry,
      ShippingPostalCode,
      RegimeTrasparenzaFiscale__c,
      USPerson__c,
      SpecifiedUSPerson__c,
      FiscalmenteResidenteSoloStatiUniti__c,
      IstituzioneFinanziaria__c,
      ValoriFiscalmenteResidenteSoloUSA__c,
      ValoriActiveNFFEActiveNFE__c,
      AltroFiscalmenteResidenteSoloUSA__c,
      ResidenzaFiscale1__c,
      ResidenzaFiscale2__c,
      ResidenzaFiscale3__c,
      ResidenzaFiscale4__c,
      CodiceFiscaleResidenzaFiscale1__c,
      CodiceFiscaleResidenzaFiscale2__c,
      CodiceFiscaleResidenzaFiscale3__c,
      CodiceFiscaleResidenzaFiscale4__c,
      CostituzioneStreetName__c,
      CostituzioneStreetType__c,
      CostituzioneStreetNumber__c,
      CostituzioneCity__c,
      CostituzionePostalCode__c,
      CostituzioneState__c,
      CostituzioneCountry__c,
      PartecipazioneSocietaFiduciarie2__c
      FROM Account
      WHERE Id = :accountId
    ];
  }

  @RemoteAction
  public static Boolean updateAdeguataVerifica(String avString) {
    WoAdeguataVerifica av = (WoAdeguataVerifica) JSON.deserialize(avString, WoAdeguataVerifica.class);
    System.SavePoint sp = Database.setSavePoint();

    try {
      if(av.advL != null) {
        //AdeguataVerifica__c adver = new AdeguataVerifica__c(Opportunita__c = av.opportunityId, Account__c = av.account.Id);
		//adione-CRM20 - ADV ora legata ad Account direttamente
		AdeguataVerifica__c adver = new AdeguataVerifica__c(Account__c = av.account.Id);
		adver.WGC_Data_Compilazione__c = Date.today();
          
        for(WoAv adv : av.advL) {
          String prefix = '';
          if(adv.categoria == 'FactDir') prefix = 'FD';
          else if(adv.categoria == 'FactInd') prefix = 'FI';
          else if(adv.categoria == 'SBancari') prefix = 'PB';

          for(Integer i = 11; i <= 19; i++) {
            adver.put('Scopo' + prefix + i + '__c', false);
          }

          for(String i : adv.adv) {
            adver.put('Scopo' + prefix + i + '__c', true);
          }

          for(Integer i = 1; i <= 4; i++) {
            adver.put('OrigineFondi' + i + '__c', false);
          }

          for(String i : adv.origineFondi) {
            adver.put('OrigineFondi' + i + '__c', true);
          }

          adver.put('NaturaRapportoContinuativo' + prefix + '__c', adv.naturaScopoContinuativo);
          adver.put('OrigineFondiAltro__c', adv.origineFondiAltro);
        }

        if(av.indirizzo != null) {
          WoIndirizzo indirizzo = av.indirizzo;
          adver.TipoIndirizzo__c = indirizzo.tipo;
          adver.CorrispondenzaStreetName__c = indirizzo.streetName;
          adver.CorrispondenzaStreetType__c = indirizzo.streetType;
          adver.CorrispondenzaStreetNumber__c = indirizzo.streetNumber;
          adver.CorrispondenzaCountry__c = indirizzo.country;
          adver.CorrispondenzaState__c = indirizzo.state;
          adver.CorrispondenzaCity__c = indirizzo.city;
          adver.CorrispondenzaCAP__c = indirizzo.cap;
        }

        delete [SELECT Id FROM AdeguataVerifica__c WHERE Opportunita__c = :av.opportunityId];
        insert adver;
      }

      if(av.referenti != null) {
        NDGLinea__c[] ndgLinee = new NDGLinea__c[]{};
        delete [SELECT Id FROM NDGLinea__c WHERE Opportunita__c = :av.opportunityId AND Tipo__c IN ('Titolare effettivo adeguata verifica', 'Esecutore adeguata verifica')];

        for(Integer i = 0; i < av.referenti.size(); i++) {
          String cId = av.referenti[i];
          if(av.ruoloReferenti[i] == 'Titolare effettivo' || av.ruoloReferenti[i] == 'Titolare effettivo ed esecutore') {
            ndgLinee.add(new NDGLinea__c(
              Contact__c = cId,
              Opportunita__c = av.opportunityId,
              RecordTypeId = U.getRecordTypes('NDGLinea__c').get('Referente').Id,
              Tipo__c = 'Titolare effettivo adeguata verifica',
              TipologiaTitolareEffettivo__c = av.tipologiaTitEffReferenti[i]
            ));
          }
          if(av.ruoloReferenti[i] == 'Esecutore' || av.ruoloReferenti[i] == 'Titolare effettivo ed esecutore') {
            ndgLinee.add(new NDGLinea__c(
              Contact__c = cId,
              Opportunita__c = av.opportunityId,
              RecordTypeId = U.getRecordTypes('NDGLinea__c').get('Referente').Id,
              Tipo__c = 'Esecutore adeguata verifica',
              TipologiaTitolareEffettivo__c = null
            ));
          }
        }

        upsert ndgLinee;
      }

      if(av.account != null) {
        Account com = av.account;
        Account accountColl = new Account(Id = com.Id);
        accountColl.EmailPEC__c = com.EmailPEC__c;
        accountColl.Phone = com.Phone;
        accountColl.Fax = com.Fax;
        accountColl.Email__c = com.Email__c;
        accountColl.EmailPECFatturaElettronica__c = com.EmailPECFatturaElettronica__c;
        accountColl.CodiceDestinatario__c = com.CodiceDestinatario__c;
        accountColl.PartecipazioneSocietaFiduciarie2__c = com.PartecipazioneSocietaFiduciarie2__c;
        update accountColl;
      }

      return true;
    } catch(DmlException e) {
      Database.rollback(sp);
      throw new Ex.WSException(e.getDmlMessage(0), e);
    }
  }

  @RemoteAction
  public static WoPayload saveCategorie(String payload) {
    WoPayload p = (WoPayload) JSON.deserialize(payload, WoPayload.class);
    Map<String, SObject> rtMap = U.getRecordTypes('Linea__c');
    List<String> selectedProds = new List<String>();
      
    //A.M. Gestione Mutuo Veneto Sviluppo  
    Set<String> productCodesNotPBPFI = U.getSet([SELECT Codice__c FROM Prodotto__c WHERE NOT(CodiceUnivoco__c LIKE 'Mutuo%' OR CodiceUnivoco__c LIKE 'IfisImpresa%' OR CodiceUnivoco__c LIKE 'VenetoSviluppo%')], 'Codice__c');
    Opportunity opp = [SELECT Id, WGC_Prodotti_Selezionati__c, WGC_Prodotti_bloccati__c, AccountId FROM Opportunity WHERE Id = :p.opportunityId];
    if (opp.WGC_Prodotti_Selezionati__c != null && opp.WGC_Prodotti_Selezionati__c != '')
      selectedProds.addAll(opp.WGC_Prodotti_Selezionati__c.split(','));
    if (opp.WGC_Prodotti_bloccati__c != null && opp.WGC_Prodotti_bloccati__c != '')
      selectedProds.addAll(opp.WGC_Prodotti_bloccati__c.split(','));

    Map<String, SObject> prodottiMap = U.keyBy([SELECT
      CodiceUnivoco__c
      FROM Prodotto__c
      WHERE CategoriaProdotto__c != 'Factoring diretto'
    ], 'CodiceUnivoco__c');

    Map<String, SObject> existingLinesMap = U.keyBy([SELECT
      Id, Prodotto__c
      FROM Linea__c
      WHERE Opportunity__c = :p.opportunityId
    ], 'Id');

    System.SavePoint sp = Database.setSavePoint();
    try {
      Linea__c[] linee = new Linea__c[]{};

      // factoring indiretto
      for(WoProdotto wp : p.pfi) {
        if(wp.importo == null) wp.importo = 0;

        Linea__c l = new Linea__c(
          Prodotto__c = prodottiMap.containsKey(wp.tipo) ? prodottiMap.get(wp.tipo).Id : null,
          Importo__c = wp.importo,
          Durata__c = wp.durata,
          QuotaProsoluto__c = wp.quotaProsoluto,
          DurataMaxCredito__c = wp.durataMaxCredito,
          DurataDilazione__c = wp.durataDilazione,
          GiorniFree__c = wp.giorniFree,
          RecordTypeId = rtMap.get('FactInd').Id,
          Opportunity__c = p.opportunityId
        );

        if(!String.isBlank(wp.id)) l.Id = wp.id;
        linee.add(l);
      }

      System.debug('@@@@ Linee 1: ' + linee);  
      // prodotti bancari
      Boolean anatocismoLinea = false;
      Id idFido;
      // salvo l'id di un eventuale fido presente
      for(WoProdotto wp : p.pb) {
        if (wp.tipo == K.CODPROD_FIDO) idFido = wp.id;
      }
      for(WoProdotto wp : p.pb) {
        // salto il fido (verrà generato tramite l'ifis impresa)
        if (wp.tipo == K.CODPROD_FIDO) continue;
          
        //SM - TEN: Fix bug gestione C/C
        if(wp.importo == null || (!wp.fido && wp.tipo.startsWith('IfisImpresa'))) wp.importo = 0;
 
        //SM - TEN: Fix bug gestione C/C
        wp.tipo = (wp.importo == 0 && !wp.tipo.contains('NonAffidato') ? wp.tipo+'NonAffidato' : (wp.importo != 0 && wp.tipo.contains('NonAffidato') ? wp.tipo.replace('NonAffidato','') : wp.tipo));

        Linea__c l = new Linea__c(
          Importo__c = wp.importo,
          Prodotto__c = prodottiMap.get(wp.tipo).Id,//OLD --> //prodottiMap.get(wp.tipo + (wp.importo == 0 && !wp.tipo.contains('NonAffidato') ? 'NonAffidato' : (wp.importo != 0 && wp.tipo.contains('NonAffidato') ? wp.tipo.replace('NonAffidato','') : ''))).Id, 
          Durata__c = wp.durata,
          Anatocismo__c = true,/*wp.anatocismo == true,*/ //SM - TEN: Da richiesta Banca Corporate Anatocismo sempre a true
          FinalitaMutuo__c = wp.finalitaMutuo,
          // MB - TEN: AGGIUNTI CAMPI PER GESTIONE INFO MUTUI POLIZZE CPI
          WGC_Polizza_CPI__c = (wp.polizzaCPI != null ? wp.polizzaCPI : false),
          WGC_Funding_BEI__c = (wp.fundingBEI != null ? wp.fundingBEI : false),
          WGC_Importo_Operazione__c = wp.importoOperazione,
          WGC_Numero_Assicurati__c = wp.numeroAssicurati,
          WGC_assicurazione_singoli__c = wp.percAssicurazioneSingoli,
          WGC_Importo_Polizza__c = wp.importoPolizza,
          WGC_Imp_Polizza_su_rata_quota_capitale__c = wp.importoPolizzaSuRata,
          WGC_Fido__c = (wp.fido == null ? false : wp.fido),
          //SM - TEN: CR 212 Gestione pre-ammortamento
          WGC_Pre_ammortamento__c = wp.preAmmortamento,
          WGC_Durata_pre_ammortamento__c = wp.durataPreAmmortamento,
          WGC_Durata_Ammortamento__c = wp.durataAmmortamento,
          RecordTypeId = rtMap.get('Fido').Id,
          Opportunity__c = p.opportunityId
        );

        // MB - TEN: Aggiunta gestione "C/C Imprese non Residente Euro"
        if(l.Importo__c != null && l.Importo__c > 0 && (wp.tipo == K.CODPROD_IFIS_IMPRESA || wp.tipo == K.CODPROD_IFIS_IMPRESA_NON_RESIDENTE)) {
        // if(l.Importo__c != null && l.Importo__c > 0 && wp.tipo == K.CODPROD_IFIS_IMPRESA) {
          // creo una linea aggiuntiva, fido di cassa (oltre all'ifis impresa)
          Linea__c fido = new Linea__c(
            Importo__c = wp.importo,
            Prodotto__c = prodottiMap.get('Fido').Id,
            Durata__c = wp.durata,
            Anatocismo__c = true,/*wp.anatocismo == true,*/ //SM - TEN: Da richiesta Banca Corporate Anatocismo sempre a true
            FinalitaMutuo__c = wp.finalitaMutuo,
            RecordTypeId = rtMap.get('Fido').Id,
            Opportunity__c = p.opportunityId
          );
          if(!String.isBlank(idFido)) fido.Id = idFido;
          linee.add(fido);
        }

        // ifis impresa deve essere a 0 + setto anatocismo globale da mettere su account
        if(wp.tipo == K.CODPROD_IFIS_IMPRESA) {
          l.Importo__c = 0;
          anatocismoLinea = wp.anatocismo == true;
        }
        System.debug('@@@@ wp.id: ' + wp.id);
        System.debug('@@@@ wp.codice: ' + wp.codice);  
        if(!String.isBlank(wp.id)) l.Id = wp.id;
        linee.add(l);
      }
      Set<Id> idLineeEsistenti = U.getIdSet(linee, 'Id');
      System.debug('@@@@ linee: ' + linee);
      System.debug('@@@@ idLineeEsistenti: ' + idLineeEsistenti);  
System.debug('@@@@ deletedLines: ' + [SELECT Id FROM Linea__c WHERE Opportunity__c = :p.opportunityId AND RecordTypeId IN (:rtMap.get('Fido').Id, :rtMap.get('FactInd').Id) AND Id NOT IN :idLineeEsistenti AND Prodotto__r.WGC_Famiglia__c NOT IN :productCodesNotPBPFI]);

      // MB - TEN: Se cambio di prodotto su linea esistente, cancello parametri configurati
      List<Id> parameterLinesToRemove = new List<Id>();
      for (Linea__c l : linee)
        if (existingLinesMap.get(l.Id) != null)
          if (((Linea__c) existingLinesMap.get(l.Id)).Prodotto__c != l.Prodotto__c)
            parameterLinesToRemove.add(l.Id);

      //Vado in upsert sulle linee sopravvissute, ed elimino quelle eliminate
      delete [SELECT Id FROM Linea__c WHERE Opportunity__c = :p.opportunityId AND RecordTypeId IN (:rtMap.get('Fido').Id, :rtMap.get('FactInd').Id) AND Id NOT IN :idLineeEsistenti AND Prodotto__r.WGC_Famiglia__c NOT IN :productCodesNotPBPFI];
      upsert linee;
      update new Opportunity(Id = p.opportunityId, HasFactoringDiretto__c = p.fd, HasConfirming__c = p.confirming);

      if (parameterLinesToRemove.size() > 0)
        delete [SELECT Id FROM PConfigurato__c WHERE Linea__c IN :parameterLinesToRemove];

      // pulizie nel caso non ci sia factoring diretto e/o confirming
      if(!p.fd || !p.confirming) {
        Set<Id> rtToDelete = new Set<Id>();
        if (!p.fd) rtToDelete.add(rtMap.get('FactDir').Id);
        if (!p.confirming) rtToDelete.add(rtMap.get('Confirming').Id);

        // elminazione della linea
        delete [
          SELECT Id
          FROM Linea__c
          WHERE RecordTypeId IN :rtToDelete
          AND Opportunity__c = :p.opportunityId
        ];

        // eliminazione delle garanzie specifiche (non omnibus)
        delete [
          SELECT Id
          FROM Garanzia__c
          WHERE Linea__c = null // ovvero non più associate a linee perchè cancellate con la DML precedente
          AND Tipo__c = 'Specifica'
          AND Opportunita__c = :p.opportunityId
        ];

        String debitoriToDeleteQuery = QueryBuilder.newInstance('NDGLinea__c', new String[]{'Id'})
          .beginFilter()
          .add('Opportunita__c', QBOp.QEQUAL, p.opportunityId)
          .add('Tipo__c', QBOp.QIN, new Set<String>{'Debitore', 'Valutazione Portafoglio'})
          .beginCrossFilter('JoinLineaDebitore__c', 'Debitore__c')
              .add('Opportunita__c', QBOp.QEQUAL, p.opportunityId)
              .add('Linea__r.RecordTypeId', QBOp.QEQUAL, rtMap.get('Confirming').Id)
          .endCrossFilter(false, p.fd && !p.confirming, true) // se ci sono factoring diretti ma non ci sono confirming cancello solo la Valutazione Portafoglio relativa al "Confirming"
          .beginCrossFilter('JoinLineaDebitore__c', 'Debitore__c')
              .add('Opportunita__c', QBOp.QEQUAL, p.opportunityId)
              .add('Linea__r.RecordTypeId', QBOp.QEQUAL, rtMap.get('Confirming').Id)
          .endCrossFilter(false, !p.fd && p.confirming, false) // se c'è confirming ma non ci sono factoring diretto cancello mantengo la Valutazione Portafoglio relativa al "Confirming"
          .endFilter()
          .getQuery();
        delete (NDGLinea__c[]) Database.query(debitoriToDeleteQuery);

        // cancellazione degli NDGLinea debitori
        // eliminazione dei garanti che non hanno più un join
        delete [
          SELECT Id
          FROM NDGLinea__c
          WHERE Tipo__c IN ('Garante')
          AND Id NOT IN (
            SELECT Garante__c
            FROM JoinGaranteGaranzia__c
            WHERE Garanzia__r.Opportunita__c = :p.opportunityId
            )
          AND Opportunita__c = :p.opportunityId
        ];
      }

      // salvataggio del flag "addebito interessi conto" sull'account
      // Opportunity opp = [SELECT AccountId FROM Opportunity WHERE Id = :p.opportunityId];
      Account a = new Account();
      a.Id = opp.AccountId;
      a.AddebitoInteressiConto__c = anatocismoLinea;
      update a;

      // WizardOpportunityController.saveCorporateLines(p);

      return editRsf(p.opportunityId);
    } catch(DmlException e) {
      Database.rollback(sp);
      System.debug('@@@ error ' + e.getMessage() + ' -- ' + e.getLineNumber());
      throw new Ex.WSException(e.getDmlMessage(0), e);
    }
  }

  @RemoteAction
  public static WoPayload saveDebitori(String payload) {
    WoPayload p = (WoPayload) JSON.deserialize(payload, WoPayload.class);

    System.SavePoint sp = Database.setSavePoint();
    try {
      saveValutazionePortafoglio(p);
      saveDebitoriInternal(p);
      fixIcarManuali(p);
      return editRsf(p.opportunityId);
    } catch(DmlException e) {
      Database.rollback(sp);
      throw new Ex.WSException(e.getDmlMessage(0), e);
    }
  }

  /**
   * Analizza il payload contenente la configurazione dei debitori, e va a cancellare le associazioni a linee ATDCS e
   * gli Icar Manuali per coloro che non soddisfano più le condizioni necessarie.
   * @param  payload informazioni relative ai debitori
   */
  public static void fixIcarManuali(WoPayload payload) {

    // if (payload.tiAnticipo) return; // TODO TIANTICIPO: decommentare la linea nel caso in cui si vorrà permettere ai
    // commerciali di modificare gli icar

    // TODO ICAR: creare un metodo centralizzato per prendere gli id delle linee interessate agli icar manuali
    Map<String, JoinLineaDebitore__c[]> joinsToIcarMap = U.groupBy([SELECT
      Id,
      Debitore__r.FakeId__c
      FROM JoinLineaDebitore__c
      WHERE Opportunita__c = :payload.opportunityId
      AND Linea__r.Prodotto__r.CodiceUnivoco__c = 'ATDTiAnticipo'
      ], 'Debitore__r.FakeId__c');

    Map<String, IcarManuale__c[]> icarsMap = U.groupBy([SELECT
      Id,
      Debitore__r.FakeId__c
      FROM IcarManuale__c
      WHERE Debitore__r.Opportunita__c = :payload.opportunityId
      ], 'Debitore__r.FakeId__c');

    JoinLineaDebitore__c[] joinsToDelete = new JoinLineaDebitore__c[]{};
    IcarManuale__c[] icarsToDelete = new IcarManuale__c[]{};

    WoDebitore[] allDebitori = new WoDebitore[]{};
    allDebitori.addAll(payload.debitori);
    allDebitori.addAll(payload.valutazioniPortafoglio);

    for(WoDebitore j : allDebitori) {
    // TODO ICAR: creare un metodo centralizzato per prendere i debitori e vedere se possono essere associati all'ATDCS
      Boolean atdRuleIcarM = !(j.divisa == '242' && j.aNotifica && !j.maturity && j.mercato == '001' && j.dcp == j.plafond);
      if (atdRuleIcarM) {
        if (joinsToIcarMap.containsKey(j.id)) joinsToDelete.addAll(joinsToIcarMap.get(j.id));
        if (icarsMap.containsKey(j.id) ) icarsToDelete.addAll(icarsMap.get(j.id));
      }
    }

    delete joinsToDelete;
    delete icarsToDelete;
  }

  public static void saveValutazionePortafoglio (WoPayload p) {
    update new Opportunity(Id = p.opportunityId, ValutazionePortafoglio__c = p.valutazionePortafoglio);
  }

  /**
   * Aggiorna i debitori sul DB
   * @param  p payload proveniente da wizard, contenente le info necessarie
   * @return
   */
  public static WoPayload saveDebitoriInternal(WoPayload p) {
    NDGLinea__c[] ndgLinee = new NDGLinea__c[]{};

    WoDebitore[] allDebitori = new WoDebitore[]{};
    allDebitori.addAll(p.debitori);
    allDebitori.addAll(p.valutazioniPortafoglio);
    System.debug('@@@@ allDebitori: ' + allDebitori);
    for(WoDebitore db : allDebitori) {
      NDGLinea__c ndgLinea = new NDGLinea__c(
        Account__c = (String.isNotBlank(db.piva)) ? db.piva : null,
        Tipo__c = (String.isNotBlank(db.tipo)) ? db.tipo : 'Debitore',
        DurataMediaCredito__c = db.dmc,
        DurataNominale__c = db.durataNominale,
        Fatturato__c = db.fatturato,
        DiCuiProsoluto__c = db.dcp,
        Opportunita__c = p.opportunityId,
        Plafond__c = db.plafond,
        // ANotifica__c = (db.aNotifica != null) ? db.aNotifica : false,
        // MB - TEN: flag notifica valorizzato a true se primo inserimento debitore
        ANotifica__c = (db.aNotifica != null) ? db.aNotifica : true,
        Maturity__c = (db.maturity != null) ? db.maturity : false,
        PlafondDeliberato__c = 0,
        DivisaNew__c = (String.isNotBlank(db.divisa)) ? db.divisa : null,
        Anticipazione__c = (String.isNotBlank(db.anticipazione)) ? db.anticipazione : null,
        CessioneContinuativa__c = (db.cessioneContinuativa != null) ? db.cessioneContinuativa : false,
        PerfezionamentoAcquisto__c = (String.isNotBlank(db.momento)) ? db.momento : null,
        NotificaLIRSingoleCessioni__c = (db.notificaLIR != null) ? db.notificaLIR : false,
        Rotativita__c = (db.rotativita != null) ? db.rotativita : false,
        ProsolutoATD__c = (String.isNotBlank(db.prosolutoATD)) ? db.prosolutoATD : null,
        Servizio__c = db.servizio,
        // MB - TEN: nuovi parametri per gestione ATD 2.0
        WGC_Procedura_Semplificata__c = (db.proceduraSemplificata != null) ? db.proceduraSemplificata : false,
        WGC_Operazione_IAS__c = (db.operazioneIAS != null) ? db.operazioneIAS : false,
        WGC_E_prevista_LIR__c = (db.previstaLIR != null) ? db.previstaLIR : false,
        RecordTypeId = U.getRecordTypes('NDGLinea__c').get('Debitore').Id,
        FakeId__c = db.id
      );
      ndgLinee.add(ndgLinea);
    }

    Set<String> ndgLineeEsistenti = U.getSet(ndgLinee, 'FakeId__c');
    delete [SELECT Id FROM Linea__c
      WHERE Opportunity__c = :p.opportunityId
      AND (RecordTypeId = :U.getRecordTypes('Linea__c').get('FactDir').Id
        OR RecordTypeId = :U.getRecordTypes('Linea__c').get('Confirming').Id
      )
      AND Id NOT IN (SELECT Linea__c FROM JoinLineaDebitore__c WHERE Debitore__r.FakeId__c IN :ndgLineeEsistenti)
      AND Id NOT IN (SELECT Linea__c FROM JoinLineaDebitore__c WHERE WGC_Codice_Random_Coppia__c != null)
    ];
    delete [SELECT Id FROM NDGLinea__c WHERE Opportunita__c = :p.opportunityId AND Tipo__c IN ('Debitore', 'Valutazione portafoglio') AND FakeId__c NOT IN :ndgLineeEsistenti];
    Database.upsert(ndgLinee, NDGLinea__c.FakeId__c);

    return p;
  }

  /**
   * Ritorna i servizi disponibili
   * Per le opportunità non "TiAnticipo" non viene visualizzato l'ATDTiAnticipo
   * @param  oppTiAnticipo true, se l'opportunità proviene da TiAnticipo, false altrimenti
   * @return               lista dei servizi disponibili
   */
  @RemoteAction
  public static MatriceServizio__mdt[] getServizi(Boolean confirming, Boolean factoringDiretto, Boolean oppTiAnticipo) {
    return (MatriceServizio__mdt[]) Database.query(
      QueryBuilder.newInstance('MatriceServizio__mdt', new String[]{'Id', 'DeveloperName', 'Label', 'Icona__c', 'Ordinamento__c', 'Acquisto__c', 'Tipo__c', 'ValutazionePortafoglioOnly__c'})
      .beginFilter()
        .beginOr()
          .add('Tipo__c', QBOp.QEQUAL, 'TiAnticipo', oppTiAnticipo)
          .add('Tipo__c', QBOp.QEQUAL, 'Factoring', factoringDiretto)
          .add('Tipo__c', QBOp.QEQUAL, 'Confirming', confirming)
        .end()
      .endFilter()
      .orderBy(new String[]{'Ordinamento__c'})
      .getQuery());
  }

  @RemoteAction
  public static MatriceSezioni__mdt[] getSezioni() {
    return [SELECT Id, Label, NomeSezione__c, Ordine__c  FROM MatriceSezioni__mdt ORDER BY Ordine__c ASC];
  }

  /**
   * Metodo che ritorna una mappa di fakeIdDebitore --> configurazione linea atd da creare, associata a lui
   * @param  p             payload proveniente da wizard
   * @param  haIfisImpresa
   * @return
   */
  public static Map<String, CodiceATD[]> getCodiciProdottoAtd(WoPayload p, Boolean haIfisImpresa) {
    Set<String> debitoriDaConsiderare = new Set<String>();
    Set<String> debitoriATDCS = new Set<String>();
    Set<String> debitoriATDConfirming = new Set<String>();
    Set<String> debitoriInRevisione = U.getSet([SELECT Debitore__r.FakeId__c FROM JoinLineaDebitore__c WHERE Linea__r.Opportunity__c = :p.opportunityId AND WGC_Codice_Random_Coppia__c != null AND Linea__r.LineaATD__c = true], 'Debitore__r.FakeId__c');
    //SM-CART-REVI
    // Map<Id,Linea__c> lineeRevi = new Map<Id,Linea__c>([SELECT Id FROM Linea__c WHERE WGC_Numero_Linea_Credito__c != null AND LineaATD__c = true AND Opportunity__c =: p.opportunityId]);
    for(WoJoinLineaAttore j : p.joinLineaAttore) {
      if (U.toSet(j.servizi).contains('Acquisto a titolo definitivo') && !debitoriInRevisione.contains(j.debitore)){
        debitoriDaConsiderare.add(j.debitore);
      }
      if (U.toSet(j.servizi).contains('ATD - TiAnticipo')) {
        debitoriATDCS.add(j.debitore);
      }
      if (U.toSet(j.servizi).contains('ATD con proroga Confirming')) {
        debitoriATDConfirming.add(j.debitore);
      }
    }

    Map<String, SObject[]> mATD = new Map<String, SObject[]>();

    // Map<String, SObject> allMatrix = U.keyBy([SELECT
    //   Label,
    //   CaricoMassivo__c,
    //   CessioneContinuativa__c,
    //   ConAnticipazione__c,
    //   DebitoreConProroga__c,
    //   FidoDiCoppiaATD__c,
    //   ICARAutomatici__c,
    //   IFISImpresa__c,
    //   LineaDiAcquisto__c,
    //   LineaDiCarico__c,
    //   LineaSingola__c,
    //   PerfezionamentoAcquisto__c,
    //   PossibilitaNotifica__c,
    //   ProsolvendoProsoluto__c,
    //   OperazioniRotative__c,
    //   Alert__c
    //   FROM MatriceATD__mdt
    // ], '{ConAnticipazione__c}_{CessioneContinuativa__c}_{PerfezionamentoAcquisto__c}_{PossibilitaNotifica__c}_{DebitoreConProroga__c}_{IFISImpresa__c}_{ProsolvendoProsoluto__c}_{OperazioniRotative__c}_{CaricoMassivo__c}', true, true);
    
    // MB - TEN: ATD 2.0
    List<WGC_Matrice_ATD__mdt> matriceATD = [SELECT
        Id,
        Anticipazione__c,
        FidoDiCoppiaATD__c,
        ICARAutomatici__c,
        LineaDiAcquisto__c,
        LineaDiCarico__c,
        LineaSingola__c,
        Maturity__c,
        Notifica__c,
        Operativit_IAS__c,
        Parametro_13__c,
        PerfezionamentoAcquisto__c,
        PrevistaLIR__c,
        ProceduraSemplificata__c,
        ProsolutoLineaCarico__c,
        ValutazionePortafoglio__c
        FROM WGC_Matrice_ATD__mdt];
      List<String> mATDfields = new List<String>{'Notifica__c','Maturity__c','ValutazionePortafoglio__c','ProceduraSemplificata__c','Operativit_IAS__c','PrevistaLIR__c','PerfezionamentoAcquisto__c','Anticipazione__c','ProsolutoLineaCarico__c'};

    WoDebitore[] allDebitori = new WoDebitore[]{};
    allDebitori.addAll(p.debitori);
    if(p.valutazioniPortafoglio != null) allDebitori.addAll(p.valutazioniPortafoglio);
    for(WoDebitore debitore : allDebitori) {
      if(debitoriDaConsiderare.contains(debitore.id)) {
        Map<String, String> debFields = new Map<String, String>();

        // ATTENZIONE: L'ORDINE DEI VALORI E' FONDAMENTALE PER SCALARE I LIVELLI DI VALORIZZAZIONE DEI PARAMETRI
        debFields.put('Notifica__c', debitore.aNotifica ? 'SI' : 'NO'); // LV.0
        debFields.put('Maturity__c', debitore.maturity ? 'SI' : 'NO'); // LV.0
        debFields.put('ValutazionePortafoglio__c', debitore.tipo == 'Valutazione Portafoglio' ? 'SI' : 'NO'); // LV.0
        debFields.put('ProceduraSemplificata__c', debitore.proceduraSemplificata ? 'SI' : 'NO'); // LV.1
        debFields.put('Operativit_IAS__c', debitore.operazioneIAS ? 'SI' : 'NO'); // LV.2
        debFields.put('PrevistaLIR__c', debitore.previstaLIR ? 'SI' : 'NO'); // LV.2
        debFields.put('PerfezionamentoAcquisto__c', String.isBlank(debitore.momento) ? '' : debitore.momento); // LV.2
        debFields.put('Anticipazione__c', String.isBlank(debitore.anticipazione) ? '' : (debitore.anticipazione == 'Si' ? 'SI' : 'NO')); // LV.3
        debFields.put('ProsolutoLineaCarico__c', String.isBlank(debitore.prosolutoATD) ? '' : debitore.prosolutoATD); // LV.3

        // String atdAnticipazione = String.isBlank(debitore.anticipazione) ? '' : (debitore.anticipazione == 'Si' ? 'SI' : 'NO');
        // String atdCessioneContinuativa = debitore.cessioneContinuativa ? 'SI' : 'NO';
        // String atdMomentoAcquisto = String.isBlank(debitore.momento) ? '' : debitore.momento;
        // String atdNotifica = debitore.aNotifica ? 'SI' : 'NO';
        // String atdMaturity = debitore.maturity ? 'SI' : 'NO';
        // String prosoluto = String.isBlank(debitore.prosolutoATD) ? '' : (debitore.prosolutoATD == 'Prosoluto' ? 'SI' : 'NO');
        // String ifisImpresa = haIfisImpresa ? 'SI' : 'NO';
        // String rotativita = debitore.rotativita ? 'SI' : 'NO';
        // String caricoMassivo = debitore.tipo == 'Valutazione Portafoglio' ? 'SI' : 'NO';
        // String valutazionePortafoglio = debitore.tipo == 'Valutazione Portafoglio' ? 'SI' : 'NO';
        // String proceduraSemplificata = debitore.proceduraSemplificata ? 'SI' : 'NO';
        // String operazioneIAS = debitore.operazioneIAS ? 'SI' : 'NO';
        // String previstaLIR = debitore.previstaLIR ? 'SI' : 'NO';
        // String key = atdAnticipazione + '_' + atdCessioneContinuativa + '_' + atdMomentoAcquisto + '_' + atdNotifica + '_' + atdMaturity + '_' + ifisImpresa + '_' + prosoluto + '_' + rotativita + '_' + caricoMassivo;
        // if(!allMatrix.containsKey(key)) throw new Ex.WSException(ERROR_CONFIGURAZIONE + ' Dettaglio debitore: ' + debitore.rsociale + '; Dettaglio linea: ' + key + ';');
        // if(allMatrix.get(key).get('Alert__c') == 'NV') throw new Ex.WSException(ERROR_CONFIGURAZIONE_NV + ' Dettaglio debitore: ' + debitore.rsociale);
        // if(allMatrix.get(key).get('Alert__c') == 'NC') throw new Ex.WSException(ERROR_CONFIGURAZIONE_NC + ' Dettaglio debitore: ' + debitore.rsociale);
        List<SObject> valori = mATD.containsKey(debitore.id) ? mATD.get(debitore.id) : new List<SObject>();
        System.debug('@@@@ debFields: ' + debFields);
        SObject newValore = getATDConfiguration(matriceATD, debFields);
        System.debug('@@@@ newValore: ' + JSON.serialize(newValore));
        if (newValore == null)
          throw new Ex.WSException(ERROR_CONFIGURAZIONE + ' Dettaglio debitore: ' + debitore.rsociale + '; Dettaglio linea: ' + debitore + ';');
        else
          valori.add(newValore);

        // valori.add(allMatrix.get(key));
        mATD.put(debitore.id, valori);
      }
    }

    // aggiungo le linee ATD in base alla matriceATD
    Map<String, CodiceATD[]> codiciATD = new Map<String, CodiceATD[]>();
    for(String deb : mATD.keySet()) {
      SObject[] righeATD = mATD.get(deb);
      List<CodiceATD> valori = codiciATD.containsKey(deb) ? codiciATD.get(deb) : new List<CodiceATD>();
      for(SObject rigaATD : righeATD) {

        if(rigaATD.get('LineaDiAcquisto__c') != null) {
          CodiceATD atdLDA = new CodiceATD();
          atdLDA.lineaAcquisto = null;
          atdLDA.linea =  (String) rigaATD.get('LineaDiAcquisto__c');
          atdLDA.fidoDiCoppiaATD = (String) rigaATD.get('FidoDiCoppiaATD__c');
          atdLDA.singola = rigaATD.get('LineaSingola__c') == 'SI';
          atdLDA.tipo = 'lineaDiAcquisto';
          atdLDA.icarAutomatici = rigaATD.get('ICARAutomatici__c') == 'SI';
          atdLDA.proceduraSemplificata = rigaATD.get('ProceduraSemplificata__c') == 'SI';
          atdLDA.operazioneIAS = rigaATD.get('Operativit_IAS__c') == 'SI';
          atdLDA.previstaLIR = rigaATD.get('PrevistaLIR__c') == 'SI';
          atdLDA.documentiOperativitaCedente = (String) rigaATD.get('Parametro_13__c');
          valori.add(atdLDA);
        }

        if(rigaATD.get('LineaDiCarico__c') != null) {
          CodiceATD atdLDC = new CodiceATD();
          atdLDC.linea = (String) rigaATD.get('LineaDiCarico__c');
          atdLDC.lineaAcquisto =  (String) rigaATD.get('LineaDiAcquisto__c');
          atdLDC.fidoDiCoppiaATD = (String) rigaATD.get('FidoDiCoppiaATD__c');
          atdLDC.singola = rigaATD.get('LineaSingola__c') == 'SI';
          atdLDC.tipo = 'lineaDiCarico';
          atdLDC.icarAutomatici = rigaATD.get('ICARAutomatici__c') == 'SI';
          atdLDC.proceduraSemplificata = rigaATD.get('ProceduraSemplificata__c') == 'SI';
          atdLDC.operazioneIAS = rigaATD.get('Operativit_IAS__c') == 'SI';
          atdLDC.previstaLIR = rigaATD.get('PrevistaLIR__c') == 'SI';
          valori.add(atdLDC);
        }

        codiciATD.put(deb, valori);
      }
    }

    // ora aggiungo le linee PCTAN
    for (String deb : debitoriATDCS) {
      List<CodiceATD> valori = codiciATD.containsKey(deb) ? codiciATD.get(deb) : new List<CodiceATD>();

      // linea di acquisto ATD
      CodiceATD atdLDA = new CodiceATD();
      atdLDA.lineaAcquisto = null;
      atdLDA.linea = '745';
      atdLDA.fidoDiCoppiaATD = 'ICAR manuale';
      atdLDA.singola = true;
      atdLDA.tipo = 'lineaDiAcquisto';
      atdLDA.icarAutomatici = false;
      valori.add(atdLDA);

      codiciATD.put(deb, valori);
    }

    // ora aggiungo le linee ATD con proroga Confirming
    for (String deb : debitoriATDConfirming) {
      List<CodiceATD> valori = codiciATD.containsKey(deb) ? codiciATD.get(deb) : new List<CodiceATD>();

      // linea di acquisto ATD
      CodiceATD atdConf = new CodiceATD();
      atdConf.lineaAcquisto = null;
      atdConf.linea = '750';
      atdConf.fidoDiCoppiaATD = 'ICAR automatici';
      atdConf.singola = false;
      atdConf.tipo = 'lineaDiAcquisto';
      atdConf.icarAutomatici = false;
      valori.add(atdConf);

      codiciATD.put(deb, valori);
    }

    return codiciATD;
  }

  public static SObject getATDConfiguration(List<WGC_Matrice_ATD__mdt> mADT, Map<String, String> debFields) {
      SObject result;
      List<WGC_Matrice_ATD__mdt> mADTfiltered = mADT;
      for (String apiName : debFields.keySet()) {
          mADTfiltered = U.filter(mADTfiltered, apiName, debFields.get(apiName));
          if (mADTfiltered.size() == 1) {
              result = mADTfiltered[0];
              break;
          } else if (mADTfiltered.size() == 0) {
            break;
          }
      }
      return result;
  }

  @RemoteAction
  public static WoPayload saveServizi(String payload) {
    WoPayload p = (WoPayload) JSON.deserialize(payload, WoPayload.class);
    return saveJoinLineeAttore(p);
  }

  public static WoPayload saveJoinLineeAttore(WoPayload payload) {
    Id rtFactoringDiretto = U.getRecordTypes('Linea__c').get('FactDir').Id;
    Id rtConfirming = U.getRecordTypes('Linea__c').get('Confirming').Id;
    Set<Id> rTypes = new Set<Id>{rtFactoringDiretto, rtConfirming};
    System.debug('@@@@ rtFactoringDiretto: ' + rtFactoringDiretto);
    // SALVO VALORI OPZIONI ATD (stanno sui debitori) + ritorno nuovo WoPayload che ha azzerato id js
    WoPayload p = saveDebitoriInternal(payload);
    // MB - TEN: AGGIUNTO PARAMETRO "WGC_Mercato__c" PER SOVRASCRITTURA MERCATO LINEA SE CAMPO VALORIZZATO
    // recupero NDGLinea per l'opportunità corrente
    Map<String, SObject> debitoriMap = U.keyBy([SELECT
      FakeId__c,
      ANotifica__c,
      Maturity__c,
      DivisaNew__c,
      Mercato__c,
      WGC_Mercato__c,
      Prosoluto__c,
      ProsolutoATD__c,
      Rotativita__c,
      Anticipazione__c,
      Tipo__c,
      IsAutoAdd__c
      FROM NDGLinea__c
      WHERE Opportunita__c = :p.opportunityId
      AND Tipo__c IN ('Debitore', 'Valutazione portafoglio')
    ], 'FakeId__c');


    Boolean haIfisImpresa = hasProdottoInOpp(K.CODPROD_IFIS_IMPRESA, p.opportunityId);
    Map<String, CodiceATD[]> codiciProdottoATDStruct = getCodiciProdottoAtd(p, haIfisImpresa);

    // allCodici conterrà l'elenco dei codici delle linee che dovremo creare, in base alle configurazioni matchate in matriceATD e quelle per ATDCS
    Set<String> allCodici = new Set<String>();
    for(CodiceATD[] cATD : codiciProdottoATDStruct.values()) {
      for(CodiceATD c : cATD) {
        allCodici.add(c.linea);
      }
    }

    Set<String> revisionedProds = U.getSet([SELECT Id, Prodotto__r.Codice__c FROM Linea__c WHERE Opportunity__c = :p.opportunityId AND WGC_Numero_Linea_Credito__c != null], 'Prodotto__r.Codice__c');
    Set<String> revisionedDebs = U.getSet([SELECT Debitore__r.FakeId__c FROM JoinLineaDebitore__c WHERE Linea__r.Opportunity__c =:p.opportunityId AND WGC_Codice_Random_Coppia__c != null], 'Debitore__r.FakeId__c');
    // MB - TEN: AGGIUNTO CAMPO "WGC_Famiglia__c"
    QueryBuilder.FilterBuilder qb = QueryBuilder.newInstance('Prodotto__c', new String[]{'Id', 'Servizio__c', 'Notifica__c', 'Maturity__c', 'Codice__c', 'WGC_Famiglia__c'})
      .beginFilter()
        .beginOr();

          for(WoJoinLineaAttore j : p.joinLineaAttore) {
            for(String servizio : j.servizi) {
              // per ATDCS e ATD la query sarà la stessa
              String s = (servizio == 'ATD - TiAnticipo' || servizio == 'ATD con proroga Confirming') ? 'Acquisto a titolo definitivo' : servizio;
              //A.M. Gestione Factoring MCC e ACF MCC
              //16/11/2020 Gestione nuovi prodotti per area Bonus Edilizi
              if (s == 'Factoring' || s == 'Anticipo Crediti futuri' || s == 'Factoring MCC' || s == 'Anticipo Crediti Futuri MCC' || s == 'ATD - Superbonus' || s == 'ATD - Altri Bonus' || s == 'ACF NOT NOT - Bonus Edilizi' || s == 'ACF Not Not MCC - Bonus Edilizi') {
                qb.beginAnd()
                  .add('Servizio__c', QBOp.QEQUAL, s)
                  .add('Notifica__c', QBOp.QEQUAL, debitoriMap.get(j.debitore).get('ANotifica__c'))
                .end();
              }

              if (s == 'Confirming') {
                qb.beginAnd()
                  .add('Servizio__c', QBOp.QEQUAL, s)
                .end();
              }

              // Se è factoring, meglio prendersi su anche i Maturity
              if(s == 'Factoring') {
                qb.add('Servizio__c', QBOp.QEQUAL, 'Maturity');
              }

              // ATD SE NE FREGA DI Servizio__c e Notifica__c
              if(s == 'Acquisto a titolo definitivo') {
                qb.add('Codice__c', QBOp.QIN, allCodici);
                if (revisionedProds.size() > 0)
                  qb.add('Codice__c', QBOp.QIN, revisionedProds);
              }

              // MB - TEN: AGGIUNTO PRODOTTO "SOLA GESTIONE" COME LINEA D'ACQUISTO
              if (s == 'Sola Gestione') {
                qb.add('Codice__c', QBOp.QEQUAL, (debitoriMap.get(j.debitore).get('ANotifica__c') == true ? '561' : '661'));
              }
            }
          }

      // if (revisionedProds.size() > 0)
      //   qb.add('Codice__c', QBOp.QNOT_IN, revisionedProds);

      String query2 = qb
      .end()
      .endFilter()
      .getQuery();

    List<Prodotto__c> prodottiQuery = Database.query(query2);
	    
    // MB - TEN: AGGIUNTA MAPPA PER GESTIONE "Sola Gestione"
    // Ho ora l'elenco dei prodotti che dovrò creare
    Map<String, SObject> prodottiMap = U.keyBy(prodottiQuery, '{Servizio__c}_{Notifica__c}_{Maturity__c}', true);
    Map<String, SObject> prodottiATD = U.keyBy(prodottiQuery, 'Codice__c');
    Map<String, SObject> prodottiSolaGestioneMap = U.keyBy(prodottiQuery, 'Codice__c');
    System.debug('@@@@ prodottiSolaGestioneMap: ' + prodottiSolaGestioneMap);
    System.debug('@@@@ prodottiMap: ' + prodottiMap);  
    // nuove linee (da inserire o aggiornare)
    Map<String, Linea__c> linee = new Map<String, Linea__c>();

    // MB - TEN: AGGIUNTO PARAMETRO "WGC_Mercato__c"
    // vecchie linee da rimuovere
    List<Linea__c> oldLinee = [SELECT
      Id,
      Prodotto__r.Servizio__c,
      Prodotto__r.Notifica__c,
      Prodotto__r.Maturity__c,
      Prodotto__r.Codice__c,
      Mercato__c,
      DivisaNew__c,
      DebitoreAnticipazione__c,
      DebitoreRotativita__c,
      DebitoreTipo__c,
      LineaProsoluto__c,
      ProsolutoATD__c,
      LineaATD__c,
      TipoLinea__c,
      ICAR__c,
      WGC_Numero_Linea_Credito__c,
      LineaATDSingola__c,
      ICARAutomaticiATD__c,
      WGC_DocumentiOperativit_Cedente__c
      FROM Linea__c
      WHERE Opportunity__c = :p.opportunityId
      AND RecordTypeId IN :rTypes
    ];

    // mappe delle vecchie per chiave
    Map<String, SObject> oldLineeMap = U.keyBy(oldLinee, '{Prodotto__r.Servizio__c}_{Prodotto__r.Notifica__c}_{Prodotto__r.Maturity__c}_{Mercato__c}_{DivisaNew__c}_{LineaATD__c}_{WGC_Numero_Linea_Credito__c}', true);
    Map<String, SObject> oldLineeMapATD = U.keyBy(oldLinee, '{Prodotto__r.Codice__c}_{Mercato__c}_{DivisaNew__c}_{DebitoreAnticipazione__c}_{ProsolutoATD__c}_{DebitoreRotativita__c}_{DebitoreTipo__c}_{LineaATD__c}_{WGC_Numero_Linea_Credito__c}', true);
    Map<String, SObject> reviLineeMapATD = U.keyBy(U.filter(oldLinee, 'WGC_Numero_Linea_Credito__c', ((Object) null), false), '{Prodotto__r.Codice__c}_{Mercato__c}_{DivisaNew__c}_{WGC_Numero_Linea_Credito__c}', true);
    Set<String> factFiscLinesCodes = new Set<String>{'464','364','534','644','744','844'};
    List<Linea__c> reviLineeATD = new List<Linea__c>();
    reviLineeATD = [SELECT Id, Prodotto__r.Codice__c, LineaATDSingola__c, TipoLinea__c, WGC_CodiceUnivocoLinea__c, WGC_Numero_Linea_Credito__c, Mercato__c FROM Linea__c WHERE Opportunity__c = :p.opportunityId AND WGC_Numero_Linea_Credito__c != null AND LineaATD__c = true];
    System.debug('@@@@ oldLineeMap: ' + JSON.serialize(oldLineeMap));
    System.debug('@@@@ oldLineeMapATD: ' + JSON.serialize(oldLineeMapATD));
    System.debug('@@@@ reviLineeMapATD: ' + JSON.serialize(reviLineeMapATD));
    // mappa per gestione numero linea revisione per linee di carico ATD
    Map<String, String> reviLineeDiCaricoMap = new Map<String, String>();
    for (String tmpKey : reviLineeMapATD.keySet()) {
      if (((Linea__c) reviLineeMapATD.get(tmpKey)).TipoLinea__c == 'lineaDiCarico')
        reviLineeDiCaricoMap.put(reviLineeMapATD.get(tmpKey).Id, ((Linea__c) reviLineeMapATD.get(tmpKey)).WGC_Numero_Linea_Credito__c);
    }
    System.debug('@@@@ reviLineeDiCaricoMap: ' + JSON.serialize(reviLineeDiCaricoMap));

    for(WoJoinLineaAttore j : p.joinLineaAttore) {
      NDGLinea__c debitore = (NDGLinea__c) debitoriMap.get(j.debitore);

      // codiciATDMap contiene (per il debitore corrente nel ciclo) una mappa "codice linea" -> "informazioni linea da creare"
      Map<String, CodiceATD> codiciATDMap = new Map<String,CodiceATD>();
      if(codiciProdottoATDStruct.containsKey(j.debitore)) {
        for(CodiceATD cod : codiciProdottoATDStruct.get(j.debitore)) {
          codiciATDMap.put(cod.linea, cod);
        }
      }

      for(String s : j.servizi) {
        // nel caso di factoring ordinario si considera il flag maturity, altrimenti non lo si considera nella chiave
        Boolean flagMaturity = s == 'Factoring' ? debitore.Maturity__c : false;
        // i codici sono quelli comprensivi di mercato, per le linee. Per trovare i codici dei prodotti, bisogna escludere Mercato__c dalla chiave
        // la chiave per i prodotti è priva di mercato: mercato è solo su Linea__c
        Boolean isATD = (s == 'Acquisto a titolo definitivo' || s == 'ATD - TiAnticipo' || s == 'ATD con proroga Confirming');
        // MB - TEN: GESTIONE "Sola Gestione"
        Boolean isSolaGestione = s == 'Sola Gestione';
        System.debug('@@@@ debitore: ' + debitore);
        Set<String> chiaviProd = new Set<String>{s + '_' + debitore.ANotifica__c + '_' + flagMaturity};
        if(isATD && j.linee != null && containsAny(j.linee, U.getSet(reviLineeATD, 'Id'))) {
          // chiaviProd = codiciATDMap.keySet();
          Set<String> reviATDCodes = U.getSet(reviLineeATD, 'Prodotto__r.Codice__c');
          reviATDCodes.addAll(codiciATDMap.keySet());
          //SM - FIX TENAM-241
          //Quando è presente una revisione ATD e ATD NOT NOT a linea singola, schiantava perchè eseguiva due volte il giro per lo stesso debitore, creando una linea non necessaria
          //Prendo solo il codice prodotto della linea legata alla join
          Set<String> code = new Set<String>();
          for(Linea__c l : reviLineeATD){
            if(j.linee.contains(l.Id))
              code.add(l.Prodotto__r.Codice__c);
          }
          if(!code.isEmpty())
            chiaviProd = code;
          else
            chiaviProd = reviATDCodes;

          System.debug('@@@ code ' + code);
          System.debug('@@@@ ATD REVI - chiaviProd: ' + chiaviProd);
        } else if (isATD) chiaviProd = codiciATDMap.keySet();
        else chiaviProd = new Set<String>{s + '_' + debitore.ANotifica__c + '_' + flagMaturity};
        // MB - TEN: GESTIONE "Sola Gestione"
        if (isSolaGestione) {
          Set<String> codes = new Set<String>{ debitore.ANotifica__c == true ? '561' : '661' };
          chiaviProd = codes;
        }
          
        //System.debug('###A.M. chiaviProd: ' + chiaviProd);  

        // MB - TEN: AGGIUNTA CONDIZIONE PER UTILIZZARE MAPPA PRODOTTI_CODICE IN CASO DI SERVIZIO "Sola Gestione"
        // Map<String, SObject> prodottiMapFinal = isATD ? prodottiATD : prodottiMap;
        Map<String, SObject> prodottiMapFinal = (isATD ? prodottiATD : (isSolaGestione ? prodottiSolaGestioneMap : prodottiMap));
        Map<String, SObject> oldLineeMapFinal = isATD ? oldLineeMapATD : oldLineeMap;
        //A.M. 
        // for(String PMF : prodottiMapFinal.keyset()) {
        //     System.debug('###A.M. prodottiMapFinal: ' + PMF);
        //  }
        
        // Boolean checkDuplicatoATD = false;
        for(String codProd : chiaviProd) {
          String servizio = codProd.split('_')[0];
          String reviCodLinea = codProd  + '_' + (debitore.WGC_Mercato__c != null ? debitore.WGC_Mercato__c : (debitore.Mercato__c != null ? debitore.Mercato__c : '{Mercato__c}')) + '_' + (debitore.DivisaNew__c != null ? debitore.DivisaNew__c : '{DivisaNew__c}');
          // MB - TEN: AGGIUNTO PARAMETRO "WGC_Mercato__c"
          // TODO ATD DM: in teoria per fare il match sulla mappa bisognerebbe tenere così le stringhe, CHECK!
          // String codLinea = codProd  + '_' + (debitore.Mercato__c != null ? debitore.Mercato__c : '{Mercato__c}') + '_' + (debitore.DivisaNew__c != null ? debitore.DivisaNew__c : '{DivisaNew__c}');
          String codLinea = codProd  + '_' + (debitore.WGC_Mercato__c != null ? debitore.WGC_Mercato__c : (debitore.Mercato__c != null ? debitore.Mercato__c : '{Mercato__c}')) + '_' + (debitore.DivisaNew__c != null ? debitore.DivisaNew__c : '{DivisaNew__c}');
          // TODO - TEN: DA MODIFICARE LA GESTIONE DEI CAMPI UTILIZZANDO QUELLI NUOVI ATD2.0
          if(isATD) codLinea += '_' + (debitore.Anticipazione__c != null ? debitore.Anticipazione__c : '{DebitoreAnticipazione__c}') + '_' + (debitore.ProsolutoATD__c != null ? debitore.ProsolutoATD__c : '{ProsolutoATD__c}') + '_' + debitore.Rotativita__c + '_' + (debitore.Tipo__c != null ? debitore.Tipo__c : '{DebitoreTipo__c}');
          // String codLinea = codProd  + '_' + debitore.Mercato__c + '_' + debitore.DivisaNew__c;
          // if(isATD) codLinea += '_' + debitore.Anticipazione__c + '_' + debitore.ProsolutoATD__c + '_' + debitore.Rotativita__c + '_' + debitore.Tipo__c;
          codLinea += '_' + isATD;
          System.debug('@@@@ reviCodLinea: ' + reviCodLinea);
          // System.debug('@@@@ codLinea: ' + codLinea);
          Map<String, String> tmpMap = new Map<String, String>();
          if (isATD) {
            if (reviLineeMapATD.keySet().size() > 0) {
              for (String keyLine : reviLineeMapATD.keySet()) {
                  if (keyLine.startsWith(reviCodLinea)){
                    // checkDuplicatoATD = true;
                  	tmpMap.put(((Linea__c) reviLineeMapATD.get(keyLine)).Id, String.isNotBlank(((Linea__c) reviLineeMapATD.get(keyLine)).WGC_Numero_Linea_Credito__c) ? ((Linea__c) reviLineeMapATD.get(keyLine)).WGC_Numero_Linea_Credito__c : '{WGC_Numero_Linea_Credito__c}');
                  }
              }
            } else {
              for (String keyLine : oldLineeMapATD.keySet()) {
                if (keyLine.startsWith(codLinea))
                  tmpMap.put(((Linea__c) oldLineeMapATD.get(keyLine)).Id, String.isNotBlank(((Linea__c) oldLineeMapATD.get(keyLine)).WGC_Numero_Linea_Credito__c) ? ((Linea__c) oldLineeMapATD.get(keyLine)).WGC_Numero_Linea_Credito__c : '{WGC_Numero_Linea_Credito__c}');
              }
            }
          } else {
            for (String keyLine : oldLineeMap.keySet()) {
              if (keyLine.startsWith(codLinea))
                tmpMap.put(((Linea__c) oldLineeMap.get(keyLine)).Id, String.isNotBlank(((Linea__c) oldLineeMap.get(keyLine)).WGC_Numero_Linea_Credito__c) ? ((Linea__c) oldLineeMap.get(keyLine)).WGC_Numero_Linea_Credito__c : '{WGC_Numero_Linea_Credito__c}');
            }
          }
          // codLinea += '_' + (isATD ?
          //     (!reviLineeMapATD.containsKey(reviCodLinea) ? 'NEW' : (j.linee != null && j.linee.contains(reviLineeMapATD.get(reviCodLinea).Id) ? 'OLD' : 'NEW') ) : 
          //     (!oldLineeMap.containsKey(codLinea + '_OLD') ? 'NEW' : (j.linee != null && j.linee.contains(oldLineeMap.get(codLinea + '_OLD').Id) ? 'OLD' : 'NEW') )
          // );
          String tmpNumLineaCredito = (j.linee != null && j.linee.size() > 0 && containsAny(j.linee, tmpMap.keySet()) ? tmpMap.get(getContainedElement(j.linee, tmpMap.keySet())) : (containsAny(reviLineeDiCaricoMap.keySet(), tmpMap.keySet()) ? reviLineeDiCaricoMap.get(getContainedElement(reviLineeDiCaricoMap.keySet(), tmpMap.keySet())) : '{WGC_Numero_Linea_Credito__c}'));
          //String tmpNumLineaCredito = (j.linee != null && j.linee.size() > 0 && containsAny(j.linee, tmpMap.keySet()) ? tmpMap.get(getContainedElement(j.linee, tmpMap.keySet())) : '{WGC_Numero_Linea_Credito__c}');
          codLinea += '_' + tmpNumLineaCredito;
          reviCodLinea += '_' + tmpNumLineaCredito;
          System.debug('@@@@ tmpNumLineaCredito: ' + tmpNumLineaCredito);
          System.debug('@@@@ codProd: ' + codProd);
          if(!prodottiMapFinal.containsKey(codProd)) throw new Ex.WSException(ERROR_CONFIGURAZIONE);

          Prodotto__c pd = (Prodotto__c) prodottiMapFinal.get(codProd);
          Id rtLinea = (servizio == 'Confirming') ? rtConfirming : rtFactoringDiretto;

          // MB - TEN: AGGIUNTO PARAMETRO "WGC_Mercato__c"
          Linea__c l = new Linea__c(
            RecordTypeId = rtLinea,
            Opportunity__c = p.opportunityId,
            DivisaNew__c = debitore.DivisaNew__c,
            // Mercato__c = debitore.Mercato__c,
            Mercato__c = (debitore.WGC_Mercato__c != null ? debitore.WGC_Mercato__c : debitore.Mercato__c),
            DebitoreAnticipazione__c = debitore.Anticipazione__c,
            DebitoreRotativita__c = debitore.Rotativita__c,
            DebitoreTipo__c = debitore.Tipo__c,
            ProsolutoATD__c = debitore.ProsolutoATD__c,
            // Prosoluto__c = debitore.Prosoluto__c,
            // ProceduraSemplificata__c = debitore.ProceduraSemplificata__c,
            // Operativit_IAS__c = debitore.Operativit_IAS__c,
            // PrevistaLIR__c = debitore.PrevistaLIR__c,
            LineaATD__c = isATD,
            Prodotto__c = pd.Id
          );

          // solo se è linea ATD scrivo i seguenti parametri
          if(isATD && codiciATDMap.get(codProd) != null) {
            l.ICAR__c = codiciATDMap.containsKey(codProd) ? codiciATDMap.get(codProd).fidoDiCoppiaATD : null;
            l.TipoLinea__c = codiciATDMap.get(codProd).tipo;
          } else if (isATD && codiciATDMap.get(codProd) == null && reviLineeMapATD.containsKey(reviCodLinea) && !codLinea.endsWith('{WGC_Numero_Linea_Credito__c}')) {
            l.ICAR__c = ((Linea__c) reviLineeMapATD.get(reviCodLinea)).ICAR__c;
            l.TipoLinea__c = ((Linea__c) reviLineeMapATD.get(reviCodLinea)).TipoLinea__c;
          }

          String codesContainer = '';
          // parametri 280 e 101 solo sulle linee di acquisto
          // MB - TEN: Aggiunto parametro 013
          System.debug('@@@@@ reviLineeMapATD.containsKey(reviCodLinea): ' + reviLineeMapATD.containsKey(reviCodLinea));
          System.debug('@@@@@ codLinea.endsWith({WGC_Numero_Linea_Credito__c}): ' + codLinea.endsWith('{WGC_Numero_Linea_Credito__c}'));
          //SM-CART-REVI
          if(isATD && !reviLineeMapATD.containsKey(reviCodLinea) && codLinea.endsWith('{WGC_Numero_Linea_Credito__c}') && codiciATDMap.get(codProd) != null) {
            if (l.TipoLinea__c == 'lineaDiAcquisto' || String.isBlank(l.TipoLinea__c) ) {
              l.LineaATDSingola__c = codiciATDMap.get(codProd).singola ? 'S' : 'N'; // parametro 280
              l.ICARAutomaticiATD__c = codiciATDMap.get(codProd).icarAutomatici ? 'S' : 'N'; // parametro 101
              l.WGC_DocumentiOperativit_Cedente__c = codiciATDMap.get(codProd).documentiOperativitaCedente; // parametro 013
            }
            codesContainer = joinSet(codiciATDMap.keySet(), '_');
          } else if (isATD && reviLineeMapATD.containsKey(reviCodLinea) && !codLinea.endsWith('{WGC_Numero_Linea_Credito__c}')) {
            if (l.TipoLinea__c == 'lineaDiAcquisto' || String.isBlank(l.TipoLinea__c)) {
              l.LineaATDSingola__c = ((Linea__c) reviLineeMapATD.get(reviCodLinea)).LineaATDSingola__c; // parametro 280
              l.ICARAutomaticiATD__c = ((Linea__c) reviLineeMapATD.get(reviCodLinea)).ICARAutomaticiATD__c; // parametro 101
              l.WGC_DocumentiOperativit_Cedente__c = ((Linea__c) reviLineeMapATD.get(reviCodLinea)).WGC_DocumentiOperativit_Cedente__c; // parametro 013
            }
            l.WGC_Numero_Linea_Credito__c = ((Linea__c) reviLineeMapATD.get(reviCodLinea)).WGC_Numero_Linea_Credito__c;
            codesContainer = joinSet(chiaviProd, '_');
            System.debug('@@@@ chiaviProd: ' + chiaviProd);
          }

          if (oldLineeMapFinal.containsKey(codLinea))
            l.WGC_Numero_Linea_Credito__c = ((Linea__c) oldLineeMapFinal.get(codLinea)).WGC_Numero_Linea_Credito__c;
          
          l.WGC_CodiceUnivocoLinea__c = getCodiceUnivocoLinea(l, (String.isNotBlank(codesContainer) ? codesContainer : pd.Codice__c), '_'); // manca info codice KNET linea per univocità

          System.debug('@@@@ oldLineeMapFinal: ' + JSON.serialize(oldLineeMapFinal));
          System.debug('@@@@ codLinea: ' + codLinea);
          System.debug('@@@@ containsKey ' + oldLineeMapFinal.containsKey(codLinea));
          // se nella old cè, recupero l'id in modo da poter fare upsert
          String finalCodLinea;
          if (reviLineeMapATD.containsKey(reviCodLinea) && !codLinea.endsWith('{WGC_Numero_Linea_Credito__c}')) {
            l.Id = reviLineeMapATD.get(reviCodLinea).Id;
            finalCodLinea = reviCodLinea;
          } else if (oldLineeMapFinal.containsKey(codLinea)) {
            l.Id = oldLineeMapFinal.get(codLinea).Id;
            finalCodLinea = codLinea;
          } else {
            finalCodLinea = codLinea;
          }
System.debug('@@@@ finalCodLinea: ' + finalCodLinea);
          // aggiungo la linea a quelle da upsertare
          // String chiaveLinea = isATD && l.LineaATDSingola__c != 'S' ? codLinea + '_' + codiciATDMap.get(codProd).lineaAcquisto : codLinea;
          // linee.put(chiaveLinea, l);
          linee.put(finalCodLinea, l);
        }
      }
    }
System.debug('@@@@ linee.values: ' + JSON.serialize(linee.values()));
List<Linea__c> linesToDelete = new List<Linea__c>();
linesToDelete = [SELECT Id FROM Linea__c WHERE Opportunity__c = :p.opportunityId AND Id NOT IN :linee.values() AND Prodotto__r.Codice__c NOT IN :factFiscLinesCodes AND RecordTypeId IN :rTypes AND WGC_Numero_Linea_Credito__c = null];
System.debug('@@@@ linesToDelete: ' + linesToDelete);

    // upsert delle nuove/aggiornate, eliminazione di quelle che non ci sono piu
    upsert linee.values();
    delete linesToDelete;

    List<JoinLineaDebitore__c> oj = [SELECT
      Id,
      Debitore__r.FakeId__c,
      Linea__c,
      Linea__r.Prodotto__c,
      Linea__r.Mercato__c,
      Linea__r.DivisaNew__c,
      Linea__r.LineaATD__c,
      Linea__r.LineaProsoluto__c,
      Linea__r.DebitoreAnticipazione__c,
      Linea__r.DebitoreRotativita__c,
      Linea__r.DebitoreTipo__c,
      WGC_Codice_Random_Coppia__c,
      Linea__r.TipoLinea__c,
      Linea__r.LineaATDSingola__c
      FROM JoinLineaDebitore__c
      WHERE Opportunita__c = :p.opportunityId
    ];
    // FACCIO LA STESSA PROCEDURA DI SOPRA, PER L'OGGETTO DI JOIN
    Map<String, SObject> oldJoins = U.keyBy(oj, '{Debitore__r.FakeId__c}_{Linea__c}_{Linea__r.Mercato__c}_{Linea__r.DivisaNew__c}_{Linea__r.LineaATD__c}_{WGC_Codice_Random_Coppia__c}', true); // _{Linea__r.LineaProsoluto__c}
    Map<String, SObject> oldJoinsATD = U.keyBy(oj, '{Debitore__r.FakeId__c}_{Linea__c}_{Linea__r.Mercato__c}_{Linea__r.DivisaNew__c}_{WGC_Codice_Random_Coppia__c}', true);
    System.debug('@@@@ oldJoins: ' + JSON.serialize(oldJoins));
    System.debug('@@@@ oldJoinsATD: ' + JSON.serialize(oldJoinsATD));
    JoinLineaDebitore__c[] joins = new JoinLineaDebitore__c[]{};

    for(WoJoinLineaAttore j : p.joinLineaAttore) {
      NDGLinea__c debitore = (NDGLinea__c) debitoriMap.get(j.debitore);

      // codiciATDMap conterrà Codice__c della linea da creare, e la relativa configurazione (presa dalla matrice ATD)
      Map<String, CodiceATD> codiciATDMap = new Map<String,CodiceATD>();
      if(codiciProdottoATDStruct.containsKey(j.debitore)) {
        for(CodiceATD cod : codiciProdottoATDStruct.get(j.debitore)) {
          codiciATDMap.put(cod.linea, cod);
        }
      }

      for(String s : j.servizi) {
        Boolean flagMaturity = s == 'Factoring' ? debitore.Maturity__c : false;
        Boolean isATD = (s == 'Acquisto a titolo definitivo' || s == 'ATD - TiAnticipo' || s == 'ATD con proroga Confirming');
        // MB - TEN: GESTIONE "Sola Gestione"
        Boolean isSolaGestione = s == 'Sola Gestione';

        System.debug('@@@@ debitore: ' + debitore);
        Set<String> chiaviProd = new Set<String>{s + '_' + debitore.ANotifica__c + '_' + flagMaturity};
        if(isATD && j.linee != null && containsAny(j.linee, U.getSet(reviLineeATD, 'Id'))) {
          // chiaviProd = codiciATDMap.keySet();
          Set<String> reviATDCodes = U.getSet(reviLineeATD, 'Prodotto__r.Codice__c');
          reviATDCodes.addAll(codiciATDMap.keySet());
          //SM - FIX TENAM-241
          //Quando è presente una revisione ATD e ATD NOT NOT a linea singola, schiantava perchè eseguiva due volte il giro per lo stesso debitore, creando una linea non necessaria
          //Prendo solo il codice prodotto della linea legata alla join
          Set<String> code = new Set<String>();
          for(Linea__c l : reviLineeATD){
            if(j.linee.contains(l.Id))
              code.add(l.Prodotto__r.Codice__c);
          }
          if(!code.isEmpty())
            chiaviProd = code;
          else
            chiaviProd = reviATDCodes;

          System.debug('@@@ code ' + code);
          System.debug('@@@@ ATD REVI - chiaviProd: ' + chiaviProd);
        } else if (isATD) chiaviProd = codiciATDMap.keySet();
        // MB - TEN: GESTIONE "Sola Gestione"
        if (isSolaGestione) {
          Set<String> codes = new Set<String>{ debitore.ANotifica__c == true ? '561' : '661' };
          chiaviProd = codes;
        }
        //OLD SM TENAM-241
        // if(isATD) {
        //   // chiaviProd = codiciATDMap.keySet();
        //   Set<String> reviATDCodes = U.getSet([SELECT Prodotto__r.Codice__c FROM Linea__c WHERE Opportunity__c = :p.opportunityId AND WGC_Numero_Linea_Credito__c != null AND LineaATD__c = true], 'Prodotto__r.Codice__c');
        //   reviATDCodes.addAll(codiciATDMap.keySet());
        //             //SM - FIX TENAM-241
        //   //Quando è presente una revisione ATD e ATD NOT NOT a linea singola, schiantava perchè eseguiva due volte il giro per lo stesso debitore, creando una linea non necessaria
        //   //Prendo solo il codice prodotto della linea legata alla join
        //   Set<String> code = new Set<String>();
        //   for(Linea__c l : reviLineeATD){
        //     if(j.linee != null && j.linee.contains(l.Id))
        //       code.add(l.Prodotto__r.Codice__c);
        //   }
        //   if(!code.isEmpty())
        //     chiaviProd = code;
        //   else
        //     chiaviProd = reviATDCodes;
        //   // chiaviProd = reviATDCodes;

        // }
        // // MB - TEN: GESTIONE "Sola Gestione"
        // if (isSolaGestione) {
        //   Set<String> codes = new Set<String>{ debitore.ANotifica__c == true ? '561' : '661' };
        //   chiaviProd = codes;
        // }

        // MB - TEN: AGGIUNTA CONDIZIONE PER UTILIZZARE MAPPA PRODOTTI_CODICE IN CASO DI SERVIZIO "Sola Gestione"
        // Map<String, SObject> prodottiMapFinal = isATD ? prodottiATD : prodottiMap;
        Map<String, SObject> prodottiMapFinal = (isATD ? prodottiATD : (isSolaGestione ? prodottiSolaGestioneMap : prodottiMap));

        System.debug('@@@ chiaviProd ' + chiaviProd);
        for(String codProd : chiaviProd) {
          String reviCodLinea = codProd  + '_' + (debitore.WGC_Mercato__c != null ? debitore.WGC_Mercato__c : (debitore.Mercato__c != null ? debitore.Mercato__c : '{Mercato__c}')) + '_' + (debitore.DivisaNew__c != null ? debitore.DivisaNew__c : '{DivisaNew__c}');
          // TODO ATD DM: in teoria per fare il match sulla mappa bisognerebbe tenere così le stringhe, CHECK!
          String codLinea = codProd  + '_' + (debitore.WGC_Mercato__c != null ? debitore.WGC_Mercato__c : (debitore.Mercato__c != null ? debitore.Mercato__c : '{Mercato__c}')) + '_' + (debitore.DivisaNew__c != null ? debitore.DivisaNew__c : '{DivisaNew__c}');
          if(isATD) codLinea += '_' + (debitore.Anticipazione__c != null ? debitore.Anticipazione__c : '{DebitoreAnticipazione__c}') + '_' + (debitore.ProsolutoATD__c != null ? debitore.ProsolutoATD__c : '{ProsolutoATD__c}') + '_' + debitore.Rotativita__c + '_' + (debitore.Tipo__c != null ? debitore.Tipo__c : '{DebitoreTipo__c}');
          // String codLinea = codProd  + '_' + debitore.Mercato__c + '_' + debitore.DivisaNew__c;
          // if(isATD) codLinea += '_' + debitore.Anticipazione__c + '_' + debitore.ProsolutoATD__c + '_' + debitore.Rotativita__c + '_' + debitore.Tipo__c;
          codLinea += '_' + isATD;
	        Map<String, String> tmpMap = new Map<String, String>();

          if (isATD) {
            if (reviLineeMapATD.keySet().size() > 0) {
              for (String keyLine : reviLineeMapATD.keySet()) {
                if (keyLine.startsWith(reviCodLinea))
                  tmpMap.put(((Linea__c) reviLineeMapATD.get(keyLine)).Id, String.isNotBlank(((Linea__c) reviLineeMapATD.get(keyLine)).WGC_Numero_Linea_Credito__c) ? ((Linea__c) reviLineeMapATD.get(keyLine)).WGC_Numero_Linea_Credito__c : '{WGC_Numero_Linea_Credito__c}');
              }
            } else {
              for (String keyLine : oldLineeMapATD.keySet()) {
                if (keyLine.startsWith(codLinea))
                  tmpMap.put(((Linea__c) oldLineeMapATD.get(keyLine)).Id, String.isNotBlank(((Linea__c) oldLineeMapATD.get(keyLine)).WGC_Numero_Linea_Credito__c) ? ((Linea__c) oldLineeMapATD.get(keyLine)).WGC_Numero_Linea_Credito__c : '{WGC_Numero_Linea_Credito__c}');
              }
            }
          } else {
            for (String keyLine : oldLineeMap.keySet()) {
              if (keyLine.startsWith(codLinea))
                tmpMap.put(((Linea__c) oldLineeMap.get(keyLine)).Id, String.isNotBlank(((Linea__c) oldLineeMap.get(keyLine)).WGC_Numero_Linea_Credito__c) ? ((Linea__c) oldLineeMap.get(keyLine)).WGC_Numero_Linea_Credito__c : '{WGC_Numero_Linea_Credito__c}');
            }
          }
          // codLinea += '_' + (containsAny(j.linee, tmpMap.keySet()) ? tmpMap.get(getContainedElement(j.linee, tmpMap.keySet())) : '{WGC_Numero_Linea_Credito__c}');
          //SM - TEN: TENAM-204
          String tmpNumLineaCredito = (j.linee != null && j.linee.size() > 0 && containsAny(j.linee, tmpMap.keySet()) ? tmpMap.get(getContainedElement(j.linee, tmpMap.keySet())) : (containsAny(reviLineeDiCaricoMap.keySet(), tmpMap.keySet()) ? reviLineeDiCaricoMap.get(getContainedElement(reviLineeDiCaricoMap.keySet(), tmpMap.keySet())) : '{WGC_Numero_Linea_Credito__c}'));
          //String tmpNumLineaCredito = (j.linee != null && j.linee.size() > 0 && containsAny(j.linee, tmpMap.keySet()) ? tmpMap.get(getContainedElement(j.linee, tmpMap.keySet())) : '{WGC_Numero_Linea_Credito__c}');
          codLinea += '_' + tmpNumLineaCredito;
          reviCodLinea += '_' + tmpNumLineaCredito;
          // codLinea += '_' + (isATD ?
          //     'OLD' : // (!reviLineeMapATD.containsKey(reviCodLinea) ? 'NEW' : (j.linee.contains(reviLineeMapATD.get(reviCodLinea).Id) ? 'OLD' : 'NEW') ) : 
          //     (!linee.containsKey(codLinea + '_OLD') ? 'NEW' : (j.linee != null && j.linee.contains(linee.get(codLinea + '_OLD').Id) ? 'OLD' : 'NEW') )
          // );
          // String chiaveLinea = isATD ? codLinea + '_' + j.debitore : codLinea;
          // String chiaveLinea = isATD && !codiciATDMap.get(codProd).singola ? codLinea + '_' + codiciATDMap.get(codProd).lineaAcquisto : codLinea;
          String finalCodLinea;
          if (linee.containsKey(codLinea)) finalCodLinea = codLinea;
          if (linee.containsKey(reviCodLinea)) finalCodLinea = reviCodLinea;

          if(linee.containsKey(finalCodLinea) && prodottiMapFinal.containsKey(codProd)) {
            Prodotto__c pd = (Prodotto__c) prodottiMapFinal.get(codProd);
            JoinLineaDebitore__c jld = new JoinLineaDebitore__c(
              Debitore__r = new NDGLinea__c(FakeId__c = j.debitore),
              DebitoreProsoluto__c = isATD ? debitore.ProsolutoATD__c == 'Prosoluto' || debitore.ProsolutoATD__c == null : debitore.Prosoluto__c,
              Linea__c = linee.get(finalCodLinea).Id,
              Opportunita__c = p.opportunityId
            );

            // TODO ATD DM: in teoria per fare il match sulla mappa bisognerebbe tenere così le stringhe, CHECK!
	            // String key = (jld.Debitore__r.FakeId__c != null ? jld.Debitore__r.FakeId__c : '{Debitore__r.FakeId__c}') + '_' + pd.Id + '_' + (debitore.WGC_Mercato__c != null ? debitore.WGC_Mercato__c : (debitore.Mercato__c != null ? debitore.Mercato__c : '{Mercato__c}')) + '_' + (debitore.DivisaNew__c != null ? debitore.DivisaNew__c : '{DivisaNew__c}');
            // if (isATD) key += (debitore.Anticipazione__c != null ? debitore.Anticipazione__c : '{DebitoreAnticipazione__c}') + '_' + (debitore.ProsolutoATD__c != null ? debitore.ProsolutoATD__c : '{ProsolutoATD__c}') + '_' + debitore.Rotativita__c + '_' + (debitore.Tipo__c != null ? debitore.Tipo__c : '{DebitoreTipo__c}');
            String key = (jld.Debitore__r.FakeId__c != null ? jld.Debitore__r.FakeId__c : '{Debitore__r.FakeId__c}') + '_' + jld.Linea__c + '_' + (debitore.WGC_Mercato__c != null ? debitore.WGC_Mercato__c : (debitore.Mercato__c != null ? debitore.Mercato__c : '{Mercato__c}')) + '_' + (debitore.DivisaNew__c != null ? debitore.DivisaNew__c : '{DivisaNew__c}');
            if (!isATD) key += '_' + isATD; //  '_' + (debitore.ProsolutoATD__c != null ? debitore.ProsolutoATD__c : 'false') +
            // String key = jld.Debitore__r.FakeId__c + '_' + pd.Id + '_' + debitore.Mercato__c + '_' + debitore.DivisaNew__c;
            // if(isATD) key += debitore.Anticipazione__c + '_' + debitore.ProsolutoATD__c + '_' + debitore.Rotativita__c + '_' + debitore.Tipo__c;
            
            Map<String, String> tmpFDCMap = new Map<String, String>();
            if (isATD) {
              System.debug('@@@ key ' + key);
              for (String keyFDC : oldJoinsATD.keySet()) { System.debug('@@@@ j.linee: ' + j.linee); System.debug('@@@@ LINEA: ' + ((JoinLineaDebitore__c) oldJoinsATD.get(keyFDC)).Linea__c); System.debug('@@@ keyFDC ' + keyFDC);
                System.debug('@@@ ((JoinLineaDebitore__c) oldJoinsATD.get(keyFDC)).Linea__c ' + ((JoinLineaDebitore__c) oldJoinsATD.get(keyFDC)).Linea__r.TipoLinea__c);
                JoinLineaDebitore__c tmpJ = (JoinLineaDebitore__c) oldJoinsATD.get(keyFDC);
                if (keyFDC.startsWith(key) && j.linee != null && j.linee.contains(((JoinLineaDebitore__c) oldJoinsATD.get(keyFDC)).Linea__c)){
                  System.debug('@@@ entra ');
                  tmpFDCMap.put(jld.Debitore__r.FakeId__c + '_' + ((JoinLineaDebitore__c) oldJoinsATD.get(keyFDC)).Linea__c, String.isNotBlank(((JoinLineaDebitore__c) oldJoinsATD.get(keyFDC)).WGC_Codice_Random_Coppia__c) ? ((JoinLineaDebitore__c) oldJoinsATD.get(keyFDC)).WGC_Codice_Random_Coppia__c : '{WGC_Codice_Random_Coppia__c}');
                }
              }
            } else {
              for (String keyFDC : oldJoins.keySet()) { System.debug('@@@@ j.linee: ' + j.linee); System.debug('@@@@ LINEA: ' + ((JoinLineaDebitore__c) oldJoins.get(keyFDC)).Linea__c);
                if (keyFDC.startsWith(key) && j.linee != null && j.linee.contains(((JoinLineaDebitore__c) oldJoins.get(keyFDC)).Linea__c))
                  tmpFDCMap.put(jld.Debitore__r.FakeId__c + '_' + ((JoinLineaDebitore__c) oldJoins.get(keyFDC)).Linea__c, String.isNotBlank(((JoinLineaDebitore__c) oldJoins.get(keyFDC)).WGC_Codice_Random_Coppia__c) ? ((JoinLineaDebitore__c) oldJoins.get(keyFDC)).WGC_Codice_Random_Coppia__c : '{WGC_Codice_Random_Coppia__c}');
              }
            }
            System.debug('@@@@ tmpFDCMap: ' + tmpFDCMap);
            //{Debitore__r.FakeId__c}_{Linea__c}_{Linea__r.Mercato__c}_{Linea__r.DivisaNew__c}_{WGC_Codice_Random_Coppia__c}
            key += '_' + (j.linee != null && j.linee.size() > 0 && containsAny(getConcatValues(j.debitore, j.linee), tmpFDCMap.keySet()) ? tmpFDCMap.get(getContainedElement(getConcatValues(j.debitore, j.linee), tmpFDCMap.keySet())) : '{WGC_Codice_Random_Coppia__c}');
            // key += '_' + (isATD ?
            //     (!oldJoinsATD.containsKey(key + '_OLD') ? 'NEW' : (j.linee != null && j.linee.contains(oldJoinsATD.get(key + '_OLD').Id) ? 'OLD' : 'NEW') ) : 
            //     (!oldJoins.containsKey(key + '_OLD') ? 'NEW' : (j.linee != null && j.linee.contains(oldJoins.get(key + '_OLD').Id) ? 'OLD' : 'NEW') )
            // );
            System.debug('@@@@ key: ' + key);
            System.debug('@@@@ oldJoins.containsKey(key): ' + oldJoins.containsKey(key));
            System.debug('@@@@ oldJoinsATD.containsKey(key): ' + oldJoinsATD.containsKey(key));

            if(oldJoins.containsKey(key)) jld.Id = oldJoins.get(key).Id;
            else if (oldJoinsATD.containsKey(key) && !key.endsWith('{WGC_Codice_Random_Coppia__c}')) jld.Id = oldJoinsATD.get(key).Id;
              Boolean fakeJoin = true;
              System.debug('@@@ linee.get(finalCodLinea) ' + linee.get(finalCodLinea));
              if(isATD) {

                // mi serve per sapere se la linea ATD è singola o meno
                Boolean lineaSingola = linee.get(finalCodLinea).LineaATDSingola__c == 'S';
                String tipoLinea = linee.get(finalCodLinea).TipoLinea__c;
                // aggiungo il join solo se si tratta di linea non ATD oppure se è ATD ed è linea di acquisto singola e prosoluto
                if(lineaSingola && ( tipoLinea == 'lineaDiAcquisto' || String.isBlank(tipoLinea) ) && jld.DebitoreProsoluto__c) fakeJoin = false;
                // linea doppia, debitore prosolvendo o prosoluto vanno sempre e solo sulla linea di carico
                if(!lineaSingola && tipoLinea == 'lineaDiCarico') fakeJoin = false;
                // MB - TEN: fakeJoin uguale a false per prodotto Procedura Semplificata
                if (codProd == '742') fakeJoin = false;
              } else fakeJoin = false; // non si tratta di un ATD, quindi aggiungo sempre
              jld.Fake__c = fakeJoin;
              System.debug('@@@@ jld: ' + jld);

              joins.add(jld);
              // if (isATD) {
              //   if ( !oldJoinsATD.containsKey(key) )
              //     joins.add(jld);
              //   else if ( ((JoinLineaDebitore__c) oldJoinsATD.get(key)).WGC_Codice_Random_Coppia__c == null )
              //     joins.add(jld);
              // } else {
              //   if ( !oldJoins.containsKey(key) )
              //     joins.add(jld);
              //   else if ( ((JoinLineaDebitore__c) oldJoins.get(key)).WGC_Codice_Random_Coppia__c == null )
              //     joins.add(jld);
              // }
          }

        }
      }
    }

    upsert joins;
    delete [SELECT Id FROM JoinLineaDebitore__c WHERE Opportunita__c = :p.opportunityId AND Id NOT IN :joins AND WGC_Codice_Random_Coppia__c = null];

    WizardOpportunityController.saveFactFisc(p, debitoriMap);
    WizardOpportunityController.saveCorporateLines(JSON.serialize(p));
    WizardOpportunityController.saveCorporateEstero(JSON.serialize(p));

    return editRsf(p.opportunityId);
  }

  public static Boolean containsAny(Set<String> container, Set<String> values) {
    List<String> containerList = new List<String>();
    containerList.addAll(container);
    return containsAny(containerList, values);
  }

  public static Boolean containsAny(List<String> container, Set<String> values) {
    Boolean ret = false;
    if (container == null) return false;
    for (String v : values)
      if (container.contains(v)) {
        ret = true;
        break;
      }
    return ret;
  }

  public static String getContainedElement(Set<String> container, Set<String> values) {
    List<String> containerList = new List<String>();
    containerList.addAll(container);
    return getContainedElement(containerList, values);
  }

  public static String getContainedElement(List<String> container, Set<String> values) {
    String ret;
    if (container == null) return '';
    for (String v : values)
      if (container.contains(v)) {
        ret = v;
        break;
      }
    return ret;
  }
  public static List<String> getConcatValues(String debitore, List<String> ids) {
    List<String> retList = new List<String>();
    for (String id : ids)
      retList.add(debitore + '_' + id);
    return retList;
  }

  public static String getCodiceUnivocoLinea(Linea__c l, String prodCodes, String separator) {
    System.debug('@@@@ getCodiceUnivocoLinea: ' + l + ' --- ' + prodCodes + ' --- ' + separator);
    return prodCodes + separator + l.DivisaNew__c + separator + l.Mercato__c + separator + String.isBlank(l.WGC_Numero_Linea_Credito__c);
  }

  public static String joinSet(Set<String> setToJoin, String separator) {
    String res = '';
    for (String s : setToJoin)
      res += s + separator;
    return res.removeEnd(separator);
  }

  public static WoPayload saveGaranzie(String payload) {
    WoPayload p = (WoPayload) JSON.deserialize(payload, WoPayload.class);
    delete [SELECT Id FROM JoinGaranteGaranzia__c WHERE Garanzia__r.Opportunita__c = :p.opportunityId];
    JoinGaranteGaranzia__c[] garantiToUpsert = new JoinGaranteGaranzia__c[]{};
    for(WoJoinGaranziaGarante j : p.joinGaranziaGarante) {
      garantiToUpsert.add(new JoinGaranteGaranzia__c(
        Garante__c = j.garante,
        Garanzia__r = new Garanzia__c(IdEsterno__c = j.garanzia),
        PercentualeGaranzia__c = j.percentualeGaranzia
      ));
    }
    upsert garantiToUpsert;
    return editRsf(p.opportunityId);
  }

  /** Metodo per il salvataggio atomico degli step **/
  @RemoteAction
  public static WoPayload saveWizard(String payload, String step) {
    if(step == 'categorie') return saveCategorie(payload);
    if(step == 'debitori') return saveDebitori(payload);
    if(step == 'servizi') return saveServizi(payload);
    if(step == 'configurazionelinee') return saveConfigurazioneLinee(payload);
    if(step == 'configurazioneicarmanuali') return saveConfigurazioneIcarManuali(payload);
    if(step == 'garanzie') return saveGaranzie(payload);
    return null;
  }

  @RemoteAction
  public static String gestisciCointestazione(Id sObjectId) {
    return CtrlCointestazione.gestisciCointestazione(sObjectId);
  }

  @RemoteAction
  public static CtrlCointestazione.ResponseObject recuperaCointestazioni(String processId, Boolean riepilogoCointestazioni, Id sObjectId) {
    return CtrlCointestazione.recuperaCointestazioni(processId, riepilogoCointestazioni, sObjectId);
  }

  /** Metodo che recupera le informazioni dal db (per tutti gli step) e forma un mega payload **/
  @RemoteAction
  //A.M. Nuovo flag BonusEdilizi__c  
  public static WoPayload editRsf(Id opportunityId) {
    Opportunity o = [SELECT Id,
      HasFactoringDiretto__c,
      HasConfirming__c,
      ATDAnticipazione__c,
      ATDNotificaLIR__c,
      ValutazionePortafoglio__c,
      ATDMomentoAcquisto__c,
      ATDCessioneContinuativa__c,
      TiAnticipo__c,
      Cessione__c,
      HasFactFisc__c,
      BonusEdilizi__c               
      FROM Opportunity WHERE Id = :opportunityId];

    Map<String, Linea__c[]> lineeMap = U.groupBy([SELECT
      Id,
      Importo__c,
      Durata__c,
      QuotaProsoluto__c,
      DurataMaxCredito__c,
      DurataDilazione__c,
      GiorniFree__c,
      LineaATD__c,
      Prodotto__r.CodiceUnivoco__c,
      Prodotto__r.Name,
      FinalitaMutuo__c,
      Anatocismo__c,
      Mercato__c,
      ICAR__c,
      RecordType.DeveloperName,
      WGC_Polizza_CPI__c,
      WGC_Funding_BEI__c,
      WGC_Importo_Operazione__c,
      WGC_Numero_Assicurati__c,
      WGC_assicurazione_singoli__c,
      WGC_Importo_Polizza__c,
      WGC_Imp_Polizza_su_rata_quota_capitale__c,
      WGC_CodiceUnivocoLinea__c,
      WGC_Utilizzo_CC_IFIS_Impresa__c,
      WGC_Seleziona_CC_IFIS_Impresa_esistente__c,
      WGC_Tipologia__c,
      WGC_Fido__c,
      DivisaNew__c,
      WGC_Finalita_Estero__c,
      WGC_Lista_Documenti__c,
      WGC_Tipologia_Estero__c,
      WGC_Affidamento__c,
      WGC_Tipo_di_garanzia__c,
      //SM - TEN: CR 212 gestione pre ammortamento
      WGC_Pre_ammortamento__c,
      WGC_Durata_pre_ammortamento__c,
      WGC_Durata_ammortamento__c
      FROM Linea__c
      WHERE Opportunity__c = :opportunityId
    ], 'RecordType.DeveloperName');

    NDGLinea__c[] ndgLinee = [SELECT
      Id,
      FakeId__c,
      Account__c,
      Account__r.PIVA__c,
      Account__r.Name,
      DurataMediaCredito__c,
      DurataNominale__c,
      DiCuiProsoluto__c,
      Prosoluto__c,
      ProsolutoATD__c,
      Fatturato__c,
      Plafond__c,
      DivisaNew__c,
      ANotifica__c,
      Maturity__c,
      Mercato__c,
      Tipo__c,
      Servizio__c,
      CessioneContinuativa__c,
      PerfezionamentoAcquisto__c,
      NotificaLIRSingoleCessioni__c,
      Anticipazione__c,
      Rotativita__c,
      WGC_Procedura_Semplificata__c,
      WGC_Operazione_IAS__c,
      WGC_E_prevista_LIR__c,
      WGC_ContropartePrivato__c,
      Account__r.WGC_Area__c,
      IsAutoAdd__c
      FROM NDGLinea__c
      WHERE Opportunita__c = :opportunityId
      AND Tipo__c IN ('Debitore', 'Valutazione portafoglio')
    ];

    JoinLineaDebitore__c[] joins = [SELECT
      Debitore__c,
      Debitore__r.Account__c,
      Debitore__r.Account__r.Name,
      Debitore__r.FakeId__c,
      Fake__c,
      Linea__c,
      Linea__r.Prodotto__r.Servizio__c,
      Linea__r.Prodotto__r.CodiceUnivoco__c,
      Linea__r.Prodotto__r.Codice__c,
      Linea__r.Prodotto__r.WGC_Famiglia__c,
      Linea__r.LineaATD__c,
      Linea__r.TipoLinea__c,
      Linea__r.ICAR__c,
      WGC_Codice_Random_Coppia__c,
      //Added WGC_Cod_Tipo_Car__c
      WGC_Cod_Tipo_Car__c
      FROM JoinLineaDebitore__c
      WHERE Opportunita__c = :opportunityId
    ];

    JoinGaranteGaranzia__c[] joinGaranzie = [SELECT
      Garante__c,
      Garanzia__r.IdEsterno__c,
      PercentualeGaranzia__c
      FROM JoinGaranteGaranzia__c
      WHERE Garanzia__r.Opportunita__c = :opportunityId
    ];

    PConfigurato__c[] parametri = [SELECT
      Id,
      Codice__c,
      Valore__c,
      WGC_Valore_Pef_38__c,
      WGC_Valore_Prg_Pef_38__c,
      WGC_IsFixedValue__c,
      Linea__c,
      Attore__r.FakeId__c
      FROM PConfigurato__c
      WHERE Linea__r.Opportunity__c = :opportunityId
    ];

    // TODO TIANTICIPO (DM) qui valutare il fetch delle Fatture oppure un trigger che le mappa su questo oggetto)

    Map<String, IcarManuale__c[]> icarManualiMap = U.groupBy([SELECT
      Id,
      Debitore__c,
      Debitore__r.Linea__c,
      AnnoFatturatoDa__c,
      AnnoFatturatoA__c,
      NumeroFatturaDa__c,
      NumeroFatturaA__c,
      DataEmissioneDa__c,
      DataEmissioneA__c
      FROM IcarManuale__c
      WHERE Debitore__c IN :U.getSet(joins, 'Debitore__c')
    ], 'Debitore__c');

    Map<String, Certificazione__c[]> certificazioniMap;
    if (o.TiAnticipo__c)
      certificazioniMap = U.groupBy([SELECT
        Id,
        Debitore__c,
        DataFatturaMinima__c,
        DataFatturaMassima__c
        FROM Certificazione__c
        WHERE Cessione__c = :o.Cessione__c
        AND Debitore__c IN :U.getSet(joins, 'Debitore__r.Account__c')
        AND CertificazioneBocciata__c = false
      ], 'Debitore__c');


    WoPayload res = new WoPayload();
    res.opportunityId = opportunityId;
    res.tiAnticipo = o.TiAnticipo__c;
    res.referenti = new Id[]{};
    res.pfi = new WoProdotto[]{};
    res.pb = new WoProdotto[]{};
    //SM - TEN: Aggiunta la lista Banca Corporate
    res.pbc = new WoProdotto[]{};
    //SM - TEN: Aggiunta la lista Corporate Estero
    res.pbce = new WoProdotto[]{};
    res.fd = o.HasFactoringDiretto__c;
    res.factfisc = o.HasFactFisc__c;
    //A.M. Flag Bonus dilizi
    res.BonusEdil = o.BonusEdilizi__c;
    res.confirming = o.HasConfirming__c;
    res.valutazionePortafoglio = o.ValutazionePortafoglio__c;
    res.debitori = new WoDebitore[]{};
    res.valutazioniPortafoglio = new WoDebitore[]{};
    res.joinLineaAttore = new WoJoinLineaAttore[]{};
    res.joinGaranziaGarante = new WoJoinGaranziaGarante[]{};
    res.configurazioneLinee = new WoParametro[]{};
    res.configurazioneIcarManuali = new WoIcarManuale[]{};
    //SM - CART FF
    res.userInfo = [SELECT Id, Name, ProfileId, Profile.Name FROM User WHERE Id =: UserInfo.getUserId() ];

    if(lineeMap.containsKey('FactInd')) {
      for(Linea__c l : lineeMap.get('FactInd')) {
        WoProdotto prod = new WoProdotto();
        prod.id = l.Id;
        prod.tipo = l.Prodotto__r.CodiceUnivoco__c;
        prod.nome = l.Prodotto__r.Name;
        prod.importo = l.Importo__c;
        prod.durata = l.Durata__c;
        prod.quotaProsoluto = l.QuotaProsoluto__c;
        prod.durataMaxCredito = l.DurataMaxCredito__c;
        prod.durataDilazione = l.DurataDilazione__c;
        prod.giorniFree = l.GiorniFree__c;
        res.pfi.add(prod);
      }
    }

    if(lineeMap.containsKey('Fido')) {
      for(Linea__c l : lineeMap.get('Fido')) {
        WoProdotto prod = new WoProdotto();
        prod.id = l.Id;
        prod.importo = l.Importo__c;
        prod.durata = l.Durata__c;
        prod.tipo = l.Prodotto__r.CodiceUnivoco__c;
        prod.nome = l.Prodotto__r.Name;
        prod.anatocismo = l.Anatocismo__c;
        prod.finalitaMutuo = l.FinalitaMutuo__c;
        // MB - TEN: AGGIUNTI CAMPI PER GESTIONE INFO MUTUI POLIZZE CPI
        prod.polizzaCPI = l.WGC_Polizza_CPI__c;
        prod.fundingBEI = l.WGC_Funding_BEI__c;
        prod.importoOperazione = l.WGC_Importo_Operazione__c;
        prod.numeroAssicurati = l.WGC_Numero_Assicurati__c;
        prod.percAssicurazioneSingoli = l.WGC_assicurazione_singoli__c;
        prod.importoPolizza = l.WGC_Importo_Polizza__c;
        prod.importoPolizzaSuRata = l.WGC_Imp_Polizza_su_rata_quota_capitale__c;
        //SM - TEN: Aggiunto Campo gestione Fido
        prod.fido = l.WGC_Fido__c;
        //SM - TEN: CR 212 Gestione pre-ammortamento
        prod.preAmmortamento = l.WGC_Pre_ammortamento__c;
        prod.durataPreAmmortamento = l.WGC_Durata_pre_ammortamento__c;
        prod.durataAmmortamento = l.WGC_Durata_ammortamento__c;
        res.pb.add(prod);
      }
    }

    //SM - Banca Corporate - popolo il nodo pbc con le linee di tipo Corporate
    if(lineeMap.containsKey('Corporate')){
      for(Linea__c l : lineeMap.get('Corporate')){
        WoProdotto prod = new WoProdotto();
        prod.id = l.Id;
        prod.importo = l.Importo__c;
        prod.tipo = l.Prodotto__r.CodiceUnivoco__c;
        prod.nome = l.Prodotto__r.Name;
        prod.utilizzoCC = l.WGC_Utilizzo_CC_IFIS_Impresa__c;
        prod.CCSelezionato = l.WGC_Seleziona_CC_IFIS_Impresa_esistente__c;
        prod.tipologiaConto = l.WGC_Tipologia__c;
        res.pbc.add(prod);
      }
    }

    //SM - Corporate Estero - popolo il nodo pbce con le linee di tipo CorporateEstero
    if(lineeMap.containsKey('WGC_Corporate_Estero')){
      for(Linea__c l : lineeMap.get('WGC_Corporate_Estero')){
        WoProdotto prod = new WoProdotto();
        prod.id = l.Id;
        prod.importo = l.Importo__c;
        prod.tipo = l.Prodotto__r.CodiceUnivoco__c;
        prod.nome = l.Prodotto__r.Name;
        prod.utilizzoCC = l.WGC_Utilizzo_CC_IFIS_Impresa__c;
        prod.CCSelezionato = l.WGC_Seleziona_CC_IFIS_Impresa_esistente__c;
        // newLine.Importo__c = line.importo;
        prod.divisa = l.DivisaNew__c;
        prod.finalitaExport = l.WGC_Finalita_Estero__c;
        prod.listaDocumenti = l.WGC_Lista_Documenti__c;
        prod.tipologiaImpExp = l.WGC_Tipologia_Estero__c;
        prod.affidamento = l.WGC_Affidamento__c ? 'S' : 'N'; 
        prod.durataGG = l.Durata__c;
        prod.tipoGaranzia = l.WGC_Tipo_di_garanzia__c;
        prod.utilizzoCC = l.WGC_Utilizzo_CC_IFIS_Impresa__c;
        prod.CCSelezionato = l.WGC_Seleziona_CC_IFIS_Impresa_esistente__c;
        res.pbce.add(prod);
      }
    }

    // qui si mette l'importo del fido di cassa nell'ifis impresa (perchè viene salvato a 0)
    Decimal importo = null;
    for(WoProdotto pbfdc : res.pb) {
      if(pbfdc.tipo == K.CODPROD_FIDO) importo = pbfdc.importo;
    }
    for(WoProdotto pbfdc : res.pb) {
      if(pbfdc.tipo == K.CODPROD_IFIS_IMPRESA) pbfdc.importo = importo;
    }

    if(!ndgLinee.isEmpty()) {
      for(NDGLinea__c ndgLinea : ndgLinee) {
        WoDebitore debitore = new WoDebitore();
        debitore.id = ndgLinea.FakeId__c;
        debitore.account = ndgLinea.Account__c;
        debitore.piva = ndgLinea.Account__c;
        debitore.rsociale = ndgLinea.Account__r.Name;
        debitore.dmc = ndgLinea.DurataMediaCredito__c;
        debitore.dcp = ndgLinea.DiCuiProsoluto__c;
        debitore.prosoluto = ndgLinea.Prosoluto__c;
        debitore.durataNominale = ndgLinea.DurataNominale__c;
        debitore.fatturato = ndgLinea.Fatturato__c;
        debitore.plafond = ndgLinea.Plafond__c;
        debitore.divisa = ndgLinea.DivisaNew__c;
        debitore.aNotifica = ndgLinea.ANotifica__c;
        debitore.maturity = ndgLinea.Maturity__c;
        debitore.mercato = ndgLinea.Mercato__c;
        debitore.tipo = ndgLinea.Tipo__c;
        debitore.servizio = ndgLinea.Servizio__c;
        debitore.anticipazione = ndgLinea.Anticipazione__c;
        debitore.cessioneContinuativa = ndgLinea.CessioneContinuativa__c;
        debitore.momento = String.isBlank(ndgLinea.PerfezionamentoAcquisto__c) ? '' : ndgLinea.PerfezionamentoAcquisto__c;
        debitore.prosolutoATD = ndgLinea.ProsolutoATD__c;
        debitore.rotativita = ndgLinea.Rotativita__c;
        debitore.notificaLIR = ndgLinea.NotificaLIRSingoleCessioni__c;

        debitore.proceduraSemplificata = ndgLinea.WGC_Procedura_Semplificata__c;
        debitore.operazioneIAS = ndgLinea.WGC_Operazione_IAS__c;
        debitore.previstaLIR = ndgLinea.WGC_E_prevista_LIR__c;
        debitore.contropartePrivato = ndgLinea.WGC_ContropartePrivato__c;
        debitore.estero = (ndgLinea.Account__r.WGC_Area__c == 'EE');

        debitore.isFactFisc = ndgLinea.IsAutoAdd__c;
        if(ndgLinea.Tipo__c == 'Debitore') res.debitori.add(debitore);
        else if(ndgLinea.Tipo__c == 'Valutazione portafoglio') res.valutazioniPortafoglio.add(debitore);
      }
    }

    if(!joins.isEmpty()) {
      Map<String, List<JoinLineaDebitore__c>> mappaJoinLineaDeb = U.groupBy(joins, 'Debitore__r.FakeId__c');
      for(String idDebitore : mappaJoinLineaDeb.keySet()) {
        WoJoinLineaAttore joinLineaAttore = new WoJoinLineaAttore();
        joinLineaAttore.debitore = idDebitore;
        Set<String> servizi = new Set<String>{};
        Set<String> linee = new Set<String>{};
        for(JoinLineaDebitore__c j : mappaJoinLineaDeb.get(idDebitore)) {
          // MB - TEN: AGGIUNTA GESTIONE "Sola Gestione"
          if (j.Linea__r.Prodotto__r.Codice__c == '561' || j.Linea__r.Prodotto__r.Codice__c == '661') {
            servizi.add(j.Linea__r.Prodotto__r.WGC_Famiglia__c);
            linee.add(j.Linea__c);
          } else
          if(j.Linea__r.Prodotto__r.Servizio__c == 'Acquisto a titolo definitivo' || j.Linea__r.Prodotto__r.Servizio__c == 'ATD - TiAnticipo' || j.Linea__r.Prodotto__r.Servizio__c == 'ATD con proroga Confirming' || !j.Linea__r.LineaATD__c) {
            servizi.add(j.Linea__r.Prodotto__r.Servizio__c);
            linee.add(j.Linea__c);
          }

          //SM-CART-REVI Added codTipoCar
          joinLineaAttore.codTipoCar = j.WGC_Cod_Tipo_Car__c;
        }
        joinLineaAttore.servizi = U.toList(servizi);
        joinLineaAttore.linee = U.toList(linee);
        res.joinLineaAttore.add(joinLineaAttore);
      }
    }

    if(!joinGaranzie.isEmpty()) {
      for(JoinGaranteGaranzia__c j : joinGaranzie) {
        WoJoinGaranziaGarante joinGaranziaGarante = new WoJoinGaranziaGarante();
        joinGaranziaGarante.garante = j.Garante__c;
        joinGaranziaGarante.garanzia = j.Garanzia__r.IdEsterno__c;
        joinGaranziaGarante.percentualeGaranzia = j.PercentualeGaranzia__c;
        res.joinGaranziaGarante.add(joinGaranziaGarante);
      }
    }

    if(!parametri.isEmpty()) {
      for(PConfigurato__c p : parametri) {
        WoParametro pconfigurato = new WoParametro();
        pconfigurato.id = p.Id;
        pconfigurato.codice = p.Codice__c;
        pconfigurato.valore = p.Valore__c;
        pconfigurato.valorePEF38 = p.WGC_Valore_Pef_38__c;
        pconfigurato.valorePrgPEF38 = p.WGC_Valore_Prg_Pef_38__c;
        pconfigurato.isFixedValue = p.WGC_IsFixedValue__c;
        pconfigurato.linea = p.Linea__c;
        pconfigurato.attore = p.Attore__r.FakeId__c;
        // MB - TEN: RIMOSSA CONDIZIONE DI FILTRO SU CODICE O VALORE NULLI
        // if(pconfigurato.codice != null && pconfigurato.valore != null) res.configurazioneLinee.add(pconfigurato);
        res.configurazioneLinee.add(pconfigurato);
      }
    }

    // creo payload ICAR MANUALI (aka DATI FATTURA)
    Map<String, List<JoinLineaDebitore__c>> mappaJoinLineaDeb = U.groupBy(joins, 'Debitore__r.FakeId__c');
    for(String idDebitore : mappaJoinLineaDeb.keySet()) {
      for(JoinLineaDebitore__c j : mappaJoinLineaDeb.get(idDebitore)) {
        // MB - TENAM-9: GESTIONE ICAR MANUALI DA MATRICE ATD
        System.debug('SV j.Linea__r: ' + j.Linea__r);
        if (WizardOpportunityController.hasIcarManuali(j.Linea__r)) {
        // if (j.Linea__r.Prodotto__r.CodiceUnivoco__c == 'ATDTiAnticipo' || j.Linea__r.Prodotto__r.Codice__c == '742') { // TODO DM: modificare!!!!!!) (MEGLIO: FARE UN METODO CHE RITORNA UN SET DI LINEE CHE RICHIEDONO L'ICAR (va usato anche nell'innesco)) // TODO DM: qui va la condizione per cui ci si aspettano icar manuali (per ora è questa)
          WoIcarManuale woIcarManuale = new WoIcarManuale();
          woIcarManuale.debitore = idDebitore;
          woIcarManuale.ragioneSociale = j.Debitore__r.Account__r.Name;
          woIcarManuale.linea = j.Linea__c;
          woIcarManuale.icarManuali = new IcarManuale[]{};
          // aggiungo gli IcarManuali
          if(icarManualiMap.keySet().contains(j.Debitore__c)) {
            for (IcarManuale__c im : icarManualiMap.get(j.Debitore__c)) {
              IcarManuale icarManuale = new IcarManuale();
              icarManuale.annoFatturatoDa = im.AnnoFatturatoDa__c != null ? ((Datetime) im.AnnoFatturatoDa__c).format('yyyy') : '';
              icarManuale.annoFatturatoA = im.AnnoFatturatoA__c != null ? ((Datetime) im.AnnoFatturatoA__c).format('yyyy') : '';
              icarManuale.numeroFatturaDa = im.NumeroFatturaDa__c;
              icarManuale.numeroFatturaA = im.NumeroFatturaA__c;
              icarManuale.dataEmissioneDa = UDate.getLongValue(im.DataEmissioneDa__c);
              icarManuale.dataEmissioneA = UDate.getLongValue(im.DataEmissioneA__c);
              woIcarManuale.icarManuali.add(icarManuale);
            }
          }
          // aggiungo le certificazioni (TiAnticipo)
          if (o.TiAnticipo__c && certificazioniMap.keySet().contains(j.Debitore__r.Account__c)) {
            for (Certificazione__c cert : certificazioniMap.get(j.Debitore__r.Account__c)) {
              IcarManuale icarManuale = new IcarManuale();
              icarManuale.annoFatturatoDa = '';
              icarManuale.annoFatturatoA = '';
              icarManuale.numeroFatturaDa = '';
              icarManuale.numeroFatturaA = '';
              icarManuale.dataEmissioneDa = UDate.getLongValue(cert.DataFatturaMinima__c);
              icarManuale.dataEmissioneA = UDate.getLongValue(cert.DataFatturaMassima__c);
              woIcarManuale.icarManuali.add(icarManuale);
            }
          }
          res.configurazioneIcarManuali.add(woIcarManuale);
        }
      }
    }
    res.linee = getLinee(opportunityId);
    return res;
  }

  @RemoteAction
  public static Boolean gestioneMutuoMCNSA(Id opportunityId) {
    return Funzionalita__c.getInstance().GestioneMutuoMCCNSA__c;
  }

  /**
   * Prende i FakeId__c dei debitori contrassegnati come non "Fake", associati alle linee dell'opportunità.
   * @param  opportunityId id dell'opportunità in esame
   * @return               mappa "idLinea -> lista fakeIdDebitori"
   */
  @RemoteAction
  public static Map<String, String[]> getDebitoriPerLinea(String opportunityId) {
    Map<String, String[]> res = new Map<String, String[]>();
    for(JoinLineaDebitore__c j : [SELECT Linea__c, Debitore__r.FakeId__c FROM JoinLineaDebitore__c WHERE Opportunita__c = :opportunityId AND Fake__c = false]) {
      if(!res.containsKey(j.Linea__c)) res.put(j.Linea__c, new String[]{});
      res.get(j.Linea__c).add(j.Debitore__r.FakeId__c);
    }
    return res;
  }

  @RemoteAction
  public static List<Contact> searchReferenti(String opportunityId) {
    List<Contact> res = new List<Contact>();
    for(AccountContactRelation c : [SELECT
      Contact.AccountId,
      Contact.FirstName,
      Contact.LastName,
      Contact.Birthdate,
      Contact.Sesso__c,
      Contact.LuogoNascita__c,
      Contact.CodCatastaleLocNascita__c,
      Contact.CF__c,
      Contact.Phone,
      Contact.Email,
      Contact.NDGGruppo__c,
      Contact.MobilePhone,
      Contact.MailingCountry,
      Contact.MailingState,
      Contact.MailingCity,
      Contact.MailingStreet,
      Contact.MailingStreetName__c,
      Contact.MailingStreetNumber__c,
      Contact.MailingStreetType__c,
      Contact.MailingPostalCode,
      Roles
      FROM AccountContactRelation
      WHERE AccountId IN (SELECT AccountId FROM Opportunity WHERE Id = :opportunityId)
      AND Contact.IsReferenteCampagna__c = FALSE
    ]) {
      c.Contact.Ruolo__c = c.Roles;
      res.add(c.Contact);
    }

    return res;
  }

  @RemoteAction
  public static Contact[] getDestinatari(Id oppId) {
    Contact[] cL = new Contact[]{};

    for(AccountContactRelation acr : [SELECT
      Contact.Id,
      Contact.FirstName,
      Contact.LastName,
      Contact.Email
      FROM AccountContactRelation
      WHERE AccountId IN (SELECT AccountId FROM Opportunity WHERE Id =:oppId)
      AND Contact.Email != NULL
    ]) {
      cL.add(acr.Contact);
    }
    return cL;
  }

  @RemoteAction
  public static Boolean inviaMail(String destinatario) {
    MailUtils.inviaMail(destinatario,'InvioAllegati');
    return true;
  }

  @RemoteAction
  public static List<WoProdotto> getLinee(Id oppId) {
    // Map<String, SObject> serviziMap = U.keyBy(getServizi(), 'Label');

    // MB - TEN: AGGIUNTO CAMPO "WGC_Icona__c"
    // MB - TEN: Aggiunto campo WGC_isRevisione__c per gestione Revisione e Rinnovo SM-CART-REVI 
    // SM - TEN: Aggiunte condizioni per non prendere in considerazione le linee tecniche Banca Corporate - Gestito nel component WGC_Cart_Configura_Prodotto_Wrapper
    List<Linea__c> linee = [
      SELECT Prodotto__c,
      LineaATD__c,
      TipoLinea__c,
      Prodotto__r.Name,
      Prodotto__r.CodiceUnivoco__c,
      Prodotto__r.Codice__c,
      Prodotto__r.Servizio__c,
      Prodotto__r.Icona__c,
      Prodotto__r.WGC_Icona__c,
      Prodotto__r.AssociazioneDebitori__c,
      ICAR__c,
      ICARAutomaticiATD__c,
      Importo__c,
      LineaATDSingola__c,
      LineaProsoluto__c,
      Mercato__c,
      DivisaNew__c,
      // WGC_isRevisione__c
      WGC_Numero_Linea_Credito__c,
      WGC_DocumentiOperativit_Cedente__c,
      DurataDilazione__c,
      WGC_CodiceUnivocoLinea__c,
      HasCrediti__c
      FROM Linea__c
      WHERE Opportunity__c = :oppId
      AND Prodotto__r.Name != 'Fido' //SM - TEN: Banca corporate - non mostro la linea di Fido nel carrello
      /*
      AND Prodotto__r.CodiceProdotto__c != 'PCAFT'
      AND Prodotto__r.CodiceProdotto__c != 'PPFRA'
      AND Prodotto__r.CodiceProdotto__c != 'PCPOR'
      */];

    Map<String, SObject> valPortPerLine = U.keyBy([SELECT Id, Linea__c FROM JoinLineaDebitore__c WHERE Opportunita__c = :oppId AND Debitore__r.Tipo__c = 'Valutazione portafoglio'], 'Linea__c');

    List<WoProdotto> prodotti = new List<WoProdotto>();
    for(Linea__c l : linee) {
      WoProdotto p = new WoProdotto();
      p.id = l.Id;
      p.mercato = l.Mercato__c;
      p.icar = l.ICAR__C;
      p.importo = l.Importo__c;
      p.icarAutomaticiATD = l.ICARAutomaticiATD__c;
      p.atdSingola = l.LineaATDSingola__c;
      p.divisa = l.DivisaNew__c;
      p.lineaProsoluto = l.LineaProsoluto__c;
      p.codice = l.Prodotto__r.CodiceUnivoco__c;
      p.nome = l.Prodotto__r.Name;
      p.associazioneDebitori = l.Prodotto__r.AssociazioneDebitori__c;
      p.tipo = l.TipoLinea__c;
      p.lineaAtd = l.LineaATD__c;
      // p.isRevisione = l.WGC_isRevisione__c;
      p.isRevisione = l.WGC_Numero_Linea_Credito__c != null ? true : false;
      p.docsOperCede = l.WGC_DocumentiOperativit_Cedente__c;
      // p.estero = ;
      // p.contropartePrivato = ;
      p.ggDilazione = Integer.valueOf(l.DurataDilazione__c);
      p.valutazionePortafoglio = (valPortPerLine.get(l.Id) != null);
      // MB - TENAM-9: GESTIONE ICAR MANUALI DA MATRICE ATD
      p.icarManuali = WizardOpportunityController.hasIcarManuali(l);
      // p.icarManuali = l.Prodotto__r.CodiceUnivoco__c == 'ATDTiAnticipo' || l.Prodotto__r.Codice__c == '742'; // TODO ICARM: qui va la condizione per cui ci si aspettano icar manuali (per ora è questa)
      p.codiceUnivoco = l.WGC_CodiceUnivocoLinea__c;
      p.hasCrediti = l.HasCrediti__c;
      if (l.Prodotto__r.WGC_Icona__c != null) {
        p.icona = l.Prodotto__r.WGC_Icona__c;
      }
      else if(l.Prodotto__r.Icona__c != null) {
        p.icona = l.Prodotto__r.Icona__c; // (String) serviziMap.get(l.Prodotto__r.Servizio__c).get('Icona__c')
      } else {
        // ICONA PER BUG!
        p.icona = 'custom-custom34';
      }

      prodotti.add(p);
    }

    return prodotti;
  }

  /**
   * Prende la lista dei parametriprodotto associati a tutti i prodotti presenti nell'opportunità
   * @param  oppId id dell'opportunità in esame
   * @return       lista dei parametriprodotto
   */
  @RemoteAction
  public static List<WoConfigurazioneParametro> getParametriProdottiLinea(Id oppId) {

    List<Linea__c> lineeOpp = [SELECT Id, Prodotto__c FROM Linea__c WHERE Opportunity__c = :oppId];
    Set<String> prodotti = U.getSet(lineeOpp,'Prodotto__c');

    Map<String, ParametroProdotto__c[]> ppByProdotto = U.groupBy([SELECT
      Prodotto__c,
      Parametro__c,
      Dominio__c,
      ReadOnly__c,
      FormulaDiControllo__c,
      Default__c,
      RegolaDiConvalida__c,
      MessaggioRegolaDiConvalida__c,
      toLabel(Sezione__c),
      toLabel(SottoSezione__c),
      Ordine__c,
      SoloDeroga__c,
      DerogaFidoDiCoppia__c,
      Parametro__r.Name,
      Label__c,
      Obbligatorio__c,
      Parametro__r.Tipo__c,
      Parametro__r.Tipologia__c,
      Parametro__r.CodiceUnivoco__c,
      Parametro__r.WGC_Precisione_Decimali__c,
      Valore_limite_cart_KNET__c
      FROM ParametroProdotto__c
      WHERE Prodotto__c IN :prodotti
      AND (Wizard__c = true AND Sezione__c != null)
      AND Parametro__r.CodiceUnivoco__c != null
      ORDER BY Ordine__c
    ], 'Prodotto__c');

    List<WoConfigurazioneParametro> confparametri = new List<WoConfigurazioneParametro>();
    for(Linea__c linea : lineeOpp) {
      if(!ppByProdotto.containsKey(linea.Prodotto__c)) continue;
      for(ParametroProdotto__c p : ppByProdotto.get(linea.Prodotto__c)) {
        WoConfigurazioneParametro cp = new WoConfigurazioneParametro();
        cp.linea = linea.Id;
        cp.nome = p.Label__c;
        cp.codice = p.Parametro__r.CodiceUnivoco__c;
        cp.tipologia = p.Parametro__r.Tipologia__c;
        cp.sezione = p.Sezione__c;
        cp.sottoSezione = p.SottoSezione__c;
        cp.ordine = p.Ordine__c;
        cp.dominioVal = p.Dominio__c;
        cp.dominioFormula = '';
        if(cp.dominioVal != null && cp.dominioVal.startsWith('${')) cp.dominioFormula = cp.dominioVal.substring(2, cp.dominioVal.length() - 1);
        cp.readonly = p.ReadOnly__c;
        cp.defaultval = String.isBlank(p.Default__c) ? '' : p.Default__c;
        cp.defaultFormula = '';
        if(cp.defaultval.startsWith('${')) cp.defaultFormula = cp.defaultval.substring(2, cp.defaultval.length() - 1);
        cp.tipo = p.Parametro__r.Tipo__c;
        cp.regolaConvalida = p.RegolaDiConvalida__c;
        cp.messaggioConvalida = p.MessaggioRegolaDiConvalida__c;
        cp.derogaFidoDiCoppia = p.DerogaFidoDiCoppia__c;
        cp.formulaControllo = p.FormulaDiControllo__c;
        cp.soloDeroga = p.SoloDeroga__c;
        cp.obbligatorio = p.Obbligatorio__c;
        cp.precisioneDecimali = Integer.valueOf(p.Parametro__r.WGC_Precisione_Decimali__c);
        cp.limiteKNET = p.Valore_limite_cart_KNET__c;

        confparametri.add(cp);
      }
    }

    return confparametri;

  }

  @RemoteAction
  public static WoPayload saveConfigurazioneLinee(String payload) {
    System.SavePoint sp = Database.setSavepoint();
    try {
      WoPayload p = (WoPayload) JSON.deserialize(payload, WoPayload.class);
      // p.opportunityId // id opportunità
      PConfigurato__c[] listapc = new List<PConfigurato__c>();
      for(WoParametro wp : p.configurazioneLinee) {
        PConfigurato__c pc = new PConfigurato__c();
        pc.Codice__c = wp.codice;
        pc.Tipo__c = wp.tipo;
        pc.Linea__c = wp.linea;
        pc.Default__c = wp.defaultval;
        pc.Valore__c = wp.valore;
        pc.WGC_Valore_Pef_38__c = wp.valorePEF38;
        pc.WGC_Valore_Prg_Pef_38__c = wp.valorePrgPEF38;
        pc.WGC_IsFixedValue__c = (wp.isFixedValue != null ? wp.isFixedValue : false);
        if(String.isNotBlank(wp.attore)) pc.Attore__r = new NDGLinea__c(FakeId__c = wp.attore);
        listapc.add(pc);
      }

      // recupero i parametri dilazionati da copiare nell'account
      List<ParametriDilazionati__mdt> pdilazionati = [SELECT Label, Codice__c FROM ParametriDilazionati__mdt];
      Map<String, SObject> pdilazionatiMap = U.keyBy(pdilazionati, 'Codice__c');
      Opportunity opp = [SELECT AccountId FROM Opportunity WHERE Id = :p.opportunityId];
      Account oppAccount = new Account();
      oppAccount.Id = opp.AccountId;

      for(PConfigurato__c pd : listapc) {
        if(pdilazionatiMap.containsKey(pd.Codice__c)) {
          SObject pdilazionato = pdilazionatiMap.get(pd.Codice__c);
          oppAccount.put((String) pdilazionato.get('Label'), pd.Valore__c);
        }
      }

      update oppAccount;

      Set<Id> lineeDaRimpiazzare = U.getIdSet(listapc, 'Linea__c');

      Linea__c[] lineeATDTA = [SELECT Id,
        Opportunity__r.Cessione__r.CostoComplessivoC138__c,
        (SELECT Id,
          Codice__c,
          Attore__c,
          Default__c,
          Linea__c,
          Tipo__c,
          Valore__c FROM PConfigurati__r
          WHERE Codice__c = 'C138'
          AND Attore__c = null)
        FROM Linea__c
        WHERE Prodotto__r.CodiceUnivoco__c = 'ATDTiAnticipo'
        AND Id IN :lineeDaRimpiazzare];

      if (!lineeATDTA.isEmpty()) {
        for (Linea__c l : lineeATDTA) {
          PConfigurato__c pc138;
          String valore;
          if (!l.PConfigurati__r.isEmpty()) {
            valore = l.PConfigurati__r[0].Valore__c;
          } else {
            if (l.Opportunity__r.Cessione__r.CostoComplessivoC138__c != null)
              valore = String.valueOf(l.Opportunity__r.Cessione__r.CostoComplessivoC138__c);
          }
          pc138 = new PConfigurato__c(
            Codice__c = 'C138',
            Attore__c = null,
            Default__c = '1',
            Linea__c = l.Id,
            Tipo__c = 'Condizione economica',
            Valore__c = valore
          );
          listapc.add(pc138);
        }
      }

      delete [SELECT Id FROM PConfigurato__c WHERE Linea__c IN :lineeDaRimpiazzare];
      upsert listapc;

      // MB - TEN: CANCELLAZIONE PARAMETRI CON SINGOLO VALORE MESE/FLAT DEFINITI NELLA VARIABILE "PARAMS_SINGLE_VALUE_ON_DEROGA"
      // delete [SELECT Id FROM PConfigurato__c WHERE Codice__c IN :PARAMS_SINGLE_VALUE_ON_DEROGA AND Linea__c IN :lineeDaRimpiazzare AND Attore__c != null AND (Valore__c = '0' OR Valore__c = '')];

      // salvo i parametri aggiuntivi
      PConfigurato__c[] listaAgg = new List<PConfigurato__c>();

      // debitori
      for(WoParametro wp : p.parametriAggiuntivi) {
        PConfigurato__c pc = new PConfigurato__c();
        pc.Codice__c = wp.codice;
        pc.Tipo__c = wp.tipo;
        pc.Linea__c = wp.linea;
        pc.Valore__c = wp.valore;
        if(String.isNotBlank(wp.attore)) pc.Attore__r = new NDGLinea__c(FakeId__c = wp.attore);
        listaAgg.add(pc);
      }

      Set<Id> lineeDaRimpiazzareAgg = U.getIdSet(listaAgg, 'Linea__c');
      delete [SELECT Id FROM PConfigurato__c WHERE Linea__c IN :lineeDaRimpiazzareAgg AND Tipo__c = 'Parametro aggiuntivo'];
      upsert listaAgg;

      //Cancello garanzie orfane
      delete [
        SELECT Id
        FROM Garanzia__c
        WHERE Linea__c = null
        AND Tipo__c = 'Specifica'
        AND Opportunita__c = :p.opportunityId
      ];

      return editRsf(p.opportunityId);
    } catch (DmlException e) {
      Database.rollback(sp);
      throw new Ex.WSException(e.getDmlMessage(0), e);
    }
  }

  @RemoteAction
  public static WoPayload saveConfigurazioneIcarManuali(String payload) {
    // TODO TIANTICIPO (DM): tenere in considerazione la logica per il TA
    System.SavePoint sp = Database.setSavepoint();

    try {
      WoPayload p = (WoPayload) JSON.deserialize(payload, WoPayload.class);

      // recupero i debitori per l'opportunità corrente
      NDGLinea__c[] debitoriList = [SELECT
        Id,
        FakeId__c,
        Tipo__c
        FROM NDGLinea__c
        WHERE Opportunita__c = :p.opportunityId
        AND Tipo__c IN ('Debitore')
      ];
      Map<String, SObject> debitoriMap = U.keyBy(debitoriList, 'FakeId__c');
      Set<Id> idDebitoriSet = U.getIdSet(debitoriList, 'Id');

      IcarManuale__c[] listaim = new List<IcarManuale__c>();
      for (WoIcarManuale wim : p.configurazioneIcarManuali) {
        Id idDeb = ((NDGLinea__c) debitoriMap.get(wim.debitore)).Id;
        for (IcarManuale i : wim.icarManuali) {
          IcarManuale__c im = new IcarManuale__c();
          im.Debitore__c = idDeb;
          if (String.isNotBlank(i.annoFatturatoDa)) im.AnnoFatturatoDa__c = Date.newinstance(Integer.valueOf(i.annoFatturatoDa), 1, 1);
          if (String.isNotBlank(i.annoFatturatoA)) im.AnnoFatturatoA__c = Date.newinstance(Integer.valueOf(i.annoFatturatoA), 1, 1);
          im.NumeroFatturaDa__c = i.numeroFatturaDa;
          im.NumeroFatturaA__c = i.numeroFatturaA;
          im.DataEmissioneDa__c = UDate.getDateValue(i.dataEmissioneDa);
          im.DataEmissioneA__c = UDate.getDateValue(i.dataEmissioneA);
          listaim.add(im);
        }
      }

      delete [SELECT Id FROM IcarManuale__c WHERE Debitore__c IN :idDebitoriSet];
      upsert listaim;

      return editRsf(p.opportunityId);
    } catch (DmlException e) {
      Database.rollback(sp);
      throw new Ex.WSException(e.getDmlMessage(0), e);
    }
  }

  @RemoteAction
  public static Boolean saveGaranzia(Garanzia__c garanzia) {
    try {
      Database.upsert(garanzia, Garanzia__c.IdEsterno__c);
      return true;
    } catch(DmlException e) {
      throw new Ex.WSException(e.getDmlMessage(0), e);
    }
  }

  @RemoteAction
  public static MatriceGaranzie__mdt[] getGaranzie() {
    return [SELECT
      CodiceCedacri__c,
      CodiceKNET__c,
      Omnibus__c,
      Specifica__c,
      Tipologia__c,
      ProQuota__c,
      Tipo__c,
      Label,
      ProdottiGaranteDefault__c
      FROM MatriceGaranzie__mdt
    ];
  }

  @RemoteAction
  public static Boolean removeGaranzia(String garanziaId) {
    try {
      delete [SELECT Id FROM Garanzia__c WHERE IdEsterno__c = :garanziaId];
      return true;
    } catch(DmlException e) {
      throw new Ex.WSException(e.getDmlMessage(0), e);
    }
  }

  @RemoteAction
  public static Boolean removeGarante(String garanteId) {
    try {
      delete [SELECT Id FROM NDGLinea__c WHERE Id = :garanteId];
      return true;
    } catch(DmlException e) {
      throw new Ex.WSException(e.getDmlMessage(0), e);
    }
  }

  @RemoteAction
  public static Boolean removeGaranti(Id[] garantiIds) {
    try {
      delete [SELECT Id FROM NDGLinea__c WHERE Id IN :garantiIds];
      return true;
    } catch(DmlException e) {
      throw new Ex.WSException(e.getDmlMessage(0), e);
    }
  }

  @RemoteAction
  public static SObject saveGarante(Id objId, Id oppId) {
    NDGLinea__c[] l = [SELECT Id FROM NDGLinea__c WHERE (Account__c = :objId OR Contact__c = :objId) AND Tipo__c = 'Garante' AND Opportunita__c = :oppId];
    NDGLinea__c newL = new NDGLinea__c(
      Opportunita__c = oppId,
      Account__c = objId.getSobjectType() == Account.SObjectType ? objId : null,
      Contact__c = objId.getSobjectType() == Contact.SObjectType ? objId : null,
      Tipo__c = 'Garante',
      RecordTypeId = U.getRecordTypes('NDGLinea__c').get('Referente').Id,
      TipoGarante__c = 'S'
    );

    if(!l.isEmpty()) {
      newL.Id = l[0].Id;
    }

    try {
      upsert newL;
      NDGLinea__c newNDGL = [SELECT Id,
        Nome__c,
        NDG__c,
        CF__c,
        CodiceRapporto__c,
        TipoGarante__c
        FROM NDGLinea__c
        WHERE Id = :newL.Id
      ];
      logGarante(new List<NDGLinea__c>{newNDGL}, oppId);
      return newNDGL;
    } catch(DmlException e) {
      throw new Ex.WSException(e.getDmlMessage(0), e);
    }
  }

  public static NDGLinea__c creaGarante(Id oppId, Id objId, String tipoGarante, String codiceRapporto) {
    return new NDGLinea__c(
      Opportunita__c = oppId,
      Account__c = objId.getSobjectType() == Account.SObjectType ? objId : null,
      Contact__c = objId.getSobjectType() == Contact.SObjectType ? objId : null,
      Tipo__c = 'Garante',
      RecordTypeId = U.getRecordTypes('NDGLinea__c').get('Referente').Id,
      CodiceRapporto__c = codiceRapporto,
      TipoGarante__c = tipoGarante
    );
  }

  @RemoteAction
  public static SObject[] saveGaranti(CtrlCointestazione.Cointestazione cointestazione, Id oppId) {
    NDGLinea__c[] garantiGiaEsistenti = [SELECT Id,
      Account__c,
      Contact__c
      FROM NDGLinea__c
      WHERE Tipo__c = 'Garante'
      AND Opportunita__c = :oppId
      AND CodiceRapporto__c = :cointestazione.codiceRapporto];

    NDGLinea__c[] garantiNuovi = new NDGLinea__c[]{};
    NDGLinea__c capoRete = creaGarante(oppId, cointestazione.capoRete.Id, 'P', cointestazione.codiceRapporto);
    for (NDGLinea__c attore : garantiGiaEsistenti) {
      if (attore.Account__c == cointestazione.capoRete.Id || attore.Contact__c == cointestazione.capoRete.Id) {
        capoRete.Id = attore.Id;
        break;
      }
    }
    garantiNuovi.add(capoRete);
    for (SObject cointestatario : cointestazione.cointestatari) {
      NDGLinea__c garanteNuovo = creaGarante(oppId, (Id) cointestatario.get('Id'), 'F', cointestazione.codiceRapporto);
      if(!garantiGiaEsistenti.isEmpty()) {
        for (NDGLinea__c attore : garantiGiaEsistenti) {
          if (attore.Account__c == cointestatario.get('Id') || attore.Contact__c == cointestatario.get('Id')) {
            garanteNuovo.Id = attore.Id;
            break;
          }
        }
      }
      garantiNuovi.add(garanteNuovo);
    }

    try {
      upsert garantiNuovi;
      NDGLinea__c[] garantiInseriti = [SELECT Id,
        Nome__c,
        NDG__c,
        CF__c,
        CodiceRapporto__c,
        TipoGarante__c
        FROM NDGLinea__c
        WHERE Id IN :U.getIdSet(garantiNuovi, 'Id')
      ];
      logGarante(garantiInseriti, oppId);
      return garantiInseriti;
    } catch(DmlException e) {
      throw new Ex.WSException(e.getDmlMessage(0), e);
    }
  }

  /**
  Setta i garanti di default per le garanzie in percentuale con certe linee associate
  (id dei garanti di default salvati nel custom setting UtenzeDefault)
  ID 77
  */
  @RemoteAction
  public static SObject saveGaranteDefault(Garanzia__c garanzia, Id oppId){
    // ID77 - la logica scatta per ogni garanzia con Tipo__c = 'Percentuale' (al momento solo la GARFD)
    MatriceGaranzie__mdt matrGara = [SELECT CodiceKnet__c, Tipo__c, ProdottiGaranteDefault__c FROM MatriceGaranzie__mdt WHERE CodiceKnet__c = :garanzia.CodiceGaranzia__c];
    //linee per le quali deve scattare la logica
    if(matrGara.Tipo__c == 'Percentuale'){
      Set<String> prodottiConGaranteDefault = new Set<String>(matrGara.ProdottiGaranteDefault__c.split(';'));
      Linea__c linea = [SELECT Prodotto__r.CodiceUnivoco__c FROM Linea__c WHERE Id = :garanzia.Linea__c];
      if(prodottiConGaranteDefault.contains(linea.Prodotto__r.CodiceUnivoco__c)){
        NDGLinea__c newAttore = new NDGLinea__c(
          Account__c = linea.Prodotto__r.CodiceUnivoco__c == WizardOpportunityController.COD_MUTUO_CONTROGARANTITO ? (Id) UtenzeDefault__c.getInstance().get('IdGaranteDefaultMutuo__c') : (Id) UtenzeDefault__c.getInstance().get('IdGaranteDefault' + linea.Prodotto__r.CodiceUnivoco__c + '__c'),
          Opportunita__c = oppId,
          Tipo__c = 'Garante',
          RecordTypeId = U.getRecordTypes('NDGLinea__c').get('Referente').Id,
          TipoGarante__c = 'S');
        try {
          insert newAttore;
          NDGLinea__c attoreDefault = [SELECT Id, Nome__c, NDG__c, CF__c, TipoGarante__c, CodiceRapporto__c FROM NDGLinea__c WHERE Id = :newAttore.Id];
          return attoreDefault;
        }
        catch(DmlException e) {
          throw new Ex.WSException(e.getDmlMessage(0), e);
          return null;
        }
      }
    }
    return null;
  }

  /**
   * Ritorna l'elenco dei prodotti che è possibile selezionare nel wizard.
   * ID 216 - Mutuo MCC NSA: per gli operatori NSA è selezionabile solo questo prodotto
   */
  @RemoteAction
  public static Map<String, List<Map<String, String>>> getDominiProdotti() {
    Boolean soloMutuoMCNSA = Funzionalita__c.getInstance().GestioneMutuoMCCNSA__c;
    String prodottoQuery = QueryBuilder.newInstance('Prodotto__c', new String[]{
      'CodiceUnivoco__c',
      'Name',
      'CategoriaProdotto__c'})
      .beginFilter()
      .add('CategoriaProdotto__c', QBOp.QIN, new String[]{'Factoring indiretto', 'Prodotto bancario'})
      .add('CodiceUnivoco__c', QBOp.QIN, new String[]{K.CODPROD_MUTUO_PCNSA, K.CODPROD_MUTUO_PCNSASA}, soloMutuoMCNSA)
      .add('CodiceUnivoco__c', QBOp.QNOT_EQUAL, K.CODPROD_MUTUO_PCNSA, !soloMutuoMCNSA)
      .endFilter()
      .getQuery();

    Map<String, Prodotto__c[]> m = U.groupBy(Database.query(prodottoQuery), 'CategoriaProdotto__c');

    Map<String, List<Map<String, String>>> res = new Map<String, List<Map<String, String>>>();
    for(String categoria : m.keySet()) {
      res.put(categoria, new List<Map<String, String>>());
      for(Prodotto__c p : m.get(categoria)) {
        res.get(categoria).add(new Map<String, String>{
          'label' => p.Name,
          'value' => p.CodiceUnivoco__c
        });
      }
    }

    return res;
  }

  /**
   * Crea un log per ogni garante visualizzato
   * @param  garanti lista di garanti visualizzati
   * @param  oppId   id dell'opportunita
   */
  @RemoteAction
  public static void logGarante(NDGLinea__c[] garanti, String oppId) {
    Log__c[] logs = new List<Log__c>();
    Id recordTypeId = Schema.SObjectType.Log__c.getRecordTypeInfosByName().get('Log Garante').getRecordTypeId();
    String alias = [SELECT Alias FROM User WHERE Id = :UserInfo.getUserId()].Alias;
    for(NDGLinea__c garante : garanti) {
      Log__c log = new Log__c();
      log.Source__c = 'Log Garante';
      log.Tipo__c = 'Garante';
      log.CodiceApplicazione__c = 'CRM';
      log.CodiceCliente__c = garante.Id;
      log.CodiceFunzione__c = 'FUNCTION 01';
      log.CodiceRapporto__c = oppId;
      log.Opportunity__c = oppId;
      log.ClientIP__c = (!Test.isRunningTest()) ? U.GetUserIPAddress() : '';
      log.OUNum__c = garante.NDG__c;
      log.Query__c = 'SELECT Id, NDG__c, Opportunita__c FROM NDGLinea__c WHERE NDG__c = \'' + garante.NDG__c + '\'';
      log.TipoCodiceCliente__c = 'ID';
      log.RecordTypeId = recordTypeId;
      log.CodiceOperatore__c = alias;
      logs.add(log);
    }
    insert logs;

  }

  @RemoteAction
  public static Map<String, Sobject> fetchInfograficheTiAnticipo() {
    InfograficaTiAnticipo__mdt[] infografiche = [SELECT
      DeveloperName,
      Titolo__c,
      NumeroSezioni__c,
      Sottotitolo__c,
      Titolo1__c,
      Testo1__c,
      Titolo2__c,
      Testo2__c,
      Titolo3__c,
      Testo3__c
      FROM InfograficaTiAnticipo__mdt];

    return (Map<String, SObject>) U.keyBy(infografiche, 'DeveloperName');
  }
}