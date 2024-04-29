public without sharing class WsRestRibes {

  //A.M. Sostituzione Infoprovider RIBES -> CERVED
  public final static String RIBES = 'Cerved';

  /**
   * RIBES 04
   * Il metodo interroga i web service esposti da Ribes per restituire i dati informativi generali per tutte le
   * aziende in archivio rispondenti ai criteri di ricerca impostati
   * @param  denominazione
   * @param  cf
   * @param  provincia
   * @return
   */
  public static GetListaAziendeResponse getListaAziende(String denominazione, String cf, String provincia) {
    if (String.isBlank(denominazione) && String.isBlank(cf)) {
      throw new Ex.RibesInputException('Denominazione o codice fiscale mancanti');
    }

    GetListaAziendeInput input = new GetListaAziendeInput();
    input.denominazione = denominazione;
    input.codiceFiscale = cf;
    input.provincia = provincia;

    return (GetListaAziendeResponse) WsRestUtils.callService(
      'URLGetListaAziendeRibes__c',
      input,
      GetListaAziendeResponse.class
    );
  }

  /**
   * RIBES 05
   * @param  rea   REA
   * @param  cciaa Numero di iscrizione alla CCIAA
   * @return
   */
  public static GetInformazioniPGResponse getInformazioniPG(String rea, String cciaa) {
    if (String.isBlank(rea) || String.isBlank(cciaa)) {
      throw new Ex.RibesInputException('Numero REA o provincia CCIAA mancanti');
    }

    InformazioniPGInput input = new InformazioniPGInput();
    input.nRea = rea;
    input.cciaa = cciaa;

    return (GetInformazioniPGResponse) WsRestUtils.callServiceSpecialRibes(
      'URLGetInformazioniPGRibes__c',
      input,
      GetInformazioniPGResponse.class
    );
  }

  /**
   * RIBES 08
   * Il metodo interroga i web service esposti da Ribes per restituire gli eventi negativi in carico ad un’azienda
   * @param  rea   REA
   * @param  cciaa Numero di iscrizione alla CCIAA
   * @return
   */
   //A.M. 25/03/21 Modifica Infoprovider RIBES -> CERVED (TicketId alafanumerico)
   //public static GetEventiNegativiResponse getEventiNegativi(String rea, String cciaa, String tipoRisposta, String formato, Long sourceIdRequest, String ndg) {
    public static GetEventiNegativiResponse getEventiNegativi(String rea, String cciaa, String tipoRisposta, String formato, String sourceIdRequest, String ndg) {
	if (String.isBlank(rea) || String.isBlank(cciaa)) {
      throw new Ex.RibesInputException('Numero REA o codice CCIAA mancanti');
    }

    return (GetEventiNegativiResponse) WsRestUtils.callServiceSpecialEventiNegativi(
      'URLGetEventiNegativiRibes__c',
      new GetEventiNegativiInput(rea, cciaa, tipoRisposta, formato, sourceIdRequest, ndg),
      GetEventiNegativiResponse.class
    );
  }

  /**
   * RIBES 06
   * @param  cf    codice fiscale
   * @param  accId id account
   * @return
   */
  public static GetBilancioSinteticoResponse getBilancioSintetico(String cf, Id accId) {
    if (String.isBlank(cf)) {
      throw new Ex.RibesInputException('Codice fiscale per bilancio sintetico mancante');
    }

    GetBilancioSinteticoInput input = new GetBilancioSinteticoInput();
    input.codiceFiscale = cf;

    System.debug('SV INPUT: ' + input);

    return (GetBilancioSinteticoResponse) WsRestUtils.callService(
      'URLGetBilancioSinteticoRibes__c',
      input,
      GetBilancioSinteticoResponse.class
    );
  }

  //stub
  public class GetListaAziendeInput {
    public String codiceProdotto = 'BICLISAZ';
    public String tipo = 'PRD';
    public String formato = 'FLD';
    public String denominazione;
    public String provincia;
    public String codiceFiscale;
    public String cciaa;
    public String nRea;
    public String codiceAnagraficaCliente;
  }

  public class InformazioniPGInput {
    public String codiceProdotto = 'BICRGTEB'; //BICVW???
    public String tipo = 'PRD';
    public String formato = 'XML';
    public String tipoRichiesta = 'RP';
    public String cciaa;
    public String nrea;
    public String codiceAnagraficaCliente;
  }

  public class GetEventiNegativiInput {
    public String tipoRisposta;
    public Servizio servizio;

    //A.M. 25/03/21 Modifica Infoprovider RIBES -> CERVED (TicketId alafanumerico)
	//public GetEventiNegativiInput(String rea, String cciaa, String tipoRisposta, String formato, Long sourceIdRequest, String ndg) {
    public GetEventiNegativiInput(String rea, String cciaa, String tipoRisposta, String formato, String sourceIdRequest, String ndg) {
	  this.tipoRisposta = tipoRisposta;
      this.servizio = new Servizio();
      this.servizio.eventiNegativi = new EventiNegativi();
      this.servizio.eventiNegativi.prodottoAziendeIscritte = new ProdottoAziendeIscritte();
      this.servizio.eventiNegativi.prodottoAziendeIscritte.nrea = rea;
      this.servizio.eventiNegativi.prodottoAziendeIscritte.cciaa = cciaa;
      this.servizio.eventiNegativi.prodottoAziendeIscritte.formato = formato;
      this.servizio.eventiNegativi.prodottoAziendeIscritte.sourceIdRequest = sourceIdRequest != null ? String.valueOf(sourceIdRequest) : null;
      this.servizio.eventiNegativi.prodottoAziendeIscritte.codiceAnagraficaCliente = ndg;

    }
  }

  public class GetBilancioSinteticoInput extends WsRestInput.CommonInput {
    public String codiceFiscale;

    public GetBilancioSinteticoInput() {
      //da sviluppatore consapevole a sviluppatore rassegnato: passo questo valori perché sì
      //sembra che se non trova un CF per il bilancio Ribes allora faccia dei controlli su campi a caso che non c'entrano null
      this.idOperazione = '12345';
      this.utenzaCanale = '12345';
    }
  }

  public class GetBilancioSinteticoOutput {
    public StatoPatrimoniale statoPatrimoniale;
    public ContoEconomico contoEconomico;
    public Long dataChiusura;
  }

  public class StatoPatrimoniale {
    public Double immobilizzazioniImmateriali;
    public Double immobilizzazioniMateriali;
    public Double immobilizzazioniFinanziarieEDiverse;
    public Double immobilizzazioniDiCuiPartecipazioni;
    public Double attivoImmobilizzato;
    public Double rimanenze;
    public Double creditiEAttivitaDiverse;
    public Double creditiDiCuiVersoClienti;
    public Double attivitaFinanziarieELiquidita;
    public Double attivoCircolante;
    public Double totaleAttivo;
    public Double capitale;
    public Double riserve;
    public Double creditiVersoSociPerVersDovuti;
    public Double risultatoDiEsercizio;
    public Double patrimonioNetto;
    public Double fondoTrattamentoAFineRapporto;
    public Double fondiPerRischiEOneri;
    public Double debitiOltreIlBt;
    public Double debitiDiCuiVersoBanche;
    public Double debitiConsolidati;
    public Double risorsePermanenti;
    public Double debitiCorrenti;
    public Double debitiCorrentiDiCuiDebitiBancari;
    public Double debitiCorrentiDiCuiDebitiCommerciali;
    public Double debitiDiversiEAltrePassivita;
    public Double passivoCorrente;
    public Double totalePassivo;
    public Double totaleGaranziePersonaliPrestate;
    public Double diCuiCreditiVersoSociOIntergruppo;
    public Double diCuiDebitiVersoSociOIntergruppo;
  }

  public class ContoEconomico {
    public Double ricaviNetti;
    public Double variazioneSemilavoratiEProdotti;
    public Double varLavoriInCorsoSuOrdinazione;
    public Double incrementiImmobilizPerLavoriInterni;
    public Double altriRicaviEProventi;
    public Double valoreDellaProduzione;
    public Double materiePrimeSussidiarieDiConsumo;
    public Double varRimMatPrimeSussidConsumoEMerci;
    public Double costiPerServizi;
    public Double valoreAggiunto;
    public Double costiDelPersonale;
    public Double risultatoOperativoLordo;
    public Double ammortamentoImmobilizMateriali;
    public Double ammortamentoImmobilizImmateriali;
    public Double altreSvalutazioniDelleImmobilizzazioni;
    public Double oneriDiversiDiGestione;
    public Double svalutazioneDelCircolanteEDiverse;
    public Double accantonamentiPerRischiEOneriDiversi;
    public Double risultatoOperativo;
    public Double proventiFinanziari;
    public Double interessiEAltriOneriFinanziari;
    public Double rettificheDiValoreDiAttivitaFinanziarie;
    public Double risultatoCorrente;
    public Double oneriStraordinari;
    public Double proventiStraordinari;
    public Double risultatoPrimaDelleImposte;
    public Double imposteSulRedditoDiEsercizio;
    public Double risultatoDiEsercizio;
    public Double numeroDipendenti;
  }

  public class Servizio {
    public EventiNegativi eventiNegativi;
  }

  public class EventiNegativi {
    public ProdottoAziendeIscritte prodottoAziendeIscritte;
  }

  public class ProdottoAziendeIscritte {
    public String sourceIdRequest;
    public String codiceProdotto = 'RGENPI';
    public String tipo = 'PRD';
    public String formato;
    public String cciaa;
    public String nrea;
    public String protesti = 'S';
    public String pregiudizievoli = 'S';
    public String pcor = 'S';
    public String cigs = 'S';
    public String allarmiQuote = 'S';
    public String tipoMonitoraggio = 'N';
    public String tipoRinnovo;
    public String codiceAnagraficaCliente;
    public String elencoInfo;
  }

  public class GetEventiNegativiOutput {
    public Long data;
	//A.M. 25/03/21 Modifica Infoprovider RIBES -> CERVED
    //public Long ticketId;
	public String ticketId;
    public Risposta risposta;
  }

  public class Payload {
    public Long data;
    public String ticketId;
    public Risposta risposta;
  }

  public class Risposta {
    public Prodotto prodotto;
  }

  public class Prodotto {
    public String cd;
    public String fmt;
    public Imprese imprese;
    public Sintesi sintesi; //eventi negativi
    public ReportPDF reportPDF;
  }

  public class Sintesi {
    public Semaforo globale;
    public Semaforo protesti;
    public Semaforo pregiudizievoli;
    public Semaforo procedureConcorsuali;
    public Semaforo cigs;
    public Semaforo allarmiQuote;
  }

  public class Semaforo {
    public String semaforo;
  }

  public class ReportPDF {
    public String fileBase64;
  }

  public class Imprese {
    public String idBicLista;
    public String posizioni;
    public Impresa[] impresa;
  }

  public class Impresa {
    public String completa;
    public String cciaa;
    public String nRea;
    public String denominazione;
    public String codFisc;
    public String pIva;
    public NaturaGiuridica natGiu;
    public String dataCessazioneIC;
    public StatoAttivita statoAttivitaR;
    public Ateco ateco07;
    public Indirizzo indirizzo;

    public String getFormaGiuridica() {
      return natGiu != null ? natGiu.cod : null;
    }
  }

  public class NaturaGiuridica {
    public String cod;
    public String codice; //per infoPG
    public String gruppo;
    public String content;
  }

  public class StatoAttivita {
    public String cod;
    public String semaforo;
    public String content;
  }

  public class Ateco {
    public String cod;
    public String content;
  }

  public class Indirizzo {
    public Provincia provincia;
    public String comune;
    public String toponimo;
    public String via;
    public String nCivico;
    public String cap;

    public String getAddress() {
      return toponimo + ' ' + via + ' ' + nCivico;
    }
  }

  public class Indirizzo2 {
    public String cap;
    public String codiceToponimo;
    public String numeroCivico;
    public String toponimo;
    public String via;
    public String content;

    public String getAddress() {
      return toponimo + ' ' + via + ' ' + numeroCivico;
    }
  }

  public class Provincia {
    public String regione;
    public String sigla; //per infoPG
    public String content;
  }

  public class AziendaFull {
    public InfoImpresa infoImpresa;
    public InfoAttivita infoAttivita;
    // SV TEN - Add dati economici in wrapper
    public InfoDatiEconomici infoDatiEconomici;
    public PersonaWrapper[] titolari;

    public AziendaFull() {}

    public AziendaFull(InfoImpresa infoImpresa, InfoAttivita infoAttivita, InfoDatiEconomici infoDatiEconomici, PersonaWrapper[] titolari) {
      this.infoImpresa = infoImpresa;
      this.infoAttivita = infoAttivita;
      this.infoDatiEconomici = infoDatiEconomici;
      this.titolari = titolari;
    }

	//A.M. Modifica infoprovider RIBES -> CERVED
    public String getAteco() {
	  String codAteco;
      String codiceAteco = ((infoAttivita != null
             && infoAttivita.classificazioniAteco != null
             && infoAttivita.classificazioniAteco.elencoClassificazioniAteco != null
             && infoAttivita.classificazioniAteco.elencoClassificazioniAteco.classificazioneAteco != null
             && infoAttivita.classificazioniAteco.elencoClassificazioniAteco.classificazioneAteco.attivita != null)
             ? infoAttivita.classificazioniAteco.elencoClassificazioniAteco.classificazioneAteco.attivita.codice
             : '');
	//A.M. Da CERVED non arriva il codice Ateco con i punti
	System.debug('@@@M.N. codiceAteco: ' + codiceAteco);
		if (!codiceAteco.contains('.') && codiceAteco.length()>0)	{     
			codAteco = codiceAteco.substring(0,2);

			if(codiceAteco.length()>=3) {
				if (codiceAteco.length()==3)
					codAteco = codAteco + '.' + codiceAteco.substring(2,3);
				else
					codAteco = codAteco + '.' + codiceAteco.substring(2,4);
			} 
			if(codiceAteco.length()>=5) {
				if (codiceAteco.length()==5)
					codAteco = codAteco + '.' + codiceAteco.substring(4,5);
				else
					codAteco = codAteco + '.' + codiceAteco.substring(4,6);
			} 
		} else {
			codAteco = codiceAteco;
		}
		System.debug('@@@A.M. codiceAteco: ' + codAteco);  
        return codAteco;
    }

    public virtual Persona[] getReferenti() {
      Persona[] tmp = new Persona[] {};
      if (titolari != null) {
        for (PersonaWrapper w : titolari) {
          tmp.add(w.persona);
        }
      }
      return tmp;
    }
  }

  public class InfoImpresa {
    public String idSoggetto;
    public String denominazione;
    public KRea kRea;
    public Sede sede;
    public String codiceFiscale;
    public NaturaGiuridica naturaGiuridica;
    public String partitaIva;
    public CodiceContent tipo;
    public Data dataIscrizioneREA;
  }

  public class KRea {
    public String nRea;
    public Cciaa cciaa;
  }

  public class Cciaa {
    public String sigla;
    public String content;
  }

  public class Sede {
    public CodiceContent regione;
    public Provincia provincia;
    public CodiceContent comune;
    public Indirizzo2 indirizzo;
  }

  //TODO: serve per problema su comune, che a volte è un oggetto, altre volte una string
  public class Sede2 {
    public CodiceContent regione;
    public Provincia provincia;
    //public CodiceContent comune;
    public Indirizzo2 indirizzo;
  }

  public class CodiceContent {
    public String codice;
    public String content;
  }

  public class Data {
    public String anno;
    public String giorno;
    public String mese;
    public String content;
  }

  public class InfoAttivita {
    public Stato stato;
    public Stato statoAttivitaRettificato;
    public ClassificazioniAteco classificazioniAteco;
    public Data dataInizioAttivita;
    public String sae;
    public String rae;
  }

  public class Stato {
    public String codice;
    public String semaforo;
    public String content;
  }

  public class ClassificazioniAteco {
    public ElencoClassificazioniAteco elencoClassificazioniAteco;
  }

  public class ElencoClassificazioniAteco {
    public String codifica;
    public String descrizione;
    public ClassificazioneAteco classificazioneAteco;
  }

  public class ClassificazioneAteco {
    public CodiceContent attivita;
  }

  public class PersonaWrapper {
    public Persona persona;
  }

  public class Persona {
    public InfoPersona infoPersona;
  }

  public class InfoPersona {
    public String idSoggetto;
    public Nominativo nominativo;
    public String codiceFiscale;
    public Sede2 residenza;
  }

  public class Nominativo {
    public String nome;
    public String cognome;
    public String content;
  }

  public class InfoDatiEconomici {
    public CapitaleSociale capitaleSociale;
  }

  public class CapitaleSociale {
    public Decimal ammontare;
    public CodiceContent valuta;
  }

  //response
  public class GetListaAziendeResponse extends WsRestInput.CommonResponse {
    @testVisible private Payload payload;

    public override Boolean isCorrect() {
      return payload != null;
    }

    public Impresa[] getAziende() {
      return getAziende(null);
    }

    public Impresa[] getAziende(String provinceCode) {
      return payload != null
             && payload.risposta != null
             && payload.risposta.prodotto != null
             && payload.risposta.prodotto.imprese != null
             && payload.risposta.prodotto.imprese.impresa != null
             ? filtraCessati(filtraProvincia(payload.risposta.prodotto.imprese.impresa, provinceCode)) : new Impresa[] {};
    }

    private Impresa[] filtraProvincia(Impresa[] input, String provinceCode) {
      if(String.isBlank(provinceCode)) return input;
      Impresa[] res = new Impresa[] {};
      for (Impresa i : input) {
        if(i.indirizzo != null && i.indirizzo.provincia != null && i.indirizzo.provincia.content == provinceCode) res.add(i);
      }
      return res;
    }

    private Impresa[] filtraCessati(Impresa[] input) {
      Impresa[] res = new Impresa[] {};
      for (Impresa i : input) {
        if (i.statoAttivitaR.content != 'CESSATA') res.add(i);
      }
      return res;
    }
  }

  public class GetInformazioniPGResponse extends WsRestInput.CommonResponse {
    @testVisible private Payload payload;

    @testVisible private AziendaFull impresa;

    public GetInformazioniPGResponse() {}

    public GetInformazioniPGResponse(InfoImpresa infoImpresa, InfoAttivita infoAttivita, InfoDatiEconomici infoDatiEconomici, PersonaWrapper[] titolari, WsRestInput.HeaderWrapper headers) {
      this.headers = headers;

      if (infoImpresa != null && infoAttivita != null) {
        this.impresa = new AziendaFull(infoImpresa, infoAttivita, infoDatiEconomici, titolari);
      }
    }

    public override Boolean isCorrect() {
      return impresa != null;
    }

    public virtual AziendaFull getImpresa() {
      return impresa;
    }
  }

  public class GetEventiNegativiResponse extends WsRestInput.CommonResponse {
    private GetEventiNegativiOutput payload;

    public override Boolean isCorrect() {
      return payload != null
             && payload.risposta != null
             && payload.risposta.prodotto != null
             && (payload.risposta.prodotto.sintesi != null
                 || payload.risposta.prodotto.reportPDF != null);
    }

    public Sintesi getSintesi() {
      return payload != null
             && payload.risposta != null
             && payload.risposta.prodotto != null
             ?  payload.risposta.prodotto.sintesi : null;
    }

    //A.M. 25/03/21 Modifica Infoprovider RIBES -> CERVED 
	//(TicketId alafanumerico e non Long)
	public String getTicketId() {
      return payload != null
             && payload.risposta != null
             ? payload.ticketId : null;
    }

    public String getPDF() {
      return payload != null
             && payload.risposta != null
             && payload.risposta.prodotto != null
             && payload.risposta.prodotto.reportPDF != null
             ? payload.risposta.prodotto.reportPDF.fileBase64 : null;
    }
  }

  public class GetBilancioSinteticoResponse extends WsRestInput.CommonResponse {
    public GetBilancioSinteticoOutput payload;

    public override Boolean isCorrect() {
      return payload != null
             && payload.statoPatrimoniale != null
             && payload.contoEconomico != null;
    }
  }


  //TODO: fare più carino, fatto al volo per deploy
  //parsing manuale
  //A.M. Modifica Infoprovider RIBES -> CERVED (sostituido 'Dati' con 'dati')
  public static GetInformazioniPGResponse parseInformazioniPG(Map<String, Object> m) {
    String[] tree = new String[] {'payload', 'risposta', 'prodotto', 'reportXML', 'dati', 'Impresa'};
    Map<String, Object> impresa;
    Map<String, Object> nodo = m;
    for (String n : tree) {
      nodo = (Map<String, Object>)nodo.get(n);
      if (nodo == null) {
        break;
      }
    }
    impresa = nodo;

    System.debug('SV parseInformazioniPG impresa: ' + impresa);

    InfoImpresa infoImp;
    InfoAttivita infoAtt;
    InfoDatiEconomici infoDEc;
    PersonaWrapper[] titolari;

    if (impresa != null) {
      infoImp = (InfoImpresa)getConcreteObject(impresa.get('InfoImpresa'), InfoImpresa.class);
      infoAtt = (InfoAttivita)getConcreteObject(impresa.get('InfoAttivita'), InfoAttivita.class);
      infoDEc = (InfoDatiEconomici)getConcreteObject(impresa.get('DatiEconomici'), InfoDatiEconomici.class);

      Map<String, Object> elencoTitolariEffettivi = (Map<String, Object>)impresa.get('ElencoTitolariEffettivi');
      if (elencoTitolariEffettivi != null) {
        PersonaWrapper titolare;
        try {
          titolari = (PersonaWrapper[])getConcreteObject(elencoTitolariEffettivi.get('TitolareEffettivo'), PersonaWrapper[].class);
        } catch (Exception e) {
          titolare = (PersonaWrapper)getConcreteObject(elencoTitolariEffettivi.get('TitolareEffettivo'), PersonaWrapper.class);
        }
        if (titolari == null && titolare != null) {
          titolari = new PersonaWrapper[] {titolare};
        }
      }
    }

    //error list
    WsRestInput.HeaderWrapper headers;
    String[] errorTree = new String[] {'headers'};
    Map<String, Object> errorHeader;
    Map<String, Object> nodo2 = m;
    for (String n : errorTree) {
      nodo2 = (Map<String, Object>)nodo2.get(n);
      if (nodo2 == null) {
        break;
      }
    }
    errorHeader = nodo2;

    if (errorHeader != null) {
      headers = (WsRestInput.HeaderWrapper)getConcreteObject(errorHeader, WsRestInput.HeaderWrapper.class);
    }

    return new GetInformazioniPGResponse(infoImp, infoAtt, infoDEc, titolari, headers);
  }

  private static Object getConcreteObject(Object generic, System.Type objType) {
    String jsonString = JSON.serialize(generic);
    OBject concrete = JSON.deserialize(jsonString, objType);
    return concrete;
  }
}