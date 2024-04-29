public without sharing class WsRestDocumentale {

  public static String DOCUMENTO_RSF = 'RSFFirm';
  private static String DOCUMENTI_CLIENTE = 'DOCUMENTI_CLIENTE';
  private static String DOCUMENT_TITLE = 'DocumentTitle';
  private static String DOCUMENT_CODICE = 'CODICEDOC';
  private static String DOCUMENT_SOTTOCLASSE = 'CODICESOTTOCLASSE';

  // metodi

  /**
   * Adds a document on the FILENET document system (DOC01)
   **/
  public static AggiungiOggettiResponse aggiungiOggetti(AggiungiOggettiInput input) {
    if (input == null || input.data == null || input.data.datiDocumento == null) {
      throw new Ex.CedacriInputException('aggiungiOggetti input vuoto');
    }
    input.data.datiDocumento.classeOggetto = DOCUMENTI_CLIENTE;
    return (AggiungiOggettiResponse) WsRestUtils.callService(
      'UrlAggiungiOggetti__c',
      input,
      AggiungiOggettiResponse.class
    );
  }

  /**
   * Removes a document on the FILENET document system (DOC01)
   **/
  public static CancellaOggettiResponse cancellaOggetti(CancellaOggettiInput input) {
    if (input == null || input.datiDocumento == null) {
      throw new Ex.CedacriInputException('cancellaOggetti input vuoto');
    }

    return (CancellaOggettiResponse) WsRestUtils.callService(
      'UrlCancellaOggetti__c',
      input,
      CancellaOggettiResponse.class
    );
  }

  /**
   * Search for a document on the FILENET document system (DOC04)
   **/
  public static SearchDocumentResponse searchDocument(SearchDocumentDettaglioOggettoInput input) {
    if (input == null || input.datiDocumento == null) {
      throw new Ex.CedacriInputException('searchDocument input vuoto');
    }
    input.datiDocumento.classeOggetto = DOCUMENTI_CLIENTE;

    return (SearchDocumentResponse) WsRestUtils.callService(
      'UrlSearchDocument__c',
      input,
      SearchDocumentResponse.class
    );
  }

  /**
   * Obtains details for an object (either a document, booklet, or custom object) on the FILENET document system (DOC06)
   */
  public static DettaglioOggettoResponse dettaglioOggetto(SearchDocumentDettaglioOggettoInput input) {
    if (input == null || input.datiDocumento == null) {
      throw new Ex.CedacriInputException('dettaglioOggetto input vuoto');
    }
    //TODO: DOCUMENTI_CLIENTE restituisce errore!
    input.datiDocumento.classeOggetto = 'INDICIFIRME';

    return (DettaglioOggettoResponse) WsRestUtils.callService(
      'UrlDettaglioOggetto__c',
      input,
      DettaglioOggettoResponse.class
    );
  }

  public static RestCommon.ResponseObject getDocumentThroughTalend(String fileName, String link, String idDocumento, String idCartella) {
    if (String.isBlank(fileName)
        || String.isBlank(link)
        || String.isBlank(idDocumento)
        || String.isBlank(idCartella)) {
      throw new Ex.CedacriInputException('getDocumentThroughTalend input non valido');
    }

    GetDocumentThroughTalendInput input = new GetDocumentThroughTalendInput(fileName, link, idDocumento, idCartella);

    RestCommon.ResponseObject responseObj;
    String response = WsRestUtils.callSimpleService('UrlGetDocumentThroughTalend__c', input);
    if (response != null) {
      responseObj = (RestCommon.ResponseObject)JSON.deserialize(response, RestCommon.ResponseObject.class);
    }
    return responseObj;
  }


  // input payloads

  /**
   * Class containing input data to invoke "AggiungiOggetti" service
   */

  public class AggiungiOggettiInput {
    public AggiungiOggettiData data;
  }

  public class AggiungiOggettiData extends WsRestInput.CommonInput {
    public String matricola;
    public String ruolo;
    public Integer filiale;
    public DatiDocumento datiDocumento;
    public String campiAggiuntivi;
  }

  /**
   * Class containing input data to invoke "CancellaOggetti" service
   */
  public class CancellaOggettiInput extends WsRestInput.CommonInput {
    public String matricola;
    public String ruolo;
    public Integer filiale;
    public DatiDocumento datiDocumento;
    public String campiAggiuntivi;
  }

  /**
   * Class containing input data to invoke "SearchDocument" and "DettaglioOggetto" service
   */
  public class SearchDocumentDettaglioOggettoInput extends WsRestInput.CommonInput {
    public String matricola = 'YH01175';
    public String ruolo = 'I340';
    public Integer filiale = 833;
    public DatiDocumento datiDocumento;
    public String campiAggiuntivi;
  }

  public class GetDocumentThroughTalendInput {
    public Documento documento;

    public GetDocumentThroughTalendInput() {}

    public GetDocumentThroughTalendInput(String fileName, String link, String idDocumento, String idCartella) {
      this.documento = new Documento(fileName, link, idDocumento, idCartella);
    }
  }

  public class Documento {
    public String fileName;
    public String link;
    public String idComposto;

    public Documento() {}

    public Documento(String fileName, String link, String idDocumento, String idCartella) {
      this.fileName = fileName;
      this.link = link;
      this.idComposto = idDocumento + '_' + idCartella;

    }
  }

  // output payloads

  /**
   * Class containing output data received from invoking "AggiungiOggetti" service
   */
  public class AggiungiOggettiOutput {
    public DatiDocumentoOut datiDocumento;
  }

  /**
   * Class containing output data received from invoking "CancellaOggetti" service
   */
  public class CancellaOggettiOutput {
    public String esito;
  }

  /**
   * Class containing output data received from invoking "searchDocument" service
   */
  public class SearchDocumentOutput {
    public Integer numeroElementi;
    public Elemento[] elemento;
    public Lettore[] lettori;
    public String link;
  }

  /**
   * Class containing output data received from invoking "DettaglioOggetto" service
   */
  public class DettaglioOggettoOutput {
    public DatiDocumentoOut2 datiDocumento;
  }


  // stubs

  public enum AzioneDiRicerca {NONE, REPLACE, ADDVERSION, ADDCONTENT, UPDATECURRENTVERSION}

  public class ContenutoDocumento {
    public String nomeFIle; //ATTENZIONE: deve avere la I maiuscola o si rompre il servizio
    public String tipoMime;
    public String sha256;
    public String base64;

    public ContenutoDocumento() {}

    public ContenutoDocumento(String nomeFile, String tipoMime, String base64) {
      this.nomeFile = nomeFile;
      this.tipoMime = tipoMime;
      this.base64 = base64;
    }
  }

  public class DatiDocumento {
    public String classeOggetto;
    public Indice[] indice;
    public AzioneDiRicerca azioneDiRicerca;
    public ContenutoDocumento[] contenutoDocumento;
    public Boolean forzaCancellazioneSottoDocumenti;
    public String cartella;
    public String sottoCartella;
    public Pagina pagina;
    public String ordine;
    public String righeMassime;
    public String versione;

    public DatiDocumento() {}

    public void addDocument(String nomeFile, String tipoMime, String base64) {
      if (contenutoDocumento == null) {
        contenutoDocumento = new ContenutoDocumento[] {};
      }
      contenutoDocumento.add(new ContenutoDocumento(nomeFile, tipoMime, base64));
    }

    public void addIndice(String nome, String valore) {
      if (indice == null) {
        indice = new Indice[] {};
      }
      indice.add(new Indice(nome, valore));
    }

    public void addIndice(String nome, String valore, String operatore) {
      if (indice == null) {
        indice = new Indice[] {};
      }
      indice.add(new Indice(nome, valore, operatore));
    }

    public void addIndiceSpastico(String nome, String valore, String operatore) {
      if (indice == null) {
        indice = new Indice[] {};
      }
      Indice tmp = new Indice(nome, valore, operatore);
      tmp.setSpasticismo();
      indice.add(tmp);
    }

    public void setPaginaStd() {
      this.pagina = new Pagina('1', '10');
    }
  }

  public class DatiDocumentoOut {
    public String id;
    public String objectStore;
    public String classe;
    public String tipoBase;
    public Indice[] indice;
    public Lettori[] lettori;
    public String link;
  }

  public class DatiDocumentoOut2 {
    public String id;
    public String objectStore;
    public String classe;
    public String tipoBase;
    public Indice[] indice;
    public Lettore[] lettori;
    public String link;
  }

  public class Elemento {
    public String id;
    public String objectStore;
    public String classe;
    public String tipoBase;
    public Indice[] indice;
    public Lettore[] lettori;
    public String link;
    private String fileName;
    private String codiceDoc;
    private String codiceSottoclasse;

    public String getDocumentName() {
      if (String.isBlank(this.fileName)) {
        if (this.indice != null) {
          for (Indice i : this.indice) {
            if (i.nome == DOCUMENT_TITLE) {
              this.fileName = i.valore;
              break;
            }
          }
        }
      }
      return this.fileName;
    }

    public String getCodiceDoc() {
      if (String.isBlank(this.codiceDoc)) {
        if (this.indice != null) {
          for (Indice i : this.indice) {
            if (i.nome == DOCUMENT_CODICE) {
              this.codiceDoc = i.valore;
              break;
            }
          }
        }
      }
      return this.codiceDoc;
    }

    public String getCodiceSottoclasse() {
      if (String.isBlank(this.codiceSottoclasse)) {
        if (this.indice != null) {
          for (Indice i : this.indice) {
            if (i.nome == DOCUMENT_SOTTOCLASSE) {
              this.codiceSottoclasse = i.valore;
              break;
            }
          }
        }
      }
      return this.codiceSottoclasse;
    }
  }

  public class Indice {
    public String id;
    public String nome;
    public String ricerca;
    public String append;
    public String operatore;
    public String label;
    public String etichetta;
    public String valore;

    public Indice() {}

    public Indice(String nome, String valore) {
      this.nome = nome;
      this.valore = valore;
      this.ricerca = 'FALSE';
      this.append = 'FALSE';
    }

    public Indice(String nome, String valore, String operatore) {
      this.nome = nome;
      this.operatore = operatore;
      this.valore = valore;
    }

    public void setSpasticismo() {
      this.id = this.nome;
      this.nome = null;
    }
  }

  public class Lettore {
    public String id;
    public DateTime oraGiornoLettura;
  }

  public class Lettori {
    public String idLettori;      // TODO check: nome idLettori ?!
    public Long oraGiornoLettura; // TODO check: tipo XMLGregorianCalendar ??
  }

  public class Pagina {
    public String Indice; //deve rimanere maiuscolo per DOC04
    public String Dimensione; //deve rimanere maiuscolo per DOC04

    public Pagina() {}

    public Pagina(String indice, String dimensione) {
      this.indice = indice;
      this.dimensione = dimensione;
    }
  }


  // responses
  public class AggiungiOggettiResponse extends WsRestInput.CommonResponse {
    public AggiungiOggettiOutput payload;

    public override Boolean isCorrect() {
      return payload != null
             && payload.datiDocumento != null
             && payload.datiDocumento.indice != null
             && !payload.datiDocumento.indice.isEmpty();
    }

    public String getDocumentId() {
      return isCorrect() ? payload.datiDocumento.id : null;
    }
  }

  public class CancellaOggettiResponse extends WsRestInput.CommonResponse {
    public CancellaOggettiOutput payload;

    public override Boolean isCorrect() {
      return payload != null;
    }
  }

  public class SearchDocumentResponse extends WsRestInput.CommonResponse {
    public SearchDocumentOutput payload;

    public override Boolean isCorrect() {
      return payload != null;
    }

    public Elemento[] getResults() {
      return payload != null ? payload.elemento : null;
    }
  }

  public class DettaglioOggettoResponse extends WsRestInput.CommonResponse {
    public DettaglioOggettoOutput payload;

    public override Boolean isCorrect() {
      return payload != null;
    }
  }

}