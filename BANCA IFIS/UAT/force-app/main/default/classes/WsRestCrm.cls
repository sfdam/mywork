public without sharing class WsRestCrm {

  /**
   * (CRM02)
   */
  public static NvAggiornamentoInnescaVenditaResponse nvAggiornamentoInnescaVendita(NvAggiornamentoInnescaVenditaInput input, Id idOpp) {
    return (NvAggiornamentoInnescaVenditaResponse) WsRestUtils.callService(
      'UrlNvAggiornamentoInnescaVendita__c',
      input,
      NvAggiornamentoInnescaVenditaResponse.class,
      120000
    );
  }

  /**
   * (CRM04)
   */
  public static NvInquiryStatoCartellaResponse nvInquiryStatoCartella(String idCart) {
    if (String.isBlank(idCart)) {
      throw new Ex.CedacriInputException('input vuoto');
    }

    return (NvInquiryStatoCartellaResponse) WsRestUtils.callService(
      'UrlNvInquiryStatoCartella__c',
      new NvInquiryStatoCartellaInput(idCart),
      NvInquiryStatoCartellaResponse.class
    );
  }

  /**
   * (CRM11)
   */
  public static RenderPdfResponse renderPdf(RenderPdfInput input) {
    return (RenderPdfResponse) WsRestUtils.callService('UrlRenderPdf__c', input, RenderPdfResponse.class);
  }


  /**
   * (CRM16) TiAnticipo: calcolo commissione effettiva
   */
  public static CalcoloC138DebitoreResponse calcoloC138Debitore(CalcoloC138DebitoreInput input) {
    input.lingua = null;
    input.idSessioneChiamante = null;
    input.idApplicazioneChiamante = null;
    return (CalcoloC138DebitoreResponse) WsRestUtils.callService(
      'UrlCalcoloC138Debitore__c',
      input,
      CalcoloC138DebitoreResponse.class,
      120000
    );
  }

  // input payloads
    public class CalcoloC138DebitoreInput extends WsRestInput.CommonInput {
    public Decimal codNDG;
    public Decimal durataCredito;
    public Decimal valoreCommissioneTA;

    public CalcoloC138DebitoreInput (String ndg, Decimal durataCredito, Decimal valoreCommissioneTA) {
      this.codNDG = Decimal.valueOf(ndg);
      this.durataCredito = durataCredito;
      this.valoreCommissioneTA = valoreCommissioneTA;
    }
  }

  public class NvAggiornamentoInnescaVenditaInput extends WsRestInput.CommonInput {
    public String userIdOperatore;
    public Integer ndgOperatore;
    public String ruoloOperatore;
    public Integer filiale;
    public Integer intestatario;
    public String noteIstruttoria;
    // MB - TEN: AGGIUNTA PARAMETRI PAYLOAD PER INVIO NV
    public String flagConsolidamento;
    // MB - TEN: END
    public AssociazioneGaranziaOmnibus associazioneGaranziaOmnibus;
    public Prodotti prodotti;

    public NvAggiornamentoInnescaVenditaInput() {
      //TODO: per evitare errori vanno settati. poi capire se saranno dinamici
      this.utenzaCanale = 'CRE0321';
      this.idOperazione = '123';
    }
  }

  public class NvInquiryStatoCartellaInput extends WsRestInput.CommonInput {
    public String idCartella;
    public NvInquiryStatoCartellaInput(String idCartella) {
      this.idCartella = idCartella;
    }
  }

  public class RenderPdfInput extends WsRestInput.CommonInput {
    public String xmlbytes;
    public String xdppath;
    public String xdpname;
    public String callFunction;
  }

  // stubs
  public class AssociazioneGaranziaOmnibus {
    public Garanzia[] garanzia;
  }

  public class Garanzia {
    public String codTipoGara;
    public String codiceGaranzia;
    public Decimal importo;
    public String divisa;
    public Long dataGara;
    public Long dataScadGara;
    public String flagProQuota;
    public Decimal prcGaranzia;
    public Referenti referenti;
    //da modificare, questo campo va in referenti e non in garanzie
    public String codTipoGarante;
  }

  public class Referenti {
    public Referente[] referente;
  }

  public class Referente {
    public Integer ndg;
    public Decimal percentuale;
    public Decimal importoGarante;
    public String codTipoGarante;
  }

  public class Prodotti {
    public Prodotto[] prodotto;
  }

  public class Prodotto {
    public Integer idProdotto;
    public String codiceApplicazione;
    public String codiceProdotto;
    public Integer codiceStato;
    public String descrizioneStato;
    public String descrizioneProdotto;
    public String tipologia;
    public String categoria;
    public AssociazioneProdotti associazioneProdotti;
    public DatiTecnici datiTecnici;
    public Condizioni condizioni;
    public CondizioniFactoring condizioniFactoring;
    public AssociazioneNdgRuoli associazioneNdgRuoli;
    public FidiCoppia fidiCoppia;
    public ParametriAggiuntivi parametriAggiuntivi;
    public AssociazioneGaranzie associazioneGaranzie;
  }

  public class AssociazioneProdotti {
    public ProdottoBase[] prodottoBase;
  }

  public class ProdottoBase {
    public Integer idProdotto;
  }

  public class DatiTecnici {
    public DatoTecnico[] datoTecnico;
  }

  public class DatoTecnico {
    public String codice;
    public String valore;
  }

  public class Condizioni {
    public String note;
    public Condizione[] condizione;
  }

  public class Condizione {
    public Long dataDecorrenza;
    public Long dataRevoca;
    public String linea;
    public String listino;
    public Integer datoElementare;
    public String valoreProposto;
    public String indice;
    public String operatore;
    public String costante;
    public String natura;
  }

  public class CondizioniFactoring {
    public CondizioneFactoring[] condizioneFactoring;
  }

  public class CondizioneFactoring {
    public String codiceCond;
    public String codDBC;
    public String codDBCscag;
    public String periodicita;
    public String tipoGiorni;
    public String tipoRangeScagl;
    public String tipoCond;
    public ValoriCondFactoring valoriCondFactoring;
  }

  public class ValoriCondFactoring {
    public ValoreCondFactoring[] valoreCondFactoring;
  }

  public class ValoreCondFactoring {
    public Integer prgScagCond;
    public Decimal minScag;
    public Decimal maxScag;
    public Decimal valueCond;
    public String indiceBaseCond;
  }

  public class AssociazioneNdgRuoli {
    public Associazione[] associazione;
  }

  public class Associazione {
    public Integer ndg;
    public String codiceRuolo;
  }

  public class FidiCoppia {
    public FidoCoppia[] fidoCoppia;
  }

  public class FidoCoppia {
    public Integer codNDGDebi;
    public String codTipoCoppia;
    public String codDivisa;
    public Decimal importoRichiestoEndo;
    public Decimal importoRichiestoUto;
    public Long dataInizioValidita;
    public ParametriFidoCoppia parametriFidoCoppia;
  }

  public class ParametriFidoCoppia {
    public Parametro[] parametro;
  }

  public class ParametriAggiuntivi {
    public Parametro[] parametro;
  }

  public class Parametro {
    public String codice;
    public String codTipoPara;
    public ValoriParametro valoriParametro;
  }

  public class ValoriParametro {
    public ValoreParametro[] valoreParametro;
  }

  public class ValoreParametro {
    public Integer progressivo;
    public String valore;
  }

  public class AssociazioneGaranzie {
    public Garanzia[] garanzia;
  }

  public class CalcoloC138DebitoreOutputTA {
    public Decimal valoreCommissioneEffettivo;
  }

  public class NvAggiornamentoInnescaVenditaResponsePayload {
    public String idCartella;
  }

  public class NvInquiryStatoCartellaResponsePayload {
    public Integer codiceStato;
    public String descrizioneStato;
    public Prodotti prodotti;
  }

  public class RenderPdfResponsePayload {
    public String documento;    //base64binary
  }

  public class CalcoloC138DebitoreResponsePayload {
    public Decimal resultCode;
    public String resultMessage;
    public String errorDetails;
    public CalcoloC138DebitoreOutputTA outputTiAnticipo;
  }

  // responses

  public class NvAggiornamentoInnescaVenditaResponse extends WsRestInput.CommonResponse {
    public NvAggiornamentoInnescaVenditaResponsePayload payload;

    public override Boolean isCorrect() {
      return payload != null && String.isNotBlank(payload.idCartella);
    }
  }

  public class NvInquiryStatoCartellaResponse extends WsRestInput.CommonResponse {
    public NvInquiryStatoCartellaResponsePayload payload;

    public override Boolean isCorrect() {
      return payload != null;
    }
  }

  public class RenderPdfResponse extends WsRestInput.CommonResponse {
    public RenderPdfResponsePayload payload;

    public override Boolean isCorrect() {
      return payload != null;
    }
  }

  public class CalcoloC138DebitoreResponse extends WsRestInput.CommonResponse {
    public CalcoloC138DebitoreResponsePayload payload;

    public override Boolean isCorrect() {
      return payload != null && payload.resultCode == 0;
    }
  }

}