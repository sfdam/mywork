public class WGC_WsRest {

    /**
   * PEF37
   * Il metodo interroga i web service per aggiornare i campi di prodotto e posizione 
   * @param  codiceIstituto3N (SI)
   * @param  codNdg (SI)
   * @param  numLineaCredito (NO)
   * @return
   */
  public static GetCampiProdottiPosizioneResponse aggiornaCampi_Prodotti_Posizione(String codiceIstituto3N, String codNdg, String numLineaCredito) {
    if (String.isBlank(codiceIstituto3N) && String.isBlank(codNdg)) {
      throw new Ex.RibesInputException('Denominazione o codice fiscale mancanti');
    }

    PayloadGenericoInput input = new PayloadGenericoInput();
    input.codNdg = Integer.valueof(codNdg);
    input.codiceIstituto3N = Integer.valueof(codiceIstituto3N);
    input.numLineaCredito = (numLineaCredito == null) ? null : Integer.valueof(numLineaCredito);
    

    return (GetCampiProdottiPosizioneResponse) WsRestUtils.callService(
      'URL_Aggiorna_Campi_Prodotti_Posizione__c',
      input,
      GetCampiProdottiPosizioneResponse.class
    );
  }

  //input payload
  public class PayloadGenericoInput {
    public Integer codNdg;
    public Integer codiceIstituto3N;
    public Integer numLineaCredito;
    
    
  }

  //output payload
  public class LineeCredito {
    public Long numLineaCredito;
    public String codRapportoEst;
    public String codLineaSistema;
    public String desLineaSistema;
    public String desStatoLinea;
    public String codStatoLinea;
    public String flgOperante;
    public String codDivisa;
    public Decimal prcCambio;
    public Decimal impOutstanding;
    public Decimal impOutstandingCtv;
    public Decimal impEmesso;
    public Decimal impEmessoCtv;
    public Decimal impUltimaCessione;
    public Decimal impUltimaCessioneCtv;
    public Decimal impImpiego;
    public Decimal impImpiegoCtv;
    public Decimal impFinanziabile;
    public Decimal impFinanziabileCtv;
    public Long datUltimaCessione;    
  }

  //metto virtual per estenderlo in RestAnagrafeCrm
  public class DatiProdotti_Posizione {
    public String resultCode;
    public String resultMessage;
    public Integer errorDetails; 
    public OutputRichiesta outputRichiesta;
  }

  public class OutputRichiesta {
    public Integer codiceIstituto3N;
    public Long codNdg;
    public Long numLineaCredito;
    public Long codNdgCedente;
    public String ragSocCedente;
    public List<LineeCredito> elencoLineeCredito;

  }

  //response getdatianagraficicedacri
  public class GetCampiProdottiPosizioneResponse extends WsRestInput.CommonResponse {
    public DatiProdotti_Posizione payload;

    public override Boolean isCorrect() {
      return payload != null;
    }
  }

  //WGC_Account_Utility_Controller.OutputMain
  /*
  * Chiamata utilizzata all'apertura dell'anagrafica per recuperare i dati dal servizio di bilancio
  * @param ndg 
  * @param codiceFiscale
  * @param numeroBilanci
  *
  */
  public static WGC_Account_Utility_Controller.OutputMain callServiceBilancio(Object input){
    if(input != null){
      return (WGC_Account_Utility_Controller.OutputMain) WsRestUtils.callService('WGC_Url_Dati_Bilancio__c' , input , WGC_Account_Utility_Controller.OutputMain.Class);
    }
      
    return null;
    
  }

  /*
  * DOC08
  * Metodo effettua il download di un pdf dal servizio DOC08
  * @param payload di input generato e trasformato in stringa
  *
  */

  public static Blob downloadPDF(String input){
    //Metodo che effettua la chiamata in base ai parametri passati
    Blob file = WsRestUtils.WGC_makeRequest_blob('WGC_Url_Doc08__c', input, 120000);
    //WsRestUtils.writeLog('WGC_URL_Doc08__c', input, file.toString(), '');

    return file;

  }

    /*
  * DOC61
  * Metodo effettua il download di un pdf dal servizio DOC61
  * @param payload di input generato e trasformato in stringa
  *
  */

  public static Blob downloadDoc61(String input){
    //Metodo che effettua la chiamata in base ai parametri passati
    Blob file = WsRestUtils.WGC_makeRequest_blob('WGC_Url_Doc_61__c', input, 120000);
    //WsRestUtils.writeLog('WGC_URL_Doc08__c', input, file.toString(), '');

    return file;

  }

  /*
  * DOC01
  * Metodo per l'upload di un file su documentale FILENET
  */
  public static WGC_FileUploaderController.ResponseUpload uploadDoc(Blob bodyBlob, String boundary) {
    return (WGC_FileUploaderController.ResponseUpload) WsRestUtils.callService('WGC_Url_Doc01__c', bodyBlob, WGC_FileUploaderController.ResponseUpload.Class, 120000, boundary);
  } 

    /*
  * DOC62
  * Metodo per l'upload di un file su documentale FILENET / CBOX
  */
  public static WGC_FileUploaderController.ResponseUpload62 uploadDoc62(Blob bodyBlob, String boundary) {
    return (WGC_FileUploaderController.ResponseUpload62) WsRestUtils.callService('WGC_Url_Doc62__c', bodyBlob, WGC_FileUploaderController.ResponseUpload62.Class, 120000, boundary);
  } 

  /**
   * DigiBox
   * Metodo per l'upload di un file su documentale tramite DigiBox
  **/
  public static BI_CRM_DigiBox_CODE.ResponseUpload uploadDocDigiBox(Blob bodyBlob, String boundary) {
    return (BI_CRM_DigiBox_CODE.ResponseUpload) WsRestUtils.callService('Url_DigiBox_createautomatic__c', bodyBlob, BI_CRM_DigiBox_CODE.ResponseUpload.Class, 120000, boundary);
  } 

  /*
  * DOC10
  * Metodo utilizzato per recuperare la lista documenti legata ad una anagrafica
  * @param payload di input generato e trasformato in stringa
  *
  */
  public static Object doc10(Object input){
    return (WGC_Documenti_Controller.OutputDoc10) WsRestUtils.callService('WGC_Url_Doc10__c', input, WGC_Documenti_Controller.OutputDoc10.Class);
  }

  /*
  * DOC11
  * Metodo utilizzato per fare la document composition
  * @param payload di input
  * @return blob file
  */
  public static Blob doc11(String input){
    Blob file = WsRestUtils.WGC_makeRequest_blob('WGC_Url_Doc11__c', input, 120000);

    return file;
  }


  /*
  * Ricerca multipla documenti
  * Metodo utilizzato per la ricerca multipla dei documenti
  * 
  */
  public static Object ricercaMultiplaDocumenti(Object input){
    return (WGC_Documenti_Controller.DatiRicercaMultiplaEsito) WsRestUtils.callService('WGC_Url_Ricerca_multipla_documenti__c', input, WGC_Documenti_Controller.DatiRicercaMultiplaEsito.Class);
  }

}