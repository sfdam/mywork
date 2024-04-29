@RestResource(urlMapping = '/RevisionePratica')
global with sharing class WGC_RestRevisionePratica { // PEF42
    public final static List<String> CODES_TO_BE_REMOVED = new List<String> {'008','FAS','PLA','DUR'};

    private WGC_RestRevisionePratica() {}

    @HttpPost
    global static ResponseObject revisionePratica(
        RestCommon.TechInfo techInfo,
        RevisionePraticaInputPayload payload
    ) {
        RevisionePraticaPayload payloadResponse = new RevisionePraticaPayload();
        ResponseObject response;

        try {
            List<Opportunity> opp = [SELECT Id FROM Opportunity WHERE IdCartella__c = :payload.idSistemaEsterno];
            // User currentUser = [SELECT Id, NDGGruppo__c FROM User WHERE Id = :UserInfo.getUserId()];

            if (opp.size() == 0) {
                // payloadResponse.resultCode = '1.0';
                payloadResponse.resultCode = 100;
                payloadResponse.resultMessage = 'Nessuna opportunità corrispondente al valore fornito per \'idSistemaEsterno\'.';
                response = new ResponseObject(null, payloadResponse.resultCode, payloadResponse.resultMessage);
            } else if (opp.size() > 1) {
                // payloadResponse.resultCode = '1.1';
                payloadResponse.resultCode = 110;
                payloadResponse.resultMessage = 'Multiple opportunità corrispondenti al valore fornito per \'idSistemaEsterno\'.';
                response = new ResponseObject(null, payloadResponse.resultCode, payloadResponse.resultMessage);
            } else {
                Opportunity opportunity = opp[0];
                WsRestCrm.NvAggiornamentoInnescaVenditaInput newOpptyMapping = WsRestCrmUtils.doMapping(opportunity.Id, true);
                Map<String, SObject> lineaMap = (Map<String, SObject>) U.keyBy([SELECT IdProdotto__c, DivisaNew__c, WGC_Numero_Linea_Credito__c, WGC_Accordato__c, WGC_Data_Scadenza_Fido__c FROM Linea__c WHERE Opportunity__r.IdCartella__c = :payload.idSistemaEsterno AND WGC_Numero_Linea_Credito__c != null], 'IdProdotto__c');
                System.debug('@@@@ lineaMap: ' + lineaMap);
                Map<String, List<SObject>> oldValuesParametersPerLine = (Map<String, List<SObject>>) U.groupBy([SELECT Id, Codice__c, Valore__c, WGC_Valore_Pef_38__c, WGC_Valore_Prg_Pef_38__c, Linea__r.WGC_Numero_Linea_Credito__c FROM PConfigurato__c WHERE Linea__r.Opportunity__r.IdCartella__c = :payload.idSistemaEsterno AND Attore__c = null AND (WGC_Parametro_revisionato__c = true OR Codice__c LIKE 'SF%')], 'Linea__r.WGC_Numero_Linea_Credito__c');
                System.debug('@@@@ oldValuesParametersPerLine: ' + oldValuesParametersPerLine);
                Map<String, Integer> codRandomCoppiaMap = new Map<String, Integer>();
                List<JoinLineaDebitore__c> joins = [SELECT Id, WGC_Codice_Random_Coppia__c, Debitore__r.NDG__c, Linea__r.WGC_Numero_Linea_Credito__c FROM JoinLineaDebitore__c WHERE Linea__r.Opportunity__r.IdCartella__c = :payload.idSistemaEsterno AND WGC_Codice_Random_Coppia__c != null];
                for (JoinLineaDebitore__c j : joins)
                    codRandomCoppiaMap.put(j.Linea__r.WGC_Numero_Linea_Credito__c + '_' + j.Debitore__r.NDG__c, Integer.valueOf(j.WGC_Codice_Random_Coppia__c));
                System.debug('@@@@ codRandomCoppiaMap: ' + codRandomCoppiaMap);
                Map<String, List<SObject>> oldValuesParametersPerCoppia = (Map<String, List<SObject>>) U.groupBy([SELECT Id, Codice__c, Valore__c, WGC_Valore_Pef_38__c, WGC_Valore_Prg_Pef_38__c, Linea__r.WGC_Numero_Linea_Credito__c, Attore__r.NDG__c FROM PConfigurato__c WHERE Linea__r.Opportunity__r.IdCartella__c = :payload.idSistemaEsterno AND Attore__c != null AND  (WGC_Parametro_revisionato__c = true OR Codice__c LIKE 'SF%')], '{Linea__r.WGC_Numero_Linea_Credito__c}_{Attore__r.NDG__c}', true);
                System.debug('@@@@ oldValuesParametersPerCoppia: ' + oldValuesParametersPerCoppia);
                List<String> fidiCoppiaCodes = new List<String>();
                for (Integer cod : codRandomCoppiaMap.values())
                    fidiCoppiaCodes.add(String.valueOf(cod));

                Map<String, SObject> codTipoCoppiaMap = (Map<String, SObject>) U.keyBy([SELECT Id, Name, Codice_famiglia_coppia__c FROM WGC_Fido_di_Coppia__c WHERE Name IN :fidiCoppiaCodes], 'Name');

System.debug('@@@@ payload: ' + payload);
System.debug('@@@@ payload.idSistemaEsterno: ' + payload.idSistemaEsterno);
System.debug('@@@@ payload.codUserID: ' + payload.codUserID);
                // payloadResponse.outputRichiesta = (OutputRichiesta) JSON.deserialize(JSON.serialize(generateResponseDataPayload(newOpptyMapping, lineaMap, payload.idSistemaEsterno, currentUser.NDGGruppo__c, oldValuesParametersPerLine, false)), OutputRichiesta.Class);
                payloadResponse.outputRichiesta = generateResponseDataPayload(newOpptyMapping, lineaMap, payload.idSistemaEsterno, payload.codUserID, oldValuesParametersPerLine, oldValuesParametersPerCoppia, codRandomCoppiaMap, codTipoCoppiaMap);
                // payloadResponse.resultCode = '0';
                payloadResponse.resultCode = 0;
                response = new ResponseObject(payloadResponse, payloadResponse.resultCode, payloadResponse.resultMessage);
            }
        } catch (Exception e) {
            response = new ResponseObject(null, 99, e.getStackTraceString() + ' - ' + e.getMessage());
        }

        RestCommon.logInboundMessage('Revisione Pratica PEF42', new Object[] {payload}, response);

        return response;
    }

    // public static GenericRevRinPayload generateResponseDataPayload(WsRestCrm.NvAggiornamentoInnescaVenditaInput newOpptyMapping, Map<String, SObject> lineaMap, String idSistemaEsterno, String userNDG, Map<String, List<SObject>> oldValuesParametersPerLine) {return generateResponseDataPayload(newOpptyMapping, lineaMap, idSistemaEsterno, '', oldValuesParametersPerLine, false);}
    public static OutputRichiesta generateResponseDataPayload(
            WsRestCrm.NvAggiornamentoInnescaVenditaInput newOpptyMapping,
            Map<String, SObject> lineaMap,
            String idSistemaEsterno,
            Long userNDG,
            Map<String, List<SObject>> oldValuesParametersPerLine,
            Map<String, List<SObject>> oldValuesParametersPerCoppia,
            Map<String, Integer> codRandomCoppiaMap,
            Map<String, SObject> codTipoCoppiaMap
        ) {
            OutputRichiesta outR = new OutputRichiesta();
            List<LineaCreditoLCCPEF42> lineeCreditoLCC = new List<LineaCreditoLCCPEF42>();

            outR = fillOutputRichiestaInfo(newOpptyMapping, idSistemaEsterno, userNDG);

            if (newOpptyMapping.prodotti != null)
                if (newOpptyMapping.prodotti.prodotto.size() > 0)
                    for (WsRestCrm.Prodotto prodotto : newOpptyMapping.prodotti.prodotto) { // LINEE DI CREDITO
                        LineaCreditoLCCPEF42 lcc = new LineaCreditoLCCPEF42();
                        System.debug('@Prodotto: '+prodotto);
                        System.debug('@lineaMap: '+ lineaMap);
                        System.debug('@oldValuesParametersPerLine: '+ oldValuesParametersPerLine);
                        String lineCode = String.valueOf(prodotto.idProdotto).leftPad(6,'0');
                        System.debug('@@@@ lineaMap.get(lineCode): ' + lineaMap.get(lineCode));
                        if (lineaMap.get(lineCode) != null) {
                            lcc = fillLineaCreditoLCCInfo(prodotto, lineaMap, oldValuesParametersPerLine, oldValuesParametersPerCoppia, codRandomCoppiaMap, codTipoCoppiaMap);
                            lineeCreditoLCC.add(lcc);
                        }
                    }

            outR.lineeCreditoLCC = lineeCreditoLCC;

            return outR;
    }

    public static OutputRichiesta fillOutputRichiestaInfo(WsRestCrm.NvAggiornamentoInnescaVenditaInput newOpptyMapping, String IDcarrelloCRM, Long userNDG) {
            OutputRichiesta outputPEF42 = new OutputRichiesta();
            outputPEF42.IDsistemaEsterno = IDcarrelloCRM;

            outputPEF42.codiceIstituto3N = (Integer) newOpptyMapping.codiceIstituto3N;
            outputPEF42.codNDGSoggetto = newOpptyMapping.intestatario;
            outputPEF42.codUserID = userNDG;
            // outputPEF42.IDcarrelloCRM = IDcarrelloCRM;
            // ATTUALMENTE NON PREVISTE MODIFICHE A GARANZIE IN REVISIONE/RINNOVO --> NODO MAPPATO A VUOTO
            // outputPEF42.garanzieOmnibus = (newOpptyMapping.associazioneGaranziaOmnibus != null ? getGaranzie(newOpptyMapping.associazioneGaranziaOmnibus.garanzia) : new Garanzia[]{});
            outputPEF42.garanzieOmnibus = new Garanzia[]{};
            // outputPEF42.notaProponente = getNotaProponente(newOpptyMapping.noteIstruttoria);

            return outputPEF42;
        // }
    }
    @TestVisible
    public static LineaCreditoLCCPEF42 fillLineaCreditoLCCInfo(
            WsRestCrm.Prodotto prodotto,
            Map<String, SObject> lineaMap,
            Map<String, List<SObject>> oldValuesParametersPerLine,
            Map<String, List<SObject>> oldValuesParametersPerCoppia,
            Map<String, Integer> codRandomCoppiaMap,
            Map<String, SObject> codTipoCoppiaMap
        ) {
            LineaCreditoLCCPEF42 lccPEF42 = new LineaCreditoLCCPEF42();
            String lineCode = String.valueOf(prodotto.idProdotto).leftPad(6,'0');
            List<PConfigurato__c> revisionedParameters = (List<PConfigurato__c>) oldValuesParametersPerLine.get(((Linea__c)lineaMap.get(lineCode)).WGC_Numero_Linea_Credito__c);
            Map<String, SObject> revisionedParametersMap = (Map<String, SObject>) U.keyBy(revisionedParameters, 'Codice__c');

            lccPEF42.importoAccordato = (revisionedParametersMap.get('SF6') != null ? Decimal.valueOf(((PConfigurato__c) revisionedParametersMap.get('SF6')).Valore__c) : ((Linea__c) lineaMap.get(lineCode)).WGC_Accordato__c);
            //System.debug('@@@@ importoAccordato: ' + revisionedParametersMap.get('SF6') != null ? Decimal.valueOf(((PConfigurato__c) revisionedParametersMap.get('SF6')).Valore__c) : ((Linea__c) lineaMap.get(lineCode)).WGC_Accordato__c);
            System.debug('@@@@ lineCode: ' + lineCode);
            System.debug('@@@@ linea: ' + (Linea__c) lineaMap.get(lineCode));
            lccPEF42.numLineaCredito = Integer.valueOf(((Linea__c) lineaMap.get(lineCode)).WGC_Numero_Linea_Credito__c);
            // lcc.importoQuotaOneri = prodotto.idProdotto;
            // lcc.importoRichiesto = ((Linea__c) lineaMap.get(lineCode)).WGC_Accordato__c;
            // lccPEF42.dataScadenzaFido = ((Datetime) ((Linea__c) lineaMap.get(lineCode)).WGC_Data_Scadenza_Fido__c).getTime();
            lccPEF42.dataScadenzaFido = null;
            lccPEF42.codDivisa = ((Linea__c) lineaMap.get(lineCode)).DivisaNew__c;
            // ATTUALMENTE NON PREVISTE MODIFICHE A GARANZIE IN REVISIONE/RINNOVO --> NODO MAPPATO A VUOTO
            // lccPEF42.garanzie = (prodotto.associazioneGaranzie != null ? getGaranzie(prodotto.associazioneGaranzie.garanzia) : new Garanzia[]{});
            lccPEF42.garanzie = new Garanzia[]{};
            lccPEF42.fidiCoppia = (prodotto.fidiCoppia != null ? getFidiCoppia(prodotto.fidiCoppia.fidoCoppia, oldValuesParametersPerCoppia, ((Linea__c) lineaMap.get(lineCode)).WGC_Numero_Linea_Credito__c, codRandomCoppiaMap, codTipoCoppiaMap) : new FidoCoppia[]{});
            lccPEF42.parametri = (prodotto.parametriAggiuntivi != null ? getParametri(prodotto.parametriAggiuntivi.parametro, revisionedParametersMap) : new Parametro[]{});

            return lccPEF42;
        // }
    }
    @TestVisible
    private static FidoCoppia[] getFidiCoppia(WsRestCrm.FidoCoppia[] fidoCoppiaList, Map<String, List<SObject>> oldValuesParametersPerCoppia, String numLineaCredito, Map<String, Integer> codRandomCoppiaMap, Map<String, SObject> codTipoCoppiaMap) {
        if (fidoCoppiaList.size() == 0)
            return new FidoCoppia[]{};
        
        FidoCoppia[] res = new FidoCoppia[]{};
        for (WsRestCrm.FidoCoppia fc : fidoCoppiaList) {
            FidoCoppia tmp = new FidoCoppia();
            List<PConfigurato__c> revisionedParameters = (List<PConfigurato__c>) oldValuesParametersPerCoppia.get(numLineaCredito + '_' + fc.codNdgDebi);
            Map<String, SObject> revisionedParametersPerCoppiaMap = (Map<String, SObject>) U.keyBy(revisionedParameters, 'Codice__c');
            Integer codRandomCoppia = codRandomCoppiaMap.get(numLineaCredito + '_' + fc.codNdgDebi);

            tmp.azioneFidoCoppia = codRandomCoppia != null ? 'V' : 'N'; // 'M'
            tmp.codRandomCoppia = codRandomCoppia != null ? codRandomCoppiaMap.get(numLineaCredito + '_' + fc.codNdgDebi) : null;
            tmp.codNdgDebi = fc.codNdgDebi;
            //SM - TEN: Ticket TENAM-191 aggiunto controllo su presenza fido di coppia
            tmp.codTipoCoppia = codRandomCoppia != null ? ((WGC_Fido_di_Coppia__c)codTipoCoppiaMap.get(String.valueOf(codRandomCoppiaMap.get(numLineaCredito + '_' + fc.codNdgDebi)))).Codice_famiglia_coppia__c : fc.codTipoCoppia;
            tmp.codDivisa = fc.codDivisa;
            tmp.importoRichiestoEndo = fc.importoRichiestoEndo;
            tmp.importoRichiestoUto = fc.importoRichiestoUto;
            tmp.dataInizioValidita = fc.dataInizioValidita;
            tmp.annoFatturaDa = null;
            tmp.numeroFatturaDa = '';
            tmp.annoFatturaA = null;
            tmp.numeroFatturaA = '';
            tmp.dataEmissioneDa = null;
            tmp.dataEmissioneA = null;

            tmp.parametri = (fc.parametriFidoCoppia != null ? getParametri(fc.parametriFidoCoppia.parametro, revisionedParametersPerCoppiaMap) : null);

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
            tmp.azioneValPara = (pConf.WGC_Valore_Pef_38__c == null ? 'N' : 'V');

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
                    tmp.azioneValPara = 'N';
                
                if (tmp.azioneValPara != null) {
                    tmp.valPara = val;
                    if (tmp.azioneValPara == 'C')
                        tmp.prgValPara = oldPrgValuesMap.get(val);
                    else if (tmp.azioneValPara == 'N') {
                        tmp.prgValPara = newPrgValPara;
                        newPrgValPara++;
                    }
                    else if (tmp.azioneValPara == 'V')
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
            tmp.codTipoGaranzia = g.codTipoGara;
            tmp.codCodiceGaranzia = g.codiceGaranzia;
            tmp.flagProQuota = g.flagProQuota;
            tmp.codDivisa = g.divisa;
            tmp.importoGaranzia = g.importo;
            tmp.prcGaranzia = g.prcGaranzia;
            tmp.dataGaranzia = g.dataGara;
            tmp.dataScadGaranzia = g.dataScadGara;

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

    global class RevisionePraticaInputPayload {
        public String codiceIstituto3N;
        public Long codUserID;
        public String idSistemaEsterno;
        public Long codNDGSoggetto;
    }

    global class ResponseObject {
        public RevisionePraticaPayload payload;
        public Integer returnCode;
        public String message;

        public ResponseObject(RevisionePraticaPayload p, Integer retCode, String msg) {
            payload = p;
            returnCode = retCode;
            message = msg;
        }
    }

    public class RevisionePraticaPayload {
        public Integer resultCode;
        // public Integer returnCode;
        public OutputRichiesta outputRichiesta;
        public String resultMessage;
        public ErrorDetail[] errorDetails;

        public RevisionePraticaPayload() {}
    }

    public class OutputRichiesta { // 1.2
        public String IDsistemaEsterno;
        public Integer codiceIstituto3N;
        public Long codUserID;
        public Long codNDGSoggetto;
        public List<LineaCreditoLCCPEF42> lineeCreditoLCC;
        public Garanzia[] garanzieOmnibus;

        public OutputRichiesta() {}
    }

    public class LineaCreditoLCCPEF42 { // 1.2.5
        public Integer numLineaCredito;
        public String codDivisa;
        public Decimal importoQuotaOneri;
        public Long dataScadenzaFido;
        public Parametro[] parametri;
        public FidoCoppia[] fidiCoppia;
        public Garanzia[] garanzie;
        public Decimal importoAccordato;

        public LineaCreditoLCCPEF42() {
            parametri = new List<Parametro>();
            fidiCoppia = new List<FidoCoppia>();
            garanzie = new List<Garanzia>();
        }
    }

    // public virtual class GenericRevRinPayload {
    //     public Integer codiceIstituto3N;
    //     public String codUserID;
    //     public Long codNDGSoggetto;
    //     public List<LineaCreditoLCC> lineeCreditoLCC;
    //     public Garanzia[] garanzieOmnibus;

    //     public GenericRevRinPayload() {}
    // }

    // public virtual class LineaCreditoLCC {
    //     public Integer numLineaCredito;
    //     public String codDivisa;
    //     public Decimal importoQuotaOneri;
    //     public Long dataScadenzaFido;
    //     public Parametro[] parametri;
    //     public FidoCoppia[] fidiCoppia;
    //     public Garanzia[] garanzie;

    //     public LineaCreditoLCC() {}
    // }

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
        public String codTipoGaranzia;
        public String codCodiceGaranzia;
        public String flagProQuota;
        public String codDivisa;
        public Decimal importoGaranzia;
        public Decimal prcGaranzia;
        public Long dataGaranzia;
        public Long dataScadGaranzia;
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

    public class ErrorDetail { // 1.4
        public String code;
        public String type;
        public String descr;

        public ErrorDetail() {}
    }

}