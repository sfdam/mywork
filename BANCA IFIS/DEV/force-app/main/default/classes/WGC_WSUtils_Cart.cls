public class WGC_WSUtils_Cart {
    public final static List<String> CODES_TO_BE_REMOVED = new List<String> {'008','FAS','PLA','DUR'};

    public class OutputRichiestaWrapper38 {
        public Integer codiceIstituto3N;
        public Long codNDG;
        public Long numLineaCredito;
        public String codRapportoEst;
        public String codLineaSistema;
        public String desLineaSistema;
        public String codStatoLinea;
        public String desStatoLinea;
        public String flgOperante;
        public Decimal impAccordato;
        public Decimal impQuotaNotifica;
        public Decimal impQuotaOneri;
        public String codDivisa;
        public ElencoParametriLinea[] elencoParametriLinea;
        public ElencoParametriDerogati[] elencoParametriDerogati;
        public ElencoCondizioniLinea[] elencoCondizioniLinea;
        public ElencoConti[] elencoConti;
        public ElencoCondizioniDerogate[] elencoCondizioniDerogate;
    }

    public class ElencoParametriLinea {
        public String codParametro;
        public String desParametro;
        public String tipoDato;
        public String tipoGestione;
        public String flgDelibera;
        public ElencoValoriParametro[] elencoValoriParametro;
    }

    public class ElencoParametriDerogati {
        public String codNdgDebitore;
        public String ragSocDebitore;
        public Long codRandomCoppia;
        public Long numCAR;
        public String codtipoCoppia;
        public String codCarTecn;
        public String codParametro;
        public String desParametro;
        public String tipoDato;
        public String tipoGestione;
        public String flgDelibera;
        public ElencoValoriParametro[] elencoValoriParametro;
    }

    public class ElencoCondizioniLinea {
        public String codCondizione;
        public String desCondizione;
        public String tipoCondizione;
        public String codDatoBaseCalc;
        public String desDatoBaseCalc;
        public String codTipoGiorni;
        public String codCondizioneBase;
        public String desCondizioneBase;
        public String valCondizioneBase;
        public Long datDecorrenza;
        public ElencoScaglioni[] elencoScaglioni;
    }

    public class ElencoConti {
        public String codTipoConto;
        public String numConto;
        public ElencoCondizioniLinea[] elencoCondizioniConto;
    }

    public class ElencoCondizioniDerogate {
        public String codNdgDebitore;
        public String ragSocDebitore;
        public String codCondizione;
        public String desCondizione;
        public String tipoCondizione;
        public String codDatoBaseCalc;
        public String desDatoBaseCalc;
        public String codTipoGiorni;
        public String codCondizioneBase;
        public String desCondizioneBase;
        public String valCondizioneBase;
        public Long datDecorrenza;
        public ElencoScaglioni[] elencoScaglioni;
    }

    public class ElencoValoriParametro {
        public String prgvalPara;
        public String valParametro;
        public String desValore;
    }

    public class ElencoScaglioni {
        public String valInizScaglione;
        public String valFineScaglione;
        public String valCondizione;
    }

    public class OutputRichiestaWrapper {
        public Integer codiceIstituto3N;
        public Integer codPratica;
        public Long codNDG;
        public String ragSocPratica;
        public String codTipoPratica;
        public String desTipoPratica;
        public String codStatoPratica;
        public String desStatoPratica;
        public Long datCreazione; // UNIX TIMESTAMP
        public Long datDelibera; // UNIX TIMESTAMP
        public String codUtenteAttivo;
        public String desUtenteAttivo;
        public String codRuoloAttivo;
        public String codUtenteDeliberante;
        public String desUtenteDeliberante;
        public String codRuoloDeliberante;
        /*MB - LOTTO5(?)*/
        public String flgPraticaSospesa;
        public Integer numGiorniSospCorrente;
        public Integer numGiorniSospTotale;
        public Integer numSospensioni;
        /*MB - LOTTO5(?)*/
        public LineaCredito[] elencoLineeCredito;
        public Nota[] elencoNote;
    }

    public class LineaCredito {
        public Integer numLineaCredito;
        public String codRapportoEst;
        public Long codNdgCedente;
        public String ragSocCedente;
        public String codLineaSistema;
        public String desLineaSistema;
        public String codDivisa;
        public String codGestione;
        public String codStatoLinea;
        public String desStatoLinea;
        public Decimal impAccordatoLinea;
        public Decimal impQuotaNotifica;
        public Decimal impQuotaOneri;
        public Coppia[] elencoCoppie;
    }

    public class Coppia {
        public Long codRandomCoppia;
        public Long ndgDebitore;
        public String ragSocDebitore;
        public String codRapportoEst;
        public Integer numCAR;
        public String codGestione;
        public String codTipoCoppia;
        public String codStatoCoppia;
        public String desStatoCoppia;
        public Decimal impAccordatoCoppia;
        public Decimal impProsolutoCoppia;
        /*MB - LOTTO5(?)*/
        public Long dataInizioValidita;
        public Integer annoFatturaDa;
        public Integer annoFatturaA;
        public String numeroFatturaDa;
        public String numeroFatturaA;
        public Long dataEmissioneDa;
        public Long dataEmissioneA;
        /*MB - LOTTO5(?)*/
    }

    public class Nota {
        public String codTipoNota;
        public String codUtente;
        public Long datInserimNota;
        public Integer numVersione;
        public String desTestoNota;
    }

    public class ErrorDetail {
        public String code;
        public String type;
        public String descr;
        public String soluzione;
    }

    public class PayloadResponse {
        public String resultCode;
        public OutputRichiestaWrapper outputRichiesta;
        public String resultMessage;
        public ErrorDetail[] errorDetails;
    }

    public class PayloadResponse38 {
        public String resultCode;
        public OutputRichiestaWrapper38 outputRichiesta;
        public String resultMessage;
        public ErrorDetail[] errorDetails;
    }

    //input payload
    public class DatiPEFInput  { // extends WsRestInput.CommonInput
        public Integer codiceIstituto3N; // INHERITED FROM CommonInput
        public Long codNdg;
        public Integer codPratica;
    }

    //output payload
    public class DatiPEFResponse extends WsRestInput.CommonResponse {
        public PayloadResponse payload;

        public override Boolean isCorrect() {
            if (payload != null)
            	return payload.resultCode == '0';
           	else
                return false;
        }

    }

    //output payload
    public class DatiPEFResponse38 extends WsRestInput.CommonResponse {
        public PayloadResponse38 payload;

        public override Boolean isCorrect() {
            if (payload != null)
            	return payload.resultCode == '0';
           	else
                return false;
        }

    }

    public static DatiPEFResponse loadDatiPEF(DatiPEFInput input) {
        return (DatiPEFResponse) WsRestUtils.callService(
            'WGC_Url_Dati_PEF__c',
            input,
            DatiPEFResponse.class
        );
    }

    //PEF39 per FF
    public static DatiPEFResponse loadDatiPEF_FF(DatiPEFInput input) {
        //TODO METTI URL: WGC_Url_Dati_PEF_FF__c
        return (DatiPEFResponse) WsRestUtils.callService(
            'WGC_Url_Dati_PEF_FF__c',
            input,
            DatiPEFResponse.class
        );
    }

    //input payload
    public class PEF38Input  {
        public Integer codiceIstituto3N; // INHERITED FROM CommonInput
        public Long codNdg;
        public Integer numLineaCredito;
    }

    //output payload
    // public class PEF38Response extends WsRestInput.CommonResponse {
    //     public PayloadResponse payload;

    //     public override Boolean isCorrect() {
    //         System.debug('@@@@ payload.resultCode: ' + payload.resultCode);
    //         System.debug('@@@@ COND: ' + (payload.resultCode == '0'));
    //         return payload.resultCode == '0';
    //     }

    // }

    public static DatiPEFResponse38 loadPEF38(PEF38Input input) {
        return (DatiPEFResponse38) WsRestUtils.callService(
            'WGC_Url_PEF38__c',
            input,
            DatiPEFResponse38.class
        );
    }

    public class PEF40Input{
        public Integer codiceIstituto3N;
        public Long codNdg;
        public Integer numLineaCredito;
        public String codCanale;
        //A.M. -> Start
        public integer codPratica;
        //A.M. -> End

        public PEF40Input(){
            this.codiceIstituto3N = codiceIstituto3N;
            this.codNdg = codNdg;
            this.numLineaCredito = numLineaCredito;
            this.codCanale = codCanale;
             //A.M. -> Start
            this.codPratica = 0;
            //A.M. -> End
        }

        public PEF40Input(OutputRichiestaWrapper richiesta, LineaCredito lineaCredito, Linea__c lineaCRM){
            this.codiceIstituto3N = richiesta.codiceIstituto3N;
            this.codNdg = richiesta.codNDG;
            this.numLineaCredito = lineaCredito.numLineaCredito;
            this.codCanale = lineaCRM.Opportunity__r.Originator__c + ' - ' + lineaCRM.Opportunity__r.Originator_di_dettaglio__c;
            //A.M. -> Start
            this.codPratica = 0;
            //A.M. -> End
        }
    }

    public class PEF40Output extends WsRestInput.CommonResponse{
        public PEF40OutputPayload payload;

        public PEF40Output(){
            this.payload = payload;
        }

        public override boolean isCorrect(){
            return payload != null && payload.resultCode == '0';
        }
        
        public override String getErrors(){
            String errors = '';

            if (payload != null) {
                if (payload.errorDetails != null) {
                    for (ErrorDetailPEF41 err : payload.errorDetails) {
                        if (err.descr != null){
                            if (errors == '') errors += err.descr;
                            else errors += '; ' + err.descr;
                        }
                    }
                }
            }

            return errors;
        }

    }

    public class PEF40OutputPayload{
        public String resultCode;
        public String resultMessage;
        public List<ErrorDetailPEF41> errorDetails;
        public PEF40OutputRichiesta outputRichiesta;

        public PEF40OutputPayload(){
            this.resultCode = resultCode;
            this.resultMessage = resultMessage;
            this.errorDetails = errorDetails;
            this.outputRichiesta = outputRichiesta;
        }
    }

    public class PEF40OutputRichiesta{
        public Integer codiceIstituto3N;
        public Integer codNdgLinea;
        public Integer numLineaCredito;
        public String codCanale;
        public String esito;

        public PEF40OutputRichiesta(){
            this.codiceIstituto3N = codiceIstituto3N;
            this.codNdgLinea = codNdgLinea;
            this.numLineaCredito = numLineaCredito;
            this.codCanale = codCanale;
            this.esito = esito;
        }
    }


    public static PEF40Output PEF40(PEF40Input input){
        return (PEF40Output)  WsRestUtils.callService(
            'WGC_Url_PEF40__c',
            input,
            PEF40Output.Class
        );
    }

    // PEF41 - START

    public class InputPayloadPEF41 {
        public String IDcarrelloCRM;
        public String flagConsolidamento;
        public String provenienzaPEF;
        public NotaProponente notaProponente;
        public Integer codiceIstituto3N;
        public String codUserID;
        public Long codNDGSoggetto;
        public List<LineaCreditoLCCPEF41> lineeCreditoLCC;
        public Garanzia[] garanzieOmnibus;

        public InputPayloadPEF41() {}
    }

    public class NotaProponente {
        public String testoHTML;
    }

    public class LineaCreditoLCCPEF41 {
        public Decimal importoRichiesto;
        public String codRapportoEsterno;
        public String codCanAcqLCC;
        public Integer numLineaCredito;
        public String codDivisa;
        public Decimal importoQuotaOneri;
        public Long dataScadenzaFido;
        public Parametro[] parametri;
        public FidoCoppia[] fidiCoppia;
        public Garanzia[] garanzie;
        /*MB - LOTTO5(?)*/
        public String codRappCredErariali;
        public String codMercato;
        public String lineaSistema;
        /*MB - LOTTO5(?)*/

        public LineaCreditoLCCPEF41() {
            parametri = new List<Parametro>();
            fidiCoppia = new List<FidoCoppia>();
            garanzie = new List<Garanzia>();
        }
    }

    public class Parametro { // 1.2.5.6
        public String codPara;
        public String codTipoPara;
        public ValoreParametro[] valoriPara;

        public Parametro() {}
    }

    public class ValoreParametro { // 1.2.5.6.3
        public String azioneValPara;
        public Integer prgValPara;
        public String valPara;

        public ValoreParametro() {}
    }

    public class FidoCoppia { // 1.2.5.7
        public String azioneFidoCoppia;
        public Integer codRandomCoppia;
        public Long codNdgDebi;
        public String codTipoCoppia;
        public String codDivisa;
        public Decimal importoRichiestoEndo;
        public Decimal importoRichiestoUto;
        public Long dataInizioValidita;
        public Integer annoFatturaDa;
        public String numeroFatturaDa;
        public Integer annoFatturaA;
        public String numeroFatturaA;
        public Long dataEmissioneDa;
        public Long dataEmissioneA;
        public Parametro[] parametri;

        public FidoCoppia() {
            parametri = new List<Parametro>();
        }
    }

    public class Garanzia { // 1.2.5.8
        public String codTipoGara;
        public String codCodiceGara;
        public String flagProQuota;
        public String codDivisa;
        public Decimal importoGaranzia;
        public Decimal prcGaranzia;
        public Long dataGara;
        public Long dataScadGara;
        public String codRapportoEsterno;
        public Decimal importoRealeGaranzia;
        public Garante[] garanti;

        public Garanzia() {
            garanti = new List<Garante>();
        }
    }

    public class Garante { // 1.2.5.8.9
        public Long codNdgGarante;
        public String codTipoGarante;
        public Decimal importoGarante;
        public Integer prcGarante;

        public Garante() {}
    }

    public class ErrorDetailPEF41 { // 1.4
        public String code;
        public String type;
        public String descr;

        public ErrorDetailPEF41() {}
    }

    public static NotaProponente getNotaProponente(String nota) {
        NotaProponente np = new NotaProponente();
        
        if (nota != null)
            np.testoHTML = nota;

        return np;
    }

    //output payload
    public class PEF41Response extends WsRestInput.CommonResponse {
        public PayloadResponse41 payload;

        public override Boolean isCorrect() {
            if (payload != null)
            	return payload.resultCode == '0';
           	else
                return false;
        }

        public override String getErrors(){
            // String[] errors = new String[] {};
            // if (
            //     headers != null &&
            //     headers.headers != null &&
            //     headers.headers.error_header != null &&
            //     headers.headers.error_header.archErrorList != null
            // ) {
            //     for (Error e : headers.headers.error_header.archErrorList) {
            //     String parsedError = parseError(e.description);
            //     if (String.isNotBlank(parsedError)) {
            //         errors.add(parsedError);
            //     } else {
            //         errors.add('Codice errore: ' + e.code);
            //     }
            //     }
            // }

            // if (String.isNotBlank(exceptionError)) {
            //     if (exceptionError.contains('HTTP Status 404')) {
            //     exceptionError = 'il servizio ha risposto con status 404';
            //     } else if (exceptionError.contains('Unexpected character (\'<\' (code 60))')) {
            //     exceptionError = 'il servizio non ha resituito un json valido.';
            //     }
            //     errors.add(exceptionError);
            // }

            // return String.join(errors, ', ');
            String errors = '';

            if (payload != null) {
                if (payload.errorDetails != null) {
                    for (ErrorDetailPEF41 err : payload.errorDetails) {
                        if (err.descr != null){
                            if (errors == '') errors += err.descr;
                            else errors += '; ' + err.descr;
                        }
                    }
                }
            }

            return errors;
        }

    }

    public class PayloadResponse41 {
        public String resultCode;
        public OutputRichiestaWrapper41 outputRichiesta;
        public String resultMessage;
        public ErrorDetailPEF41[] errorDetails;
    }

    public class OutputRichiestaWrapper41 {
        public Long codiceIstituto3N;
        public Long codNDGSoggetto;
        public String IDcarrelloCRM;
        public String flagConsolidamento;
        public String esitoOperazione;
        public Long codPratica;

        public OutputRichiestaWrapper41() {}
    }

    public static PEF41Response calloutPEF41(Id opportunityId, String userNDG) {
        WsRestCrm.NvAggiornamentoInnescaVenditaInput newOpptyMapping = WsRestCrmUtils.doMapping(opportunityId, true);
        System.debug('@@@@ newOpptyMapping: ' + new WsRestInput(newOpptyMapping).toJSONString());
        Map<String, SObject> lineaMap = (Map<String, SObject>) U.keyBy([SELECT IdProdotto__c, DivisaNew__c, WGC_Numero_Linea_Credito__c, WGC_Accordato__c, WGC_Data_Scadenza_Fido__c FROM Linea__c WHERE Opportunity__c = :opportunityId AND WGC_Numero_Linea_Credito__c != null], 'IdProdotto__c');
        System.debug('@@@@ lineaMap: ' + lineaMap);
        Map<String, List<SObject>> oldValuesParametersPerLine = (Map<String, List<SObject>>) U.groupBy([SELECT Id, Codice__c, Valore__c, WGC_Valore_Pef_38__c, WGC_Valore_Prg_Pef_38__c, Linea__r.WGC_Numero_Linea_Credito__c FROM PConfigurato__c WHERE Linea__r.Opportunity__c = :opportunityId AND Attore__c = null AND (WGC_Parametro_revisionato__c = true OR Codice__c LIKE 'SF%')], 'Linea__r.WGC_Numero_Linea_Credito__c');
        System.debug('@@@@ oldValuesParametersPerLine: ' + oldValuesParametersPerLine);
        Map<String, Integer> codRandomCoppiaMap = new Map<String, Integer>();
        List<JoinLineaDebitore__c> joins = [SELECT Id, WGC_Codice_Random_Coppia__c, Debitore__r.NDG__c, Linea__r.WGC_Numero_Linea_Credito__c FROM JoinLineaDebitore__c WHERE Linea__r.Opportunity__c = :opportunityId AND WGC_Codice_Random_Coppia__c != null];
        for (JoinLineaDebitore__c j : joins)
            codRandomCoppiaMap.put(j.Linea__r.WGC_Numero_Linea_Credito__c + '_' + j.Debitore__r.NDG__c, Integer.valueOf(j.WGC_Codice_Random_Coppia__c));
        System.debug('@@@@ codRandomCoppiaMap: ' + codRandomCoppiaMap);
        Map<String, List<SObject>> oldValuesParametersPerCoppia = (Map<String, List<SObject>>) U.groupBy([SELECT Id, Codice__c, Valore__c, WGC_Valore_Pef_38__c, WGC_Valore_Prg_Pef_38__c, Linea__r.WGC_Numero_Linea_Credito__c, Attore__r.NDG__c FROM PConfigurato__c WHERE Linea__r.Opportunity__c = :opportunityId AND Attore__c != null AND (WGC_Parametro_revisionato__c = true OR Codice__c LIKE 'SF%')], '{Linea__r.WGC_Numero_Linea_Credito__c}_{Attore__r.NDG__c}', true);
        System.debug('@@@@ oldValuesParametersPerCoppia: ' + oldValuesParametersPerCoppia);

        // InputPayloadPEF41 input = (InputPayloadPEF41) JSON.deserialize(JSON.serialize(WGC_RestRevisionePratica.generateResponseDataPayload(newOpptyMapping, lineaMap, opportunityId, userNDG, oldValuesParametersPerLine, true)), InputPayloadPEF41.Class);
        InputPayloadPEF41 input = generateInputDataPayload(newOpptyMapping, lineaMap, opportunityId, userNDG, oldValuesParametersPerLine, oldValuesParametersPerCoppia, codRandomCoppiaMap);

        return (PEF41Response) WsRestUtils.callService(
            'WGC_Url_PEF41__c',
            input,
            PEF41Response.class
        );
    }

    public static InputPayloadPEF41 generateInputDataPayload(WsRestCrm.NvAggiornamentoInnescaVenditaInput newOpptyMapping, Map<String, SObject> lineaMap, String idSistemaEsterno, String userNDG, Map<String, List<SObject>> oldValuesParametersPerLine, Map<String, List<SObject>> oldValuesParametersPerCoppia, Map<String, Integer> codRandomCoppiaMap) {
        InputPayloadPEF41 inpR = new InputPayloadPEF41();
        List<LineaCreditoLCCPEF41> lineeCreditoLCC = new List<LineaCreditoLCCPEF41>();

        inpR = fillInputRichiestaInfo(newOpptyMapping, idSistemaEsterno, userNDG);

        if (newOpptyMapping.prodotti != null)
            if (newOpptyMapping.prodotti.prodotto.size() > 0)
                for (WsRestCrm.Prodotto prodotto : newOpptyMapping.prodotti.prodotto) { // LINEE DI CREDITO
                    LineaCreditoLCCPEF41 lcc = new LineaCreditoLCCPEF41();
                    System.debug('@Prodotto: '+prodotto);
                    System.debug('@lineaMap: '+ lineaMap);
                    System.debug('@oldValuesParametersPerLine: '+ oldValuesParametersPerLine);
                    String lineCode = String.valueOf(prodotto.idProdotto).leftPad(6,'0');
                    System.debug('@@@@ lineaMap.get(lineCode): ' + lineaMap.get(lineCode));
                    if (lineaMap.get(lineCode) != null) {
                        lcc = fillLineaCreditoLCCInfo(prodotto, lineaMap, oldValuesParametersPerLine, oldValuesParametersPerCoppia, codRandomCoppiaMap);
                        lineeCreditoLCC.add(lcc);
                    }
                }

        inpR.lineeCreditoLCC = lineeCreditoLCC;

        return inpR;
    }
    
    private static InputPayloadPEF41 fillInputRichiestaInfo(WsRestCrm.NvAggiornamentoInnescaVenditaInput newOpptyMapping, String IDcarrelloCRM, String userNDG) {
        InputPayloadPEF41 inputPEF41 = new InputPayloadPEF41();
        inputPEF41.IDcarrelloCRM = IDcarrelloCRM;
        inputPEF41.flagConsolidamento = 'N'; // opp[0].WGC_FlagConsolidamento__c == true ? 'S' : 'N'
        inputPEF41.provenienzaPEF = '';
        
        inputPEF41.codiceIstituto3N = (Integer) newOpptyMapping.codiceIstituto3N;
        inputPEF41.codNDGSoggetto = newOpptyMapping.intestatario;
        inputPEF41.codUserID = userNDG;
        // inputPEF41.IDcarrelloCRM = IDcarrelloCRM;
        inputPEF41.garanzieOmnibus = (newOpptyMapping.associazioneGaranziaOmnibus != null ? getGaranzie(newOpptyMapping.associazioneGaranziaOmnibus.garanzia) : new Garanzia[]{});
        inputPEF41.notaProponente = getNotaProponente(newOpptyMapping.noteIstruttoria);

        return inputPEF41;
    }
    @TestVisible
    private static LineaCreditoLCCPEF41 fillLineaCreditoLCCInfo(WsRestCrm.Prodotto prodotto, Map<String, SObject> lineaMap, Map<String, List<SObject>> oldValuesParametersPerLine, Map<String, List<SObject>> oldValuesParametersPerCoppia, Map<String, Integer> codRandomCoppiaMap) {
        WGC_WSUtils_Cart.LineaCreditoLCCPEF41 lccPEF41 = new WGC_WSUtils_Cart.LineaCreditoLCCPEF41();
        String lineCode = String.valueOf(prodotto.idProdotto).leftPad(6,'0');
        List<PConfigurato__c> revisionedParameters = (List<PConfigurato__c>) oldValuesParametersPerLine.get(((Linea__c)lineaMap.get(lineCode)).WGC_Numero_Linea_Credito__c);
        Map<String, SObject> revisionedParametersMap = (Map<String, SObject>) U.keyBy(revisionedParameters, 'Codice__c');

        // lccPEF41.importoRichiesto = Decimal.valueOf(((PConfigurato__c) revisionedParametersMap.get('SF6')).Valore__c);
        lccPEF41.importoRichiesto = (revisionedParametersMap.get('SF6') != null ? Decimal.valueOf(((PConfigurato__c) revisionedParametersMap.get('SF6')).Valore__c) : ((Linea__c) lineaMap.get(lineCode)).WGC_Accordato__c);
        lccPEF41.codRapportoEsterno = '';
        lccPEF41.codCanAcqLCC = '';
        System.debug('@@@@ revisionedParametersMap: ' + revisionedParametersMap);
        System.debug('@@@@ lineCode: ' + lineCode);
        System.debug('@@@@ linea: ' + (Linea__c) lineaMap.get(lineCode));
        lccPEF41.numLineaCredito = Integer.valueOf(((Linea__c) lineaMap.get(lineCode)).WGC_Numero_Linea_Credito__c);
        // lcc.importoQuotaOneri = prodotto.idProdotto;
        // lcc.importoRichiesto = ((Linea__c) lineaMap.get(lineCode)).WGC_Accordato__c;
        // lccPEF41.dataScadenzaFido = ((Datetime) ((Linea__c) lineaMap.get(lineCode)).WGC_Data_Scadenza_Fido__c).getTime();
        lccPEF41.dataScadenzaFido = null;
        lccPEF41.codDivisa = ((Linea__c) lineaMap.get(lineCode)).DivisaNew__c;
        lccPEF41.garanzie = (prodotto.associazioneGaranzie != null ? getGaranzie(prodotto.associazioneGaranzie.garanzia) : new Garanzia[]{});
        lccPEF41.fidiCoppia = (prodotto.fidiCoppia != null ? getFidiCoppia(prodotto.fidiCoppia.fidoCoppia, oldValuesParametersPerCoppia, ((Linea__c) lineaMap.get(lineCode)).WGC_Numero_Linea_Credito__c, codRandomCoppiaMap) : new FidoCoppia[]{});
        lccPEF41.parametri = (prodotto.parametriAggiuntivi != null ? getParametri(prodotto.parametriAggiuntivi.parametro, revisionedParametersMap) : new Parametro[]{});

        //SM - TEN: Fix per Crediti Erariali e revisioni
        lccPEF41.codRappCredErariali = '${NULL}';

        return lccPEF41;
    }
    @TestVisible
    private static FidoCoppia[] getFidiCoppia(WsRestCrm.FidoCoppia[] fidoCoppiaList, Map<String, List<SObject>> oldValuesParametersPerCoppia, String numLineaCredito, Map<String, Integer> codRandomCoppiaMap) {
        if (fidoCoppiaList.size() == 0)
            return new FidoCoppia[]{};

        FidoCoppia[] res = new FidoCoppia[]{};
        for (WsRestCrm.FidoCoppia fc : fidoCoppiaList) {
            FidoCoppia tmp = new FidoCoppia();
            List<PConfigurato__c> revisionedParameters = (List<PConfigurato__c>) oldValuesParametersPerCoppia.get(numLineaCredito + '_' + fc.codNdgDebi);
            Map<String, SObject> revisionedParametersPerCoppiaMap = (Map<String, SObject>) U.keyBy(revisionedParameters, 'Codice__c');
            // tmp.azioneFidoCoppia = 'M';
            //SM - TEN: Controllo per capire se è nuovo o "vecchio" (Revisionato)
            tmp.azioneFidoCoppia = codRandomCoppiaMap.get(numLineaCredito + '_' + fc.codNdgDebi) != null ? 'M' : 'N';
            tmp.codRandomCoppia = codRandomCoppiaMap.get(numLineaCredito + '_' + fc.codNdgDebi);
            tmp.codNdgDebi = fc.codNdgDebi;
            tmp.codTipoCoppia = fc.codTipoCoppia;
            tmp.codDivisa = fc.codDivisa;
            //SM-CART-REVI
            tmp.importoRichiestoEndo = revisionedParametersPerCoppiaMap.get('SF25') != null ? Decimal.valueOf(String.valueOf(revisionedParametersPerCoppiaMap.get('SF25').get('Valore__c'))) : fc.importoRichiestoEndo;
            tmp.importoRichiestoUto = revisionedParametersPerCoppiaMap.get('SF26') != null ? Decimal.valueOf(String.valueOf(revisionedParametersPerCoppiaMap.get('SF26').get('Valore__c'))) : fc.importoRichiestoUto != null ? fc.importoRichiestoUto : 0;
            tmp.dataInizioValidita = fc.dataInizioValidita;
            tmp.annoFatturaDa = null;
            tmp.numeroFatturaDa = '';
            tmp.annoFatturaA = null;
            tmp.numeroFatturaA = '';
            tmp.dataEmissioneDa = null;
            tmp.dataEmissioneA = null;

            tmp.parametri = (fc.parametriFidoCoppia != null ? getParametri(fc.parametriFidoCoppia.parametro, revisionedParametersPerCoppiaMap) : null);
            System.debug('@@@ tmp.parametri ' + JSON.serialize(tmp.parametri));

            res.add(tmp);
        }
        return res;
    }
    @TestVisible
    private static Parametro[] getParametri(WsRestCrm.Parametro[] parametroList, Map<String, SObject> revisionedParametersMap) {
        if (parametroList.size() == 0)
            return new Parametro[]{};
        
        Parametro[] res = new Parametro[]{};
        for (WsRestCrm.Parametro p : parametroList) {
            if (!CODES_TO_BE_REMOVED.contains(p.codice)) {
                Parametro tmp = new Parametro();
                tmp.codPara = p.codice;
                tmp.codTipoPara = p.codTipoPara;

                tmp.valoriPara = (p.valoriParametro != null ? getValoriParametro(p.valoriParametro.valoreParametro, p.codTipoPara, (PConfigurato__c) revisionedParametersMap.get(p.codice)) : null);

                res.add(tmp);
            }
        }
        return res;
    }
    @TestVisible
    private static ValoreParametro[] getValoriParametro(WsRestCrm.ValoreParametro[] valoriParametroList, String codTipoPara, PConfigurato__c pConf) {
        if (pConf == null)
            return new ValoreParametro[]{};
        System.debug('@@@@ valoriParametroList: ' + valoriParametroList);
        System.debug('@@@@ pConf: ' + pConf);
        ValoreParametro[] res = new ValoreParametro[]{};
        List<String> newValues = pConf.Valore__c != null ? pConf.Valore__c.split(';') : new List<String>();
        List<String> oldValues = pConf.WGC_Valore_Pef_38__c != null ? pConf.WGC_Valore_Pef_38__c.split(';') : new List<String>();
        List<String> allValues = new List<String>();
        allValues.addAll(newValues);
        allValues.addAll(oldValues);

        List<String> oldPrgValues = pConf.WGC_Valore_Prg_Pef_38__c != null ? pConf.WGC_Valore_Prg_Pef_38__c.split(';') : new List<String>();
        Map<String, Integer> oldPrgValuesMap = new Map<String, Integer>();
        for (String oldPrgVal : oldPrgValues) oldPrgValuesMap.put(oldPrgVal.split(':')[1], Integer.valueOf(oldPrgVal.split(':')[0]));
        
        List<Integer> prgValues = oldPrgValuesMap.values();
        prgValues.sort();
        Integer newPrgValPara = (prgValues.size() > 0 ? prgValues.get(prgValues.size()-1)+1 : 1);

        if (codTipoPara != 'C') {
            ValoreParametro tmp = new ValoreParametro();
            tmp.azioneValPara = (pConf.WGC_Valore_Pef_38__c == null ? 'I' : 'M');

            if (pConf.WGC_Valore_Prg_Pef_38__c == null) // se parametro nuovo, progressivo = 1
                tmp.prgValPara = 1;
            else // altrimenti recupero il progressivo
                tmp.prgValPara = Integer.valueOf(pConf.WGC_Valore_Prg_Pef_38__c.split(':')[0]);

            tmp.valPara = pConf.Valore__c;
                
            res.add(tmp);
        } else {
            for (String val : allValues) {
                ValoreParametro tmp = new ValoreParametro();
                if (oldValues.contains(val) && !newValues.contains(val))
                    tmp.azioneValPara = 'C';
                else if (!oldValues.contains(val) && newValues.contains(val))
                    tmp.azioneValPara = 'I';
                
                if (tmp.azioneValPara != null) {
                    tmp.valPara = val;
                    if (tmp.azioneValPara == 'C')
                        tmp.prgValPara = oldPrgValuesMap.get(val);
                    else if (tmp.azioneValPara == 'I') {
                        tmp.prgValPara = newPrgValPara;
                        newPrgValPara++;
                    }
                    else if (tmp.azioneValPara == 'M')
                        tmp.prgValPara = newPrgValPara;

                    if (tmp.azioneValPara == 'C' && res.size() > 0)
                        res.add(0, tmp);
                    else
                        res.add(tmp);
                }
            }
        }

        // for (String val : allValues) {
        //     ValoreParametro tmp = new ValoreParametro();
        //     if (codTipoPara != 'C')
        //         tmp.azioneValPara = (oldPrgValuesMap.get(val) == null ? 'I' : 'M');
        //     else {
        //         if (oldValues.contains(val) && !newValues.contains(val))
        //             tmp.azioneValPara = 'C';
        //         else if (!oldValues.contains(val) && newValues.contains(val))
        //             tmp.azioneValPara = 'I';
        //     }

        //     if (tmp.azioneValPara != null) {
        //         tmp.valPara = val;
        //         if (tmp.azioneValPara == 'C')
        //             tmp.prgValPara = oldPrgValuesMap.get(val);
        //         else if (tmp.azioneValPara == 'I') {
        //             tmp.prgValPara = newPrgValPara;
        //             newPrgValPara++;
        //         }
        //         else if (tmp.azioneValPara == 'M')
        //             tmp.prgValPara = newPrgValPara;

        //         res.add(tmp);
        //     }
        // }

        return res;
    }
    @TestVisible
    private static Garanzia[] getGaranzie(WsRestCrm.Garanzia[] garanzie) {
        if (garanzie.size() == 0)
            return new Garanzia[]{};
        
        Garanzia[] res = new Garanzia[]{};
        for (WsRestCrm.Garanzia g : garanzie) {
            Garanzia tmp = new Garanzia();
            tmp.codRapportoEsterno = '';
            tmp.importoRealeGaranzia = 0;
            // tmp.codTipoGara = g.codTipoGara;
            tmp.codTipoGara = '';
            tmp.codCodiceGara = g.codiceGaranzia;
            tmp.flagProQuota = g.flagProQuota;
            tmp.codDivisa = g.divisa;
            tmp.importoGaranzia = g.importo;
            tmp.prcGaranzia = g.prcGaranzia;
            tmp.dataGara = g.dataGara;
            tmp.dataScadGara = g.dataScadGara;

            tmp.garanti = (g.referenti != null ? getGaranti(g.referenti.referente) : null);

            res.add(tmp);
        }
        return res;
    }
    @TestVisible
    private static Garante[] getGaranti(WsRestCrm.Referente[] referenti) {
        if (referenti.size() == 0)
            return new Garante[]{};
        
        Garante[] res = new Garante[]{};
        for (WsRestCrm.Referente ref : referenti) {
            Garante tmp = new Garante();
            tmp.codNdgGarante = ref.ndg;
            tmp.codTipoGarante = ref.codTipoGarante;
            tmp.importoGarante = ref.importoGarante;
            tmp.prcGarante = Integer.valueOf(ref.percentuale); // CONVERSION FROM DECIMAL TO INTEGER

            res.add(tmp);
        }
        return res;
    }

    // PEF41 - END

    // ANAG70

    public class PayloadResponseANAG70 extends WsRestInput.CommonResponse {
        public ANAG70OutputPayload payload;
        // public OutputRichiestaWrapper41 outputRichiesta;
        // public String resultMessage;
        // public ErrorDetail[] errorDetails;
        
        public override Boolean isCorrect() {
            if (payload != null)
            	return payload.returnCode == '0';
           	else
                return false;
        }

    }

    public class InputPayloadANAG70 {
        public String ndgSoggetto;
        public String ndgGestore;
        public String codTipoRela;
        public String service;
        public String codMotiPart;
        public String codTipoPart;

        public InputPayloadANAG70() {}
    }

    public class ANAG70OutputPayload {
        public String message;
        public String returnCode;
    }

    public static PayloadResponseANAG70 callANAG70(InputPayloadANAG70 input){
        return (PayloadResponseANAG70)  WsRestUtils.callService(
            'WGC_Url_ANAG70__c',
            input,
            PayloadResponseANAG70.Class
        );
    }

    // ANAG70 - END

    // ANAG11 - START

    public class InputPayloadAnag11{
        @AuraEnabled public Integer codiceIstituto3N;
        @AuraEnabled public String idApplicazioneChiamante;
        @AuraEnabled public String idSessioneChiamante;
        @AuraEnabled public String lingua;
        @AuraEnabled public String idOperazione;
        @AuraEnabled public String utenzaCanale;
        @AuraEnabled public Long ndg;
        @AuraEnabled public String tipoRapporto;
        @AuraEnabled public String servizio;
        @AuraEnabled public String codiceBox;
        @AuraEnabled public String flagStorico;
        @AuraEnabled public String flagStampa;

        public InputPayloadAnag11(String AccNdg, Boolean storico, Boolean stampa){
            this.codiceIstituto3N = 881;
            this.idApplicazioneChiamante = idApplicazioneChiamante;
            this.idSessioneChiamante = idSessioneChiamante;
            this.lingua = lingua;
            this.idOperazione = idOperazione;
            this.utenzaCanale = utenzaCanale;
            this.ndg = Long.valueOf(AccNdg);
            this.tipoRapporto = 'T'; // Valori possibili: 'E', 'T'
            this.servizio = servizio;
            this.codiceBox = codiceBox;
            this.flagStorico = storico ? 'S' : 'N';// Valori possibili: 'N', 'S'
            this.flagStampa = stampa ? 'S' : 'N';// Valori possibili: 'N', 'S'
        }
    }

    public class PayloadResponseAnag11 extends WsRestInput.CommonResponse{
        @AuraEnabled public OutputPayloadAnag11 payload;

        public override Boolean isCorrect(){
            return payload != null;
        }
    }

    public class OutputPayloadAnag11 {
        @AuraEnabled public Integer recordTotali;
        @AuraEnabled public Integer rapportiEstratti;
        @AuraEnabled public Integer rapportiEstinti;
        @AuraEnabled public Integer rapportiInEssere;
        @AuraEnabled public TabellaIndirizzi tabellaIndirizzi;
        @AuraEnabled public TabellaIndirizzi tabellaIndirizziDelNominativo;
        @AuraEnabled public TabellaRapporti tabellaRapporti;
    }

    public class TabellaIndirizzi{
        @AuraEnabled public List<String> indirizzi;

        public TabellaIndirizzi(List<String> indirizzi){
            this.indirizzi = indirizzi;
        }
    }

    public class TabellaRapporti{
        @AuraEnabled public List<DatiRapporto> datiRapporto;
    }

    public class DatiRapporto{
        @AuraEnabled public String tipoOperativita;
        @AuraEnabled public String flagEstinto;
        @AuraEnabled public String codiceRapportoNonNumerico;
        @AuraEnabled public Rapporto rapporto;
        @AuraEnabled public String categoriaSottocategoria;
        @AuraEnabled public String descrizioneCategSottocateg;
        @AuraEnabled public Long dataAccesione;
        @AuraEnabled public Long dataVariazione;
        @AuraEnabled public String flagIndirizzoPersonale;
        @AuraEnabled public TabellaIndirizzi tabellaIndirizziRapporto;
        @AuraEnabled public TabellaIndirizzi tabellaIndirizziDelRapporto;
        @AuraEnabled public String flagRapportoPersonale;
        @AuraEnabled public String programmaDiAggiornamento;
        @AuraEnabled public String descrizioneSaldo;
        @AuraEnabled public String codiceBox;
        @AuraEnabled public String flagBox;
    }

    public class Rapporto{
        @AuraEnabled public Integer servizio;
        @AuraEnabled public Integer filiale;
        @AuraEnabled public Long conto;
    }

    public static PayloadResponseAnag11 callAnag11(InputPayloadAnag11 input){
        return (PayloadResponseAnag11)  WsRestUtils.callService(
            'WGC_Url_ANAG11__c',
            input,
            PayloadResponseAnag11.Class
        );
    }

    // ANAG11 - END

}