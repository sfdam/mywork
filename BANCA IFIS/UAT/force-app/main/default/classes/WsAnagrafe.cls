public without sharing class WsAnagrafe {

  public final static String CEDACRI = 'Cedacri';
  public final static String NATURAGIURIDICA_PF = 'PF';
  public final static String NOT_FOUND_ERROR = 'NDG/CODICE FISCALE NON TROVATO';
  private final static String COLLNDG_COINTESTAZIONE = 'COINT';
  private final static String COLLNDG_PF_PG = 'DELEG';
  private final static String IMPRESA = 'IMPRESA';
  private final static String PRIVATO = 'PRIVATO';
  private final static String DITTA_INDIVIDUALE = 'DI';
  private final static String SETRETIANAGRAFICHE_ERROR = 'ERROR';

  private final static String GESTORE_CEDENTE_COD = 'SGE';
  private final static String GESTORE_CEDENTE = 'GESTORE CEDENTE';
  private final static String GESTORE_DEBITORE_COD = 'SRD';
  private final static String GESTORE_DEBITORE = 'GESTORE DEBITORE';
  private final static String SETTORISTA_COD = 'SRC';
  private final static String SETTORISTA = 'SETTORISTA';
  private final static String PRESENTATORE_COD = 'SSU';
  private final static String PRESENTATORE = 'PRESENTATORE';
  private final static Map<String, String> collTipoMap = new Map<String, String> {
    GESTORE_CEDENTE_COD => GESTORE_CEDENTE,
    GESTORE_DEBITORE_COD => GESTORE_DEBITORE,
    SETTORISTA_COD => SETTORISTA,
    PRESENTATORE_COD => PRESENTATORE
  };
  private final static Map<String, Long> collRappMap = new Map<String, Long> {
    GESTORE_CEDENTE_COD => 9900000000001L,
    GESTORE_DEBITORE_COD => 9900000000004L,
    SETTORISTA_COD => 9900000000002L,
    PRESENTATORE_COD => 9900000000003L
  };

  //metodi

  /**
   * Ricerca anagrafica online (ANAG15)
   */
  public static SearchAnagraficaRes searchAnagrafica(String denominazione, String cf, String cognome, String nome) {
	return searchAnagrafica(denominazione, cf, cognome, nome, null);
  }

  /**
   * Ricerca anagrafica online (ANAG15)
   */
  public static SearchAnagraficaRes searchAnagrafica(String denominazione, String cf, String cognome, String nome, Long ndg) {
    //adione CRM ID 80
    if (String.isBlank(denominazione) && String.isBlank(cf) && String.isBlank(cognome) && ndg == null) {
      throw new Ex.CedacriInputException('searchAnagrafica input vuoto');
    }

    PayloadGenericoInput input = new PayloadGenericoInput();
    input.codiceFiscale = String.isBlank(cf) ? null : cf.leftPad(16, '0'); //'FLPFRC71B23F158U' - '0000011111111111'
	input.ndg = ndg;
    input.ragioneSociale = denominazione;
    input.cognome = cognome;
    input.nome = nome;
    input.tipoAggregazione = 'OR';

    return (SearchAnagraficaRes) WsRestUtils.callService(
      'UrlRicercaAnagraficaCedacri__c',
      input,
      SearchAnagraficaRes.class
    );
  }

  /**
   * Interrogazione dati anagrafici online (ANAG01 ANAG25 ANAG31)
   */
  public static GetAnagraficaRes getAnagrafica(String ndg, String cf) {
    if (String.isBlank(ndg) && String.isBlank(cf)) {
      throw new Ex.CedacriInputException('getAnagrafica input vuoto');
    }

    PayloadGenericoInput input = new PayloadGenericoInput();
    if (String.isNotBlank(ndg)) {
      input.ndg = Long.valueOf(ndg);
    } else if (String.isNotBlank(cf)) {
      input.codiceFiscale = cf;
    }

    return (GetAnagraficaRes) WsRestUtils.callService(
      'UrlGetDatiAnagraficiCedacri__c',
      input,
      GetAnagraficaRes.class
    );
  }

  /**
   * Censimento anagrafico LIGHT Ndg online (ANAG51 ANAG50 ANAG49 ANAG09)
    */
  public static CensimentoLightRes censimentoLight(WsAnagraficaBean input) {
    return (CensimentoLightRes)WsRestUtils.callService(
      'UrlSetAnagraficaLight__c',
      input,
      'WTCensimentoLight',
      CensimentoLightRes.class
    );
  }

  /**
   * Censimento anagrafico Ndg online (ANAG26)
    */
  public static CensimentoFullRes censimentoFull(WsAnagraficaBean input) {
    return (CensimentoFullRes) WsRestUtils.callService(
      'UrlSetAnagraficaCedacri__c',
      input,
      'WTCensimentoFull',
      CensimentoFullRes.class
    );
  }

  /**
   * Censimento anagrafico Ndg online (ANAG57)
    */
  public static ModificaDatiAggiuntiviQQResponse modificaDatiAggiuntiviQQ(ModificaDatiAggiuntiviQQInput input) {
    return (ModificaDatiAggiuntiviQQResponse) WsRestUtils.callService(
      'URLModificaDatiAggiuntiviQQ__c',
      input,
      ModificaDatiAggiuntiviQQResponse.class
    );
  }

  /**
   * Recupero informazioni QQ(ANAG58)
    */
  public static DatiBilancioResponse datiBilancio(DatiBilancioInput input) {
    return (DatiBilancioResponse) WsRestUtils.callService(
      'UrlDatiBilancio__c',
      input,
      DatiBilancioResponse.class
    );
  }

  /**
   * Variazione dei rapporti anagrafici. Modifica ndg esistenti a seconda della tipologia della natura giuridica del cliente (ANAG10)
   */
  public static VariazioneRes variazione(WsAnagraficaBean input) {
    return (VariazioneRes) WsRestUtils.callService(
      'UrlSetAnagraficaVariazione__c',
      input,
      'WTVariazione',
      VariazioneRes.class
    );
  }

  public static GestioneCollNdgResponse gestioneCollNdg(String ndg) {
    if (String.isBlank(ndg)) {
      throw new Ex.CedacriInputException('gestioneCollNdg input vuoto');
    }
    GestioneCollNdgInput input = new GestioneCollNdgInput('L', null);
    input.ndg = Long.valueOf(ndg);

    return (GestioneCollNdgResponse) WsRestUtils.callService(
      'UrlGestioneCollNdg__c',
      input,
      GestioneCollNdgResponse.class
    );
  }

  public static GestioneCollNdgResponse creaCointestazioneCollNdg(String[] ndgs) {
    if (ndgs == null || ndgs.isEmpty()) {
      throw new Ex.CedacriInputException('creaCointestazioneCollNdg input vuoto');
    }
    GestioneCollNdgInput input = new GestioneCollNdgInput('I', COLLNDG_COINTESTAZIONE);
    for (String ndg : ndgs) {
      input.addElementoRelazioneTabella(ndg);
    }

    return (GestioneCollNdgResponse) WsRestUtils.callService(
      'UrlGestioneCollNdg__c',
      input,
      GestioneCollNdgResponse.class
    );
  }

  public static GestioneCollNdgResponse associaPfPgCollNdg(
    String ndgAccount,
    String ndgContact,
    String tipoRete,
    Boolean cedenteCapoRete
  ) {
    if (String.isBlank(ndgAccount) || String.isBlank(ndgContact) || String.isBlank(tipoRete) || cedenteCapoRete == null) {
      throw new Ex.CedacriInputException('associaPfPgCollNdg input vuoto');
    }

    GestioneCollNdgInput input = new GestioneCollNdgInput('N', tipoRete);
    input.addElementoRelazioneDati(ndgAccount, cedenteCapoRete);
    input.addElementoRelazioneDati(ndgContact, !cedenteCapoRete);

    return (GestioneCollNdgResponse) WsRestUtils.callService(
      'UrlGestioneCollNdg__c',
      input,
      GestioneCollNdgResponse.class
    );
  }

  public static GestioneCollNdgResponse WGC_variazionePfPgCollNdg(
    String ndgAccount,
    String ndgContact,
    String tipoRete,
    Boolean cedenteCapoRete,
    ElementoNdg[] collegamenti 
  ) {
    if (String.isBlank(ndgAccount) || String.isBlank(ndgContact) || String.isBlank(tipoRete) || cedenteCapoRete == null) {
      throw new Ex.CedacriInputException('associaPfPgCollNdg input vuoto');
    }

    GestioneCollNdgInput input = new GestioneCollNdgInput('V', tipoRete);
    WsAnagrafe.Rapporto rapporto = new WsAnagrafe.Rapporto();
    rapporto.filiale = collegamenti[0].rapporto.filiale;
    rapporto.conto =  collegamenti[0].rapporto.conto;
    rapporto.servizio =  collegamenti[0].rapporto.servizio;
    rapporto.flagEstinto =  collegamenti[0].rapporto.flagEstinto;

    input.rapporto = rapporto;

    input.addElementoRelazioneDati(ndgAccount, cedenteCapoRete);
    input.addElementoRelazioneDati(ndgContact, !cedenteCapoRete);

    for(ElementoNdg singleElement : collegamenti){
      input.addElementoRelazioneDati(String.valueOf(singleElement.ndg), !cedenteCapoRete);
    }

    System.debug('SV WGC_variazionePfPgCollNdg input: ' + input);

    return (GestioneCollNdgResponse) WsRestUtils.callService(
      'UrlGestioneCollNdg__c',
      input,
      GestioneCollNdgResponse.class
    );
  }

  public static SetRetiAnagraficheIfisResponse setRetiAnagraficheIfis(
    String ndgCliente,
    String ndgGestoreCedente,
    String ndgGestoreDebitore,
    String ndgSettorista,
    String ndgPresentatore
  ) {
    if (String.isBlank(ndgCliente) || String.isBlank(ndgSettorista)) {
      throw new Ex.CedacriInputException('setRetiAnagraficheIfis: gli NDG di Cliente e Settorista sono obbligatori');
    }

    SetdatianagraficiifisInput input = new SetdatianagraficiifisInput(ndgCliente);
    input.addSoggettoCollegato(ndgSettorista, SETTORISTA_COD);

    if (String.isNotBlank(ndgGestoreCedente)) {
      input.addSoggettoCollegato(ndgGestoreCedente, GESTORE_CEDENTE_COD);
    }

    if (String.isNotBlank(ndgGestoreDebitore)) {
      input.addSoggettoCollegato(ndgGestoreDebitore, GESTORE_DEBITORE_COD);
    }

    if (String.isNotBlank(ndgPresentatore)) {
      input.addSoggettoCollegato(ndgPresentatore, PRESENTATORE_COD);
    }

    input.numeroCollegati = input.soggettiCollegati.size();
    return (SetRetiAnagraficheIfisResponse) WsRestUtils.callService(
      'UrlSetRetianagraficheIfis__c',
      input,
      SetRetiAnagraficheIfisResponse.class
    );
  }

  //input payload
  public class PayloadGenericoInput extends WsRestInput.CommonInput {
    public Long ndg;
    public String codiceFiscale;
    public String cognome;
    public String nome;
    public String ragioneSociale;
    public String tipoAggregazione;
    public String funzione;
    public String tipoRete;
    public String tabellaNDG;
    public String sae;
    public String rae;
    public String ndgSCO;
    public String flagControlloSCO;
    public String flagPep;
  }

  public class GestioneCollNdgInput extends WsRestInput.CommonInput {
    public String funzione;
    public Long ndg;
    public String tipoRete;
    public TabellaNdg tabellaNDG;
    public Integer sae;
    public Integer rae;
    public Long ndgSCO;
    public String flagControlloSCO;
    public Long ndgRete;
    public Rapporto rapporto;
    public ElementoNdg[] datiNdg;

    public GestioneCollNdgInput() {}

    public GestioneCollNdgInput(String funzione, String tipoRete) {
      this.funzione = funzione;
      this.tipoRete = tipoRete;
    }

    public void addElementoRelazioneTabella(String ndg) {
      if (tabellaNDG == null) {
        tabellaNDG = new TabellaNdg();
      }
      tabellaNDG.codice.add(Long.valueOf(ndg));
    }

    public void addElementoRelazioneDati(String ndg, Boolean isCapoRete) {
      if (datiNdg == null) {
        datiNdg = new ElementoNdg[] {};
      }
      datiNdg.add(new ElementoNdg(ndg, isCapoRete));
    }
  }

  public class elencorapportiInput extends WsRestInput.CommonInput {
    public Long ndg;
    public String tipoRappporto;
    public String servizio;
    public String codiceBox;
    public String flagStorico;
    public String flagStampa;
  }

  public class ModificaDatiAggiuntiviQQInput extends WsRestInput.CommonInput {
    public Long ndg;
    public RequestDati requestDati;
  }

  public class DatiBilancioInput extends WsRestInput.CommonInput {
    public Long ndg;
    public Integer codiceModulo;
  }

  public class SetdatianagraficiifisInput extends WsRestInput.CommonInput {
    public Long ndg;
    public Integer numeroCollegati;
    public SoggettoCollegato[] soggettiCollegati;

    public SetdatianagraficiifisInput(String ndgCliente) {
      this.ndg = Long.valueOf(ndgCliente);
      soggettiCollegati = new SoggettoCollegato[] {};
    }

    public void addSoggettoCollegato(String ndg, String tipo) {
      //prima ne aggiungo uno per l'ndg cliente
      soggettiCollegati.add(new SoggettoCollegato(this.ndg, tipo, false, Date.today()));
      //poi ne aggiungo uno per l'altro
      soggettiCollegati.add(new SoggettoCollegato(Long.valueOf(ndg), tipo, true, null));
    }
  }

  //stub

  public class DatiBilancio {
    public Integer numeroDomande;
    public Integer codiceModulo;
    public String descrizioneModulo;
    public Long dataUltimaVariazioneModulo;
    public Long ndgOperatoreUltimaVariazione;
    public String intestazioneNdgModulo;
    public DatiDomande datiDomande;
  }

  public class DatiDomande {
    public Domanda[] domanda;
  }

  public class Domanda {
    public Integer codiceDatoDomanda;
    public String risposta;
    public Integer progressivoDato;
    public String formatoInputCampo;
    public String segno;
    public Integer lunghezza;
    public Integer lunghezzaDecimale;
    public Integer numMaxRipetizioni;
    public String obbligatorioFacoltativo;
    public String numeroAccettatoZero;
    public String totale;
    public String layoutCampo;
    public String formatoOutputCampo;
    public String minuscole;
    public String digitabile;
    public String domanda;
    public DatiLayout datiLayout;
  }

  public class DatiLayout {
    public String tipoLayout;
    public Layout[] layout;
  }

  public class Layout {
    public String risposta;
    public String valoreRisposta;
    public String rispostaAttiva;
  }

  public class RequestDati {
    public RequestDato[] requestDato;
  }

  public class RequestDato {
    public String tipoOperazione;
    public Integer codice;
    public String valore;
    public String progressivo;

  }

  public class Rapporto {
    public Integer servizio;
    public Integer filiale;
    public Long conto;
    public String flagEstinto;
  }

  public class ElementoNdg {
    public Long ndg;
    public String capoRete;
    public String delegato;
    public String descrizione;
    public String descrizioneColl;
    public String tipoRuolo;
    public String tipo;
    public Rapporto rapporto;
    public Long dataAccensione;
    public Long dataUltimaVariazione;
    public String collegamentoAttivo;

    public ElementoNdg() {}

    public ElementoNdg(String ndg, Boolean isCapoRete) {
      this.ndg = Long.valueOf(ndg);
      this.capoRete = isCapoRete ? 'S' : 'N';
    }
  }

  public class TabellaNdg {
    public Long[] codice;

    public TabellaNdg() {
      this.codice = new Long[] {};
    }
  }

  public class Elemento {
    public Long ndg;
    public String capoRete;
    public String delegato;
    public String descrizioneColl;
    public String tipoRuolo;
    public String tipo;
    public String rapporto;
    public Long dataAccensione;
    public Long dataUltimaVariazione;
  }

  public class NaturaGiuridica {  //censimento anagrafico excel: si chiamano "naturaGiuridica"Nome.....
    public String nome;
    public String codice;
    public String descrizione;

    public NaturaGiuridica() {}

    public NaturaGiuridica(String nome, String codice, String descrizione) {
      this.nome = nome;
      this.codice = codice;
      this.descrizione = descrizione;
    }
  }

  public class NaturaGiuridica2 {
    public String naturaGiuridicaNome;
    public String naturaGiuridicaCodice;
  }

  public class IntestazioneDati {
    public String cognome;
    public String nome;
    public String attivita;

    public IntestazioneDati() {}

    public IntestazioneDati(String attivita, String nome, String cognome) {
      this.nome = nome;
      this.cognome = cognome;
      this.attivita = attivita;
    }
  }

  public class Documento {
    public String codiceTipo;
    public String descrizioneTipo;
    public String numero;
    public Long data;
    public String ente;
  }

  public class AttivitaEcononica {
    public Integer cae;
    public Integer sae;
    public Integer rae;
    public String descrizioneCAE;
    public String descrizioneSAE;
    public String descrizioneRAE;

    public AttivitaEcononica() {}

    public AttivitaEcononica(String sae, String rae, String cae) {
      this.sae = sae != null ? Integer.valueOf(sae) : null;
      this.rae = rae != null ? Integer.valueOf(rae) : null;
      this.cae = cae != null ? Integer.valueOf(cae) : null;
    }
  }

  public class SoggettoCollegato {
    public String naturaCollegamento;
    public String tipoRete;
    public Long ndg;
    public String flagNdgCaporete;
    public String descrizione;
    public Long rapportoDiEvidenza;
    public Long dtaAccensione;

    public SoggettoCollegato(Long ndg, String tipo, Boolean isCapoRete, Date d) {
      this.ndg = ndg;
      this.tipoRete = tipo;
      this.descrizione = collTipoMap.get(tipo);
      this.flagNdgCaporete = isCapoRete ? 'S' : 'N';
      this.rapportoDiEvidenza = collRappMap.get(tipo);
      if (d != null) {
        this.dtaAccensione = UDate.getLongValue(d);
      }
    }
  }

  public class InfoNascita {
    public Long data;
    public String luogo;
    public String provincia;
    public String localita;
  }

  public class Via {
    public String tipo;
    public String nome;
    public String numeroDomicilio;

    public String getViaCompleta() {
      return UtilAnagrafiche.getIndirizzoCompleto(tipo, nome, numeroDomicilio);
    }
  }

  public class Via2 {
    public String tipo;
    public String nome;
    public String numero;

    public String getViaCompleta() {
      return UtilAnagrafiche.getIndirizzoCompleto(tipo, nome, numero);
    }
  }

  public class DomiciliazioneAmministrativa {
    public String descrizione;
    public Indirizzo3 indirizzo;
    public String indicativo;

    public DomiciliazioneAmministrativa() {}

    public DomiciliazioneAmministrativa(
      String streetName,
      String streetNumber,
      String streetType,
      String postalCode,
      String city,
      String province
    ) {
      this.indirizzo = new Indirizzo3();
      this.indirizzo.via = new Via2();
      this.indirizzo.via.tipo = streetType;
      this.indirizzo.via.nome = streetName;
      this.indirizzo.via.numero = streetNumber;
      this.indirizzo.cap = postalCode != null ? Integer.valueOf(postalCode) : null;
      this.indirizzo.comune = city;
      this.indirizzo.provincia = province;

      //public String localita;
    }
  }

  public class DomiciliazioneAmministrativa2 {
    public String descrizione;
    public Indirizzo indirizzo;
    public String indicativo;

    public DomiciliazioneAmministrativa2() {
      this.indirizzo = new Indirizzo();
    }
  }

  public class DomiciliazioneAmministrativa4 {
    public Integer indicativo;
  }

  public class Indirizzo {
    public Via via;
    public String localita;
    public Integer cap;
    public String comune;
    public String provincia;

    public Indirizzo() {
      this.via = new Via();
    }
  }

  public class Indirizzo2 {
    public Via2 indirizzo;
    public String localita;
    public Integer cap;
    public String comune;
    public String provincia;
  }

  public class Indirizzo3 {
    public Via2 via;
    public String localita;
    public Integer cap;
    public String comune;
    public String provincia;

    public Indirizzo3() {
      this.via = new Via2();
    }
  }

  public class Indirizzo4 {
    public String titoloIndirizzo;
    public String descrizioneIndirizzo;
  }

  public class ResidenzaTitolare {
    public Indirizzo indirizzo;
  }

  public class ResidenzaTitolare2 {
    public Indirizzo3 indirizzo;
  }

  public class Telefono {
    public Integer prefisso; //non ha senso che siano interi...
    public Integer numero;

    public String getNumeroCompleto() {
      return numero == null ? null : (prefisso == null ? '' : String.valueOf(prefisso)) + String.valueOf(numero);
    }
  }

  public class Telefono2 {
    public String prefisso;
    public String numero;

    public String getNumeroCompleto() {
      return String.isBlank(numero) ? null : (String.isBlank(prefisso) ? '' : prefisso) + numero;
    }
  }

  public class InfoCCIAA {
    public Long dataIscrizioneLegale;
    public String provinciaSedeLegale;
    public Long numeroIscrizioneLegale;
    public Long dataIscrizioneAmministrativa;
    public String provinciaAmministrativa;
    public Long numeroIscrizioneAmministrativa;
  }

  public class CittadinanzaResidenza {
    public String codiceCittadinanza;
    public String tipoCittadinanza;
    public String codiceResidenza;
    public String descrizioneCittadinanza;
  }

  public class CittadinanzaResidenza2 {
    public Integer codiceCittadinanza;
    public Integer tipoCittadinanza;
    public Integer codiceResidenza;
    public String descrizioneCittadinanza;
  }

  public class Agenzia {
    public Integer codice;
    public String descrizione;
  }

  public class NotaStatus {
    public String codiceLingua;
    public String codiceMoneta;
    public String indicativoFornitore;
  }

  public class TabellaPrivacy {
    public ElementoPrivacy[] elementoPrivacy;
    private Map<String, Boolean> privacyMap;

    public Boolean getPrivacyFlag(String codiceConsenso) {
      if (this.privacyMap == null) {
        this.privacyMap = new Map<String, Boolean>();
        for (ElementoPrivacy e : elementoPrivacy) {
          this.privacyMap.put(String.valueOf(e.codiceDato), 'S' == e.consenso);
        }
      }
      return this.privacyMap.get(codiceConsenso);
    }

    public TabellaPrivacy() {
      this(null);
    }

    public TabellaPrivacy(SObject obj) {
      if (obj == null) return;
      elementoPrivacy = new ElementoPrivacy[] {};
      Datetime dataCompilazioneConsensi = (Datetime) obj.get('DataInserimentoConsensi__c');
      if (dataCompilazioneConsensi != null) {
        elementoPrivacy.add(generaPrivacyFlag(K.CONSENSO_PROFILAZIONE, (Boolean) obj.get('ConsensoAllaProfilazione__c'), dataCompilazioneConsensi));
        elementoPrivacy.add(generaPrivacyFlag(K.CONSENSO_PROD_MKT, (Boolean) obj.get('ConsensoAttivitaPromRicercheMercato__c'), dataCompilazioneConsensi));
        elementoPrivacy.add(generaPrivacyFlag(K.CONSENSO_PROD_TERZI, (Boolean) obj.get('ConsensoAttivitaPromozionaleTerzi__c'), dataCompilazioneConsensi));
        elementoPrivacy.add(generaPrivacyFlag(K.CONSENSO_PROMOZ_MKT, (Boolean) obj.get('ConsensoProdottiBancaRicercheMercato__c'), dataCompilazioneConsensi));
        elementoPrivacy.add(generaPrivacyFlag(K.CONSENSO_PROMOZ_TERZI, (Boolean) obj.get('ConsensoProdottiSocietaTerze__c'), dataCompilazioneConsensi));
        elementoPrivacy.add(generaPrivacyFlag(K.CONSENSO_MOD_TRADIZ, (Boolean) obj.get('ConsensoSoloModalitaTradizionali__c'), dataCompilazioneConsensi));
      }
    }

    private ElementoPrivacy generaPrivacyFlag(String codiceConsenso, Boolean valore, Datetime d) {
      ElementoPrivacy res = new ElementoPrivacy();
      res.agenzia = 0;
      res.consenso = valore == true ? 'S' : 'N';
      res.codiceDato = Integer.valueOf(codiceConsenso);
      res.data = d.getTime();
      return res;
    }
  }

  public class TabellaPrivacy2 {
    public ElementoPrivacy[] elementoPrivacyCompleto;
  }

  public class TabellaPrivacy3 {
    public ElementoPrivacy2[] elementoPrivacy;
  }

  public class ElementoPrivacy {
    public Integer codiceDato;
    public String descrizioneDato;
    public String consenso;
    public Long data;
    public Integer agenzia;
    public String privFi;
  }

  public class ElementoPrivacy2 {
    public Integer codiceDato;
    public String descrizioneDato;
    public String consenso;
    public Long data;
    public String agenzia;
    public String privFi;
  }

  public class DatiAggiuntivi {
    public Integer codiceDato;
    public String valoreCodiceDato;
    public String layout;
    public Integer lunghezzaCodiceDato;
    public Integer numeroDecimaliCodiceDato;
    public String tipoDato;
    public String formatoIn;
    public String formatoOut;
    public String returnCode;
    public String responseCode;
    public String descrizioneErrore;
    public String allineaIntestazione;
  }

  public class DatiAggiuntiComplementari {
    public String DataScadenzaDocumento;
    public String CentraleRischi;
    public String partitaIVA;
    public String codiceProfessione;
      public String UltimaProfesSvolta;
      public String FormaGiurSocAppart;
    public String FlagPep;
    public String numeroAddetti;
    public String ateco;
    public String telefono;
    public String numeroCellulare;
    public String email;
    public String numeroFax;
    //public String elementoPrivacy.data;
    public String FlagAntiterrorismo;
    public String emailPec;
    public String NazioneAttPrev;
    public String ProvAttPrev;
    public String numeroCellulareAlternativo;
    public String CodClassCliente ;
    //public String elementoPrivacy.privFi(1);
    //public String elementoPrivacy.privFi(2);
    //public String elementoPrivacy.privFi(3);
    //public String elementoPrivacy.privFi(4);
    //public String elementoPrivacy.privFi(5);
    //public String elementoPrivacy.privFi(6);
    //public String elementoPrivacy.privFi(7);
    public String CodCompRil;
    public String RatingProfRischio;
    public String CodTitStudio;
    public String DataDecesso;
    public String CodSoggEstero;
    public String DataRifFatt;
    public String ImpFatt;
    public String CodNazCasaMadre;
    public String FlagPepDomestico; //NON UTILIZZATO IN ANAG22
    public String FlagPIL;
    public String codiceTAE;
    public String FlagBloccoAnag;
    public String DescBloccoAnag;
    public String FlagNONpresTitEff;
    public String DataStampaQuestionario;
    public String CentraleRischiAssociativa;
    public String SegmentoB2;
    public String AlboArtigiani;
    public String CodFiscalePrecedente;
    public String CodiceUIFSecondaCittad; //NON UTILIZZATO IN ANAG22
    public String BonificoRipetitivoUSA;
    public String CabNascita;
    public String CabResidenza;
    public String TelefonoInternazionale;
    public String RatingLegalita;
    public String NDGanteMigrazione;
    public String CodFiscaleAde;
    public String ClienteComuneGruppoAss;
    public String ClienteSOS;
    public String ClienteMagistratura;
    public String SettoreLavorativo;
    public String RapportoDiLavoro;
    public String Abitazione;
    public String NumComponentiNucleo;
    public String ProdottoInvestimento1;
    public String ProdottoInvestimento2;
    public String MotivoAssenzaTitolareEff;
    public String TipoDocumIdentita2;
    public String NumeroDocumento2;
    public String DataDocumento2;
    public String LuogoDocumento2;
    public String FilialeDiCompetenza;
    public String CognomeConiuge;
    public String IndirizzoInternet;
    public String IndirizzoInternet2;
    public String PosizioneAnagraficheNegative;
    public String CollegatoPEP;
    public String DataEstinzioneUltRapp;
    public String DataEstinzioneUltCc;
    public String DataAccensioneDefin;
    public String DataAccensionePrimoRapp;
    public String DataAccensioneProvv;
    public String DataCaricamentoInDefin;
    public String DataCaricamentoInProvv;
    public String SoggettoIndagato;
    public String NDGFiduciante;
    public String DataProvvConfisca;
    public String EsitoAccertamento;
    public String PosizionePEP;
    public String SocietaFiduciaria;
    public String CodiceSegmento;
    public String TelefonoDitte;
    public String AttivitaPrevalente;
    public String CensimentoRuoli;
    public String NumRapportiDirettiEstinti;
    public String NumRapportiDirettiInEssere;
    public String NumRapportiIndirettiEstinti;
    public String NumRapportiIndirettiInEssere;
    public String PeriodoSorveglianza;
    public String PosEstero;
    public String ResidenzaFiscaleEstera;
    public String CaiIndirizzo;
    public String CaiCap;
    public String CaiLocalita;
    public String CaiProvincia;
    public String CaiPaese;
    public String SpecieGiuridicaEstera;
    public String ProtezioneAccessiDipendente;
    public String LEI;
    public String SettoreFCEMIR;
    public String ncgEstero; // NON UTILIZZATO IN ANAG22
    public String CodiceIdentificativoEstero; // NON UTILIZZATO IN ANAG22
    public String Eredita;
    public String ProceduraConcorsuale;
    public String SocCostLeggiStraniere;
    public String SAECodificaNuova;
    public String SAEEsteroNuovo;
    public String SocietaQuotBorsa;
    public String DataFondazione;
    public String DataIscrizione;
    public String NazioneCostruzione;
    public String CodiceIban;
    public String ProALBODitteIndiv;
    public String DepositoAlPortatore;
    public String IscrittiALBODitteIndivid;
    public String GestioneBolli;
    public String PrefissoTelCasa;
    public String PrefissoTelAlterativo;
    public String IndicativoSorveglianza;
    public String PrefissoCell1;
    public String PrefissoCell2;
    public String MiniIntestazione1;
    public String MiniIntestazione2;
    public String NDGSettorialeEstero;
    public String CodFiscaleEstero;
    public String CodiceCorrEstero;
    public String CodiceSWIFT;
    public String TipoClienteFATCA;
    public String CodiceFiscalePrimaResidenzaFATCA;
    public String DatiDocFATCA;
    public String FATCADichiarazCittadinanzaUS;
    public String FATCADichiarazResidenzaUS;
    public String PosizioneFATCA;
    public String CodiceFiscaleSecondaResidenzaFATCA;
    public String CodiceFiscaleTerzaResidenzaFATCA;
    public String PrimaResidenzaFATCA;
    public String SecondaResidenzaFATCA;
    public String TerzaResidenzaFATCA;
    public String QuartaResidenzaFATCA;
    public String QuintaResidenzaFATCA;
    public String CodiceFiscaleQuartaResidenzaFATCA;
    public String CodiceFiscaleQuintaResidenzaFATCA;
    public String FACTAEntity;
    public String FACTAGIIN;
    public String TerzaCittadinanzaFATCA;
    public String Note2CodFiscFATCA;
    public String Note3CodFiscFATCA;
    public String Note4CodFiscFATCA;
    public String TrasparenzaFiscale;
    public String PosizioneCRS;
    public String EntityCRS;
    public String DatiDocumento02CRS;
    public String Note5CodFiscFATCA;
    public String DocAggiuntivoFATCA;
    public String ClienteIndesiderato;
  }

  public class StatusElemento {
    public String sAEAlternativo;
    public Integer rAEAlternativo;
    public Integer indicativoMarketing;
  }

  public class Fatturazione {
    public Integer indicativo;
    public Integer periodicita;
  }

  public class Titolo {
    public String codice;
    public String descrizioneBreve;
    public String descrizione;
  }

  public class FlagGenerici {
    public String FlagOperatore;
  }

  public class Anagrafiche {
    public Anagrafica[] anagrafica;
  }

  public class Anagrafica {
    public Long ndg;
    public String denominazione;
    public String tipologia;
    public String segmento;
    public Integer agenzia;
    public Agenzia gestore;
    public Telefono telefono;
    public String numeroCellulare;
    public String codiceFiscale;
    public String sesso;
    public Indirizzo2 residenzaLegale;
    public String nazione;
    public Long dataDiNascita;
    public String luogoDiNascita;
    public String email;
    public String emailPec;
    public String sitoInternet;

    public String getFormaGiuridica() {
      Boolean isCf = (
        String.isNotBlank(codiceFiscale) &&
        codiceFiscale.length() == 16 &&
        codiceFiscale.substring(0, 6).isAlpha()
      );

      return tipologia == IMPRESA && isCf ? DITTA_INDIVIDUALE : tipologia;
    }

    public Boolean isAzienda() {
      return tipologia == IMPRESA;
    }

    public Boolean isPersonaFisica() {
      return tipologia == PRIVATO;
    }

    public Boolean isCointestazione() {
      return String.isBlank(codiceFiscale);
    }
  }

  //metto virtual per estenderlo in RestAnagrafeCrm
  public virtual class DatiAnagraficiCedacri {
    public Decimal codiceIstituto3N; //serve per servizio inbound
    public Long ndg;
    public String codiceFiscale;
    public String sesso;
    public NaturaGiuridica naturaGiuridica;
    public IntestazioneDati intestazione;
    public Integer numeroCointestatari;
    public String codiceStatoCivile;
    public String descrizioneStatoCivile;
    public InfoNascita infoNascita;
    public Indirizzo3 residenzaLegale;
    public DomiciliazioneAmministrativa domiciliazioneAmministrativa;
    public Documento documento;
    public AttivitaEcononica attivitaEcononica;
    public Telefono2 telefono;
    public InfoCCIAA infoCCIAA;
    public CittadinanzaResidenza cittadinanzaResidenza;
    public Agenzia agenzia;
    public StatusElemento statusElemento;
    public String descrizioneSAEAlternativo;
    public String descrizioneRAEAlternativo;
    public String descrizioneResidenzaValutaria;
    public String descrizioneIndicativoSocio;
    public String descrizioneTipoGruppo;
    public String descrizioneIndicativoMarketing;
    public NotaStatus notaStatus;
    public String descrizoneLingua;
    public Integer codiceABI;
    public Fatturazione fatturazione;
    public Integer matricolaFunzionario;
    public Long dataCensimento;
    public Long dataUltimaVariazioneAnagrafica;
    // public ResidenzaTitolare residenzaTitolare;
    // MB - TEN: richiesto cambio da ITEC per gestione campo "numero" di "via" del nodo "indirizzo"
    public ResidenzaTitolare2 residenzaTitolare;
    public Long centraleRischi;
    public String partitaIVA;
    public String numeroCellulare;
    public String email;
    public String numeroFax;
    public String ateco;
    public String descrizioneAteco;
    public TabellaPrivacy tabellaPrivacy;
    public String numeroCellulareAlternativo;
    public String emailAlternativo;
    public String numeroTelefonoAlternativo;
    public String sitoInternet;
    public String codiceProfessione;
    public String descrizioneProfessione;
      public String UltimaProfesSvolta;
      public String FormaGiurSocAppart;
    public Long dataScadenzaDocumento;
    public String numeroAddetti;
    public String flagClientePotenziale;
    public String codiceAppellativo;
    public String descrizioneAppellativo;
    public Titolo titoloNonAccademico;
    public Titolo titoloAccademico;
    public Integer tipoDipendente;
    public String descrizioneTipoDipendente;
    public Integer matricolaDipendente;
    public Integer indicativoCapoConvenzione;
    public Integer codiceConvenzione;
    public Integer indicativoCapoGruppo;
    public Integer codiceGruppo;
    public String codiceSegmento;
    public String datiAggiuntiObbligatori;
    public DatiAggiuntivi[] datiAggiuntivi; //NON UTILIZZATO IN ANAG22
    public DatiAggiuntiComplementari datiAggiuntiviComplementari;
    public String allineaIntestazione;
    public String indicativoNormalizzazioneResidenza;
    public String esitoNormalizzazioneResidenza;
    public String indicativoNormalizzazioneDomicilio;
    public String esitoNormalizzazioneDomicilio;
    public String indicativoSocietaConstituenda;
    public String codiceTAE;
    public String descrizioneTAE;
    public String flagValidazione;
    public Long ndgOperatore;
    public String intestazioneOperatore;
    public Long dataUltimaVariazione;
    public FlagGenerici flagGenerici;
    public Long ndgOperatorePws;
    public String moduloAdobe;
    public String intestazioneAnagrafica;
    public String statusAnagrafico1;
    public String statusAnagrafico2;
    public String reteAssociataNaturaGiuridica;
    public String filialeMadre;
    public String forzatura;
      public String paeseCasaMadre;
      public String paeseSvolgimentoAttivitaPrevalente;
      public String paeseRelazioni1;
      public String paeseRelazioni2;
      public String paeseRelazioni3;

    public Boolean isPersonaFisica() {
      return naturaGiuridica != null && naturaGiuridica.descrizione == NATURAGIURIDICA_PF;
    }
  }

  public class DatiAnagraficiCedacri2 {
    public Long ndg;
    public String codiceFiscale;
    public NaturaGiuridica naturaGiuridica;     // censimento anagrafico excel: guarda classe
    public String naturaGiuridicaDescrizione; // serve? è in censimento anagrafico excel ma non in json
    public IntestazioneDati intestazione;       //in "censimento anagrafico exel" si chiama: 10 intestazioneDati
    public Integer numeroCointestatari;
    public String codiceStatoCivile;
    public String descrizioneStatoCivile;
    public InfoNascita infoNascita;
    public Indirizzo residenzaLegale;
    public DomiciliazioneAmministrativa2 domiciliazioneAmministrativa;
    public Documento documento;
    public AttivitaEcononica attivitaEcononica;
    public Telefono telefono;
    public InfoCCIAA infoCCIAA;
    public CittadinanzaResidenza cittadinanzaResidenza;
    public Agenzia agenzia;
    public StatusElemento statusElemento;
    public String descrizioneSAEAlternativo;
    public String descrizioneRAEAlternativo;
    public String descrizioneResidenzaValutaria;
    public String descrizioneIndicativoSocio;
    public String descrizioneTipoGruppo;
    public String descrizioneIndicativoMarketing;
    public NotaStatus notaStatus;
    public String descrizoneLingua;
    public Integer codiceABI;
    public Fatturazione fatturazione;
    public Integer matricolaFunzionario; //censimento anagrafico json: si chiama "matricolaFunzionario" anzichè "matricola"
    public Long dataCensimento;
    public Long dataUltimaVariazioneAnagrafe; //censimento anagrafico json: si chiama "dataUltimaVariazioneAnagrafe" anzichè "dataUltimaVariazioneAnagrafica"
    public ResidenzaTitolare residenzaTitolare;
    public Long centraleRischi;
    public String partitaIVA;
    public String numeroCellulare;
    public String email;
    public String numeroFax;
    public String ateco;
    public String descrizioneAteco;
    public TabellaPrivacy2 tabellaPrivacy; //censimento anagrafico json: la tabella contiene una lista di "elementoPrivacyCompleto", ho creato quindi la nuova classe TabPriv2
    public String numeroCellulareAlternativo;
    public String emailAlternativo;
    public String numeroTelefonoAlternativo;
    public String sitoInternet;
    public String codiceProfessione;
    public String descrizioneProfessione;
      public String UltimaProfesSvolta;
      public String FormaGiurSocAppart;
    public Long dataScadenzaDocumento;
    public String numeroAddetti;
    public String flagClientePotenziale;
    public String codiceAppellativo;
    public String descrizioneAppellativo;
    public Titolo titoloNonAccademico;
    public Titolo titoloAccademico;
    public Integer tipoDipendente; //censimento anagrafico json: string?
    public String descrizioneTipoDipendente; //in json c'è..in exel?
    public Integer matricolaDipendente;
    public Integer indicativoCapoConvenzione;
    public Integer codiceConvenzione;
    public Integer indicativoCapoGruppo;
    public Integer codiceGruppo;
    public String codiceSegmento;
    public String tipo;
    public String datiAggiuntiObbligatori;
    public DatiAggiuntivi[] datiAggiuntivi;
    public String indicativoNormalizzazioneResidenza;
    public String esitoNormalizzazioneResidenza;
    public String indicativoNormalizzazioneDomicilio;
    public String esitoNormalizzazioneDomicilio;
    public String indicativoSocietaConstituenda;
    public String codiceTAE;
    public String descrizioneTAE;
    public String flagValidazione;
    public Long ndgOperatore;
    public String intestazioneOperatore;
    public Long dataUltimaVariazione;
    public FlagGenerici flagGenerici;
    public Long ndgOperatorePws;
    public String moduloAdobe;
    // public String intestazioneAnagrafica; // questo è nell'excel, ma nel json c'è "intestazioneCliente", come sotto
    public String intestazioneCliente;
    public String statusAnagrafico1;
    public String statusAnagrafico2;
    public String reteAssociataNaturaGiuridica;
    public String filialeMadre;
      
      public String paeseCasaMadre;
      public String paeseSvolgimentoAttivitaPrevalente;
      public String paeseRelazioni1;
      public String paeseRelazioni2;
      public String paeseRelazioni3;
  }

  public class DatiAnagraficiCedacri3 {
    public Long ndg;
    public String codiceFiscale;
    public NaturaGiuridica2 naturaGiuridica;
    public String naturaGiuridicaDescrizione;
    public IntestazioneDati intestazioneDati;
    public Integer numeroCointestatari;
    public String codiceStatoCivile;
    public String descrizioneStatoCivile;
    public InfoNascita infoNascita;
    public Indirizzo residenzaLegale;
    public DomiciliazioneAmministrativa4 domiciliazioneAmministrativa;
    public Documento documento;
    public AttivitaEcononica attEcon;
    public Telefono2 telefono;
    public InfoCCIAA infoCCIAA;
    public CittadinanzaResidenza2 cittadinanzaResidenza;
    public Agenzia agenzia;
    public StatusElemento statusElemento;
    public String descrizioneSAEAlternativo;
    public String descrizioneRAEAlternativo;
    public String descrizioneResidenzaValutaria;
    public String descrizioneIndicativoSocio;
    public String descrizioneTipoGruppo;
    public String descrizioneIndicativoMarketing;
    public NotaStatus notaStatus;
    public String descrizoneLingua;
    public Integer codiceABI;
    public Fatturazione fatturazione;
    public Integer matricolaFunzionario;
    public Long dataCensimento;
    public Long dataUltimaVariazioneAnagrafica;
    public ResidenzaTitolare2 residenzaTitolare;
    public Long centraleRischi;
    public String partitaIVA;
    public String numeroCellulare;
    public String email;
    public String numeroFax;
    public String ateco;
    public String descrizioneAteco;
    public TabellaPrivacy3 tabellaPrivacy;
    public String numeroCellulareAlternativo;
    public String emailAlternativo;
    public String numeroTelefonoAlternativo;
    public String sitoInternet;
    public String codiceProfessione;
    public String descrizioneProfessione;
      public String UltimaProfesSvolta;
      public String FormaGiurSocAppart;
    public Long dataScadenzaDocumento;
    public String numeroAddetti;
    public String flagClientePotenziale;
    public String codiceAppellativo;
    public String descrizioneAppellativo;
    public Titolo titoloNonAccademico;
    public Titolo titoloAccademico;
    public Integer matricolaDipendente;
    public Integer indicativoCapoConvenzione;
    public Integer codiceConvenzione;
    public Integer indicativoCapoGruppo;
    public Integer codiceGruppo;
    public String codiceSegmento;
    public String tipo;
    public String datiAggiuntiObbligatori;
    public DatiAggiuntivi[] datiAggiuntivi;
    public String indicativoNormalizzazioneResidenza;
    public String esitoNormalizzazioneResidenza;
    public String indicativoNormalizzazioneDomicilio;
    public String esitoNormalizzazioneDomicilio;
    public String indicativoSocietaConstituenda;
    public String codiceTAE;
    public String descrizioneTAE;
    public String flagValidazione;
    public Long ndgOperatore;
    public String intestazioneOperatore;
    public Long dataUltimaVariazione;
    public FlagGenerici flagGenerici;
    public Long ndgOperatorePws;
    public String moduloAdobe;
    public String intestazioneAnagrafica;
    public String statusAnagrafico1;
    public String statusAnagrafico2;
    public String reteAssociataNaturaGiuridica;
    public String filialeMadre;
    public TabellaPrivacy2 tabellaPrivacyCompleto;
      
      public String paeseCasaMadre;
      public String paeseSvolgimentoAttivitaPrevalente;
      public String paeseRelazioni1;
      public String paeseRelazioni2;
      public String paeseRelazioni3;
  }

  public class DatiAnagraficiIntegrazione {
    public Long ndg;
    public String codiceFiscale;
    public NaturaGiuridica naturaGiuridica;
    public IntestazioneDati intestazione;
    public Integer numeroCointestatari;
    public String codiceStatoCivile;
    public String descrizioneStatoCivile;
    public InfoNascita infoNascita;
    public Indirizzo3 residenzaLegale;
    public DomiciliazioneAmministrativa domiciliazioneAmministrativa;
    public Documento documento;
    public AttivitaEcononica attivitaEcononica;
    public Telefono telefono;
    public InfoCCIAA infoCCIAA;
    public CittadinanzaResidenza cittadinanzaResidenza;
    public Agenzia agenzia;
    public StatusElemento statusElemento;
    public String descrizioneSAEAlternativo;
    public String descrizioneRAEAlternativo;
    public String descrizioneResidenzaValutaria;
    public String descrizioneIndicativoSocio;
    public String descrizioneTipoGruppo;
    public String descrizioneIndicativoMarketing;
    public NotaStatus notaStatus;
    public String descrizoneLingua;
    public Integer codiceABI;
    public Fatturazione fatturazione;
    public Integer matricolaFunzionario;
    public Long dataCensimento;
    public Long dataUltimaVariazioneAnagrafe;
    public ResidenzaTitolare residenzaTitolare;
    public Long centraleRischi;
    public String partitaIVA;
    public String numeroCellulare;
    public String email;
    public String numeroFax;
    public String ateco;
    public String descrizioneAteco;
    public TabellaPrivacy tabellaPrivacy;
    public String numeroCellulareAlternativo;
    public String emailAlternativo;
    public String numeroTelefonoAlternativo;
    public String sitoInternet;
    public String codiceProfessione;
    public String descrizioneProfessione;
      public String UltimaProfesSvolta;
      public String FormaGiurSocAppart;
    public Long dataScadenzaDocumento;
    public String numeroAddetti;
    public String flagClientePotenziale;
    public String codiceAppellativo;
    public String descrizioneAppellativo;
    public Titolo titoloNonAccademico;
    public Titolo titoloAccademico;
    public String tipoDipendente;
    public String descrizioneTipoDipendente;
    public Integer matricolaDipendente;
    public Integer indicativoCapoConvenzione;
    public Integer codiceConvenzione;
    public Integer indicativoCapoGruppo;
    public Integer codiceGruppo;
    public String codiceSegmento;
    public String datiAggiuntiObbligatori;
    public DatiAggiuntivi[] datiAggiuntivi;
    public String indicativoNormalizzazioneResidenza;
    public String esitoNormalizzazioneResidenza;
    public String indicativoNormalizzazioneDomicilio;
    public String esitoNormalizzazioneDomicilio;
    public String indicativoSocietaConstituenda;
    public String codiceTAE;
    public String descrizioneTAE;
    public String flagValidazione;
    public Long ndgOperatore;
    public String intestazioneOperatore;
    public Long dataUltimaVariazione;
    public FlagGenerici flagGenerici;
    public Long ndgOperatorePws;
    public String moduloAdobe;
    public String intestazioneCliente;
    public String statusAnagrafico1;
    public String statusAnagrafico2;
    public String reteAssociataNaturaGiuridica;
    public String filialeMadre;
    public Esito esitoGenerale;
    public Esito esitoVariazione;

    public DatiAnagraficiIntegrazione() {}
  }

  public class Esito {
    public String esito;
    public String descrizione;
    public String nomeCampo;
  }

  public class GestioneCollNdg {
    public ElementoNdg[] elementi;
    public Integer sae;
    public Integer rae;
    public Long ndgSCO;
    public TabellaIntestazione[] tabellaIntestazione;
    public Indirizzo domicilio;
    public String tipoOperatore;
    public Rapporto rapporto;
    public ElementoNdg[] datiNdgOut;

    public ElementoNdg[] getCointestazioneList() {
      ElementoNdg[] result = new ElementoNdg[] {};
      if (elementi != null) {
        for (ElementoNdg el : elementi) {
          if (el.tipo == COLLNDG_COINTESTAZIONE) {
            result.add(el);
          }
        }
      }
      return result;
    }

    public String getCointestazioneCapoReteNdg() {
      for (ElementoNdg el : getCointestazioneList()) {
        if (el.capoRete == 'S') {
          return String.valueOf(el.ndg);
        }
      }
      return null;
    }
  }

  public class TabellaIntestazione {
    public String intestazione;
  }

  public class ElencoRapporti {
    public Integer recordTotali;
    public Integer rapportiEstratti;
    public Integer rapportiEstinti;
    public Integer rapportiInEssere;
    public TabellaIndirizzi tabellaIndirizzi;
    public TabellaIndirizziDelNominativo tabellaIndirizziDelNominativo;
    public TabellaRapporti tabellaRapporti;
  }

  public class TabellaIndirizzi {
    public String[] indirizzo; //in excel è indirizzoNdg
  }

  public class TabellaIndirizziDelNominativo {
    public Indirizzo4[] Indirizzo;
  }

  public class TabellaRapporti {
    public ElemTabellaRapporti elemTabellaRapporti;
  }

  public class ElemTabellaRapporti {
    public String tipoOperativita;
    public String flagEstinto;
    public String codiceRapportoNonNumerico;
    public DatiRapporto datiRapporto;
    public String categoriaSottocategoria;
    public String descrizioneCategSottocateg;
    public String flagc90TitoloTipoRapporto;
    public String c90TitoloTipoRapporto;
    public String flagc91TitoloTipoRapporto;
    public String c91TitoloTipoRapporto;
    public Long dataAccesione;
    public Long dataVariazione;
    public String flagIndirizzoPersonale;
    public TabellaIndirizzi tabellaIndirizziRapporto;
    public TabellaIndirizziDelNominativo tabellaIndirizziDelRapporto;
    public String flagRapportoPersonale;
    public Double saldo;
    public String programmaDiAggiornamento;
    public String descrizioneSaldo;
    public String codiceBox;
    public String flagBox;
  }

  public class DatiRapporto {
    public Integer servizio;
    public Integer filiale;
    public Long conto;
  }

  public class ModificaDatiAggiuntiviQQ {
    public String esitoGlobale;
    public Long dataAggiornamento;
    public EsitoOperazioniDati esitoOperazioniDati;
  }

  public class EsitoOperazioniDati {
    public EsitoOperazioneDato[] esitoOperazioneDato;
  }

  public class EsitoOperazioneDato {
    public String tipoOperazione;
    public Integer codice;
    public String valore;
    public String esito;
    public String messaggioErrore;
  }

  public class RetiAnagrafichePayload {
    public String ledger;
    public String result;
    public String message;

    public Boolean isCorrect() {
      return result != SETRETIANAGRAFICHE_ERROR;
    }
  }

  //response 1
  public class ElencoRapportiResponse extends WsRestInput.CommonResponse {
    public ElencoRapporti payload;

    public override Boolean isCorrect() {
      return payload != null;
    }
  }

  public class DatiBilancioResponse extends WsRestInput.CommonResponse {
    public DatiBilancio payload;

    public override Boolean isCorrect() {
      return payload != null;
    }
  }

  public class ModificaDatiAggiuntiviQQResponse extends WsRestInput.CommonResponse {
    public ModificaDatiAggiuntiviQQ payload;

    public override Boolean isCorrect() {
      return payload != null;
    }
  }

  public class SearchAnagraficaRes extends WsRestInput.CommonResponse {
    public Anagrafiche payload;

    public override Boolean isCorrect() {
      return payload != null && payload.anagrafica != null;
    }

    public Anagrafica[] getAnagrafica(String tipo) {
      if(tipo == 'pf') return getPersoneFisiche();
      else if(tipo == 'pg') return getAziende();
      else return null;
    }

    public Anagrafica[] getAziende() {
      if(!isCorrect()) return new Anagrafica[]{};
      Anagrafica[] res = new Anagrafica[]{};
      for(Anagrafica a : payload.anagrafica) {
        if(a.isAzienda()) res.add(a);
      }
      return res;
    }

    public Anagrafica[] getPersoneFisiche() {
      if(!isCorrect()) return new Anagrafica[]{};
      Anagrafica[] res = new Anagrafica[]{};
      for(Anagrafica a : payload.anagrafica) {
        if(a.isPersonaFisica()) res.add(a);
      }
      return res;
    }
  }

  //response getdatianagraficicedacri
  public class GetAnagraficaRes extends WsRestInput.CommonResponse {
    public DatiAnagraficiCedacri payload;

    public override Boolean isCorrect() {
      return payload != null;
    }
  }

  //response setanagraficalight
  public class CensimentoLightRes extends WsRestInput.CommonResponse {
    public DatiAnagraficiCedacri2 payload;

    public override Boolean isCorrect() {
      return payload != null && payload.ndg != null;
    }
  }

  public class GestioneCollNdgResponse extends WsRestInput.CommonResponse {
    public GestioneCollNdg payload;

    public override Boolean isCorrect() {
      return payload != null;
    }

    public String[] getElementi(String ndgPadre) {
      String[] res = new String[]{};
      if(payload.elementi == null) return res;
      for(ElementoNdg e : payload.elementi) {
        if(e.ndg != null && String.valueOf(e.ndg) != ndgPadre) res.add(String.valueOf(e.ndg));
      }
      return res;
    }
  }

  public class CensimentoFullRes extends WsRestInput.CommonResponse {
    public DatiAnagraficiCedacri3 payload;

    public override Boolean isCorrect() {
      return payload != null && payload.ndg != null;
    }
  }

  public class VariazioneRes extends WsRestInput.CommonResponse {
    public DatiAnagraficiIntegrazione payload;

    public override Boolean isCorrect() {
      return payload != null && payload.esitoGenerale != null && payload.esitoGenerale.esito == 'OK';
    }

    public override String getErrors() {
      String[] errors = new String[] {};
      if (headers != null && headers.headers != null && headers.headers.error_header != null && headers.headers.error_header.archErrorList != null) {
        for (Error e : headers.headers.error_header.archErrorList) {
          String parsedError = this.parseError(e.description);
          if (String.isNotBlank(parsedError)) {
            errors.add(parsedError);
          }
        }
      }
      if (String.isNotBlank(exceptionError)) {
        errors.add(exceptionError);
      }

      if (payload != null && payload.esitoGenerale != null && payload.esitoGenerale.esito == 'KO') {
        errors.add(payload.esitoGenerale.esito + ' - ' + payload.esitoGenerale.descrizione);
      }

      return String.join(errors, ', ');
    }
  }

  public class SetRetiAnagraficheIfisResponse extends WsRestInput.CommonResponse {
    public RetiAnagrafichePayload[] payload;

    public override Boolean isCorrect() {
      if (payload != null && !payload.isEmpty()) {
        for (RetiAnagrafichePayload p : payload) {
          if (!p.isCorrect()) {
            return false;
          }
        }
      } else {
        return false;
      }
      return true;
    }
  }
}