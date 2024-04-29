public with sharing class WGC_WsRestFF {

    //SERVIZIO TIME02 - CENSIMENTO RIGO DI TRATTATIVA
    public static CensimentoTrattativaResponse censimentoTrattativa (CensimentoTrattativaRequest request){
        CensimentoTrattativaResponse response = (CensimentoTrattativaResponse) WsRestUtils.callService('WGC_CensimentoTratt__c', request, CensimentoTrattativaResponse.class);
        //salvo la response
        if (response !=null && response.payload!=null && response.payload.esito!=null && response.payload.esito.size()> 0){
            for (WGC_WsRestFF.Esito esito :  response.payload.esito){
                if (esito.esitoRiga.equals('OK')){
                    Map<String,Object> parameters = new Map<String,Object>{
                            'Id' => esito.idCrmLinea,
                            'WGC_Codice_Rapporto__c' => esito.pRapporto
                    };
                    saveResponse(parameters);
                }
            }
        }

        return response;
    }

    public static CensimentoTrattativaResponse censimentoTrattativa (Id opportunityId, String typeCall){
        CensimentoTrattativaRequest request = new CensimentoTrattativaRequest();
        Opportunity opp = getOpportunity(opportunityId).get(0);
        request.pIdCrmOpportunita = opportunityId;
        request.pNdgCedente = convertStringToInteger(opp.WGC_NDG_Cedente__c);

        //SM - TEN: Aggiunto recupero informazioni nodo pLinea
        NDGLinea__c agenzia = [SELECT Id, Name, WGC_Codice_Linea_PC__c FROM NDGLinea__c WHERE Opportunita__c =: opportunityId AND Account__c =: WGC_PC_CartController.idAdE LIMIT 1];
        List<RigaCommessa> righeCommessa = new List<RigaCommessa>();
        for (Credito__c c : opp.Credito__r){
            RigaCommessa riga = new RigaCommessa();
            riga.idCrmLinea = c.Id;
            riga.pUtente = getUserAlias();

            List<AccountContactRelation> relation = getContactGruppo(opp.AccountId);
            if (!relation.isEmpty()){
                AccountContactRelation acr = relation.get(0);
                riga.pNdgCuratore = convertStringToInteger(acr.Contact.NDGGruppo__c);
                riga.pNdgLegaleRapp = convertStringToInteger(acr.Contact.NDGGruppo__c);
            }

            riga.pFunzionario = opp.Owner.FederationIdentifier;
            //CR - Cambio Logica Assuntore
            //SM - TEN: CR 409 - 8
            // riga.pNdgDebitore = convertStringToInteger(opp.WGC_NDG_Cedente__c);
            riga.pNdgDebitore = convertStringToInteger(opp.WGC_NDG_Debitore__c);
            riga.pNdgAssuntore = convertStringToInteger(opp.WGC_NDG_Assuntore__c);
            if (opp.Intermediario__c != null) {
                riga.pNdgIntermediario = convertStringToInteger(opp.Intermediario__r.NDGGruppo__c);
            }else {
                riga.pNdgIntermediario = -999999; //workaround per avere null sul json
            }

            if (c.WGC_AdE_Territoriale__c !=null) {
                riga.pAde = c.WGC_AdE_Territoriale__r.Codice__c;
            }
            riga.pCommessa = '${NULL}';
            if (typeCall.equals('pre')){
                riga.pDataCommessa = -999999; //workaround per avere null sul json
            }else if (typeCall.equals('post')){
                riga.pDataCommessa = convertDateToTimestamp(c.WGC_Data_Contratto__c);
            }

            riga.pAnnoImposta = c.WGC_Annualita_imposta__c!=null ? c.WGC_Annualita_imposta__c: '${NULL}';

            if (typeCall.equals('pre')){
                riga.pDataContratto = -999999; //workaround per avere null sul json
            }else if (typeCall.equals('post')){
                riga.pDataContratto = convertDateToTimestamp(c.WGC_Data_Contratto__c);
            }

            riga.pUL = c.WGC_Unita_Locale__c !=null ? c.WGC_Unita_Locale__c : '${NULL}';
            riga.pCompensi = c.WGC_Compensi__c!=null ? c.WGC_Compensi__c.intValue() : -999999;
            riga.pCompensiGM = c.WGC_Compensi_gest_Manuale__c!=null ? c.WGC_Compensi_gest_Manuale__c.intValue() : -999999;
            riga.pContrattoUL = convertStringToInteger(c.WGC_Contratto_unita_locale__c);
            riga.pTipoImposta = convertStringToInteger(checkImposta(c.Imposta__c));
            riga.pOrigine = convertStringToInteger(c.WGC_Origine__c);
            riga.pTipoOperaz = convertStringToInteger(c.WGC_Tipo_Operazione__c);
            riga.pTodalita = convertStringToInteger(c.WGC_Modalita__c);
            riga.pTipologIncasso = convertStringToInteger(c.WGC_Tipologia_Incasso__c);
            if (opp.Assuntore__c!=null){
                riga.pIdTribunale = convertStringToInteger(opp.Assuntore__r.NDGGruppo__c);
            }
            riga.pDataIngrProc = convertDateToTimestamp(opp.WGC_Data_ingresso_in_procedura__c);
            riga.pGiudiceDelegato = opp.WGC_Giudice_delegato__c !=null ? opp.WGC_Giudice_delegato__c : '${NULL}';
            riga.pServRiscossioneTrib = opp.WGC_AeR_Estratto_di_ruolo__c !=null ? opp.WGC_AeR_Estratto_di_ruolo__c : '${NULL}';
            riga.pDataCessazPIVA = convertDateToTimestamp(opp.WGC_Data_Cessazione_PIVA__c );
            riga.pVN = c.ValoreNominale__c !=null ? c.ValoreNominale__c: -999999;
            riga.pVNesigibile = c.WGC_Val_Nom_Esigibile__c!=null ? c.WGC_Val_Nom_Esigibile__c : -999999;
            riga.pPA = c.WGC_Prezzo_di_acquisto__c != null ? c.WGC_Prezzo_di_acquisto__c : 0;
            riga.pInteressi = c.WGC_Interessi_Maturati__c!=null ? c.WGC_Interessi_Maturati__c : -999999;
            riga.pInteressiStimati =  c.WGC_Interessi_stimati__c!=null ? c.WGC_Interessi_stimati__c : -999999;
            riga.pRuoliComp = c.WGC_Ruoli_compens__c!=null ? c.WGC_Ruoli_compens__c: -999999;
            riga.pDataIncassoPres = convertDateToTimestamp(c.WGC_Data_DSO__c);
            riga.pDataRimborsoPres = convertDateToTimestamp(c.WGC_Data_rimborso_presunto__c);
            riga.pDataPresentazRimborso = convertDateToTimestamp(c.WGC_Data_presentazione_rimborso__c);
            riga.pDataSaldo = convertDateToTimestamp(c.WGC_Data_Saldo__c);
            riga.pDataRimborsoPresAC = convertDateToTimestamp(c.WGC_Data_rimb_pres_in_atto_di_cessione__c);
            riga.pModalitaContab = convertStringToInteger(c.WGC_Modalita_contabilizzazione__c);
            riga.pDipManuale = c.WGC_Modifica_DSO__c ? 'S' : 'N';
            riga.pUtenteDipManuale = '${NULL}';
            riga.pCausaleDipManuale = convertStringToInteger(c.WGC_Causale_modifica_DSO__c);
            riga.pDataDelibera = convertDateToTimestamp(opp.DataDelibera__c);
            riga.pOrganoDelibera = convertStringToInteger(opp.WGC_Organo_Delibera__c);
            riga.pUtenteMCmanuale = '${NULL}';
            riga.pIdCausaleMCmanuale = -999999; //workaround per avere null sul json
            riga.pUltQuantif = 'N'; //non può essere null
            riga.pPercQuantif = c.WGC_Ulteriore_quantificazione_perc__c !=null ? c.WGC_Ulteriore_quantificazione_perc__c : -999999;
            //SM - TEN: CR Aggiunti campi note e ultima nota
            riga.pNote = c.WGC_Note_BO__c;
            riga.pUltNota = c.WGC_Ultima_Nota__c;
            riga.pLinea = agenzia.WGC_Codice_Linea_PC__c;
            righeCommessa.add(riga);
        }

        request.righeCommessa = righeCommessa;
        return censimentoTrattativa(request);
    }

    public static CensimentoTrattativaResponse censimentoTrattativaSingle (Id opportunityId, Id creditoId, String typeCall){
        CensimentoTrattativaRequest request = new CensimentoTrattativaRequest();
        Opportunity opp = getOpportunity(opportunityId).get(0);
        request.pIdCrmOpportunita = opportunityId;
        request.pNdgCedente = convertStringToInteger(opp.WGC_NDG_Cedente__c);

        //SM - TEN: Aggiunto recupero informazioni nodo pLinea
        NDGLinea__c agenzia = [SELECT Id, Name, WGC_Codice_Linea_PC__c FROM NDGLinea__c WHERE Opportunita__c =: opportunityId AND Account__c =: WGC_PC_CartController.idAdE LIMIT 1];
        List<Credito__c> credito = getCrediti(new Set<Id>{creditoId});
        List<RigaCommessa> righeCommessa = new List<RigaCommessa>();
        for (Credito__c c : credito){
            RigaCommessa riga = new RigaCommessa();
            riga.idCrmLinea = c.Id;
            riga.pUtente = getUserAlias();

            List<AccountContactRelation> relation = getContactGruppo(opp.AccountId);
            if (!relation.isEmpty()){
                AccountContactRelation acr = relation.get(0);
                riga.pNdgCuratore = convertStringToInteger(acr.Contact.NDGGruppo__c);
                riga.pNdgLegaleRapp = convertStringToInteger(acr.Contact.NDGGruppo__c);
            }

            riga.pFunzionario = opp.Owner.FederationIdentifier;
            //CR - Cambio Logica Assuntore
            riga.pNdgDebitore = convertStringToInteger(opp.WGC_NDG_Debitore__c);
            riga.pNdgAssuntore = convertStringToInteger(opp.WGC_NDG_Assuntore__c);
            if (opp.Intermediario__c != null) {
                riga.pNdgIntermediario = convertStringToInteger(opp.Intermediario__r.NDGGruppo__c);
            }else {
                riga.pNdgIntermediario = -999999; //workaround per avere null sul json
            }

            if (c.WGC_AdE_Territoriale__c !=null) {
                riga.pAde = c.WGC_AdE_Territoriale__r.Codice__c;
            }
            riga.pCommessa = '${NULL}';
            if (typeCall.equals('pre')){
                riga.pDataCommessa = -999999; //workaround per avere null sul json
            }else if (typeCall.equals('post')){
                riga.pDataCommessa = convertDateToTimestamp(c.WGC_Data_Contratto__c);
            }

            riga.pAnnoImposta = c.WGC_Annualita_imposta__c!=null ? c.WGC_Annualita_imposta__c: '${NULL}';

            if (typeCall.equals('pre')){
                riga.pDataContratto = -999999; //workaround per avere null sul json
            }else if (typeCall.equals('post')){
                riga.pDataContratto = convertDateToTimestamp(c.WGC_Data_Contratto__c);
            }

            riga.pUL = c.WGC_Unita_Locale__c !=null ? c.WGC_Unita_Locale__c : '${NULL}';
            riga.pCompensi = c.WGC_Compensi__c!=null ? c.WGC_Compensi__c.intValue() : -999999;
            riga.pCompensiGM = c.WGC_Compensi_gest_Manuale__c!=null ? c.WGC_Compensi_gest_Manuale__c.intValue() : -999999;
            riga.pContrattoUL = convertStringToInteger(c.WGC_Contratto_unita_locale__c);
            riga.pTipoImposta = convertStringToInteger(checkImposta(c.Imposta__c));
            riga.pOrigine = convertStringToInteger(c.WGC_Origine__c);
            riga.pTipoOperaz = convertStringToInteger(c.WGC_Tipo_Operazione__c);
            riga.pTodalita = convertStringToInteger(c.WGC_Modalita__c);
            riga.pTipologIncasso = convertStringToInteger(c.WGC_Tipologia_Incasso__c);
            if (opp.Assuntore__c!=null){
                riga.pIdTribunale = convertStringToInteger(opp.Assuntore__r.NDGGruppo__c);
            }
            riga.pDataIngrProc = convertDateToTimestamp(opp.WGC_Data_ingresso_in_procedura__c);
            riga.pGiudiceDelegato = opp.WGC_Giudice_delegato__c !=null ? opp.WGC_Giudice_delegato__c : '${NULL}';
            riga.pServRiscossioneTrib = opp.WGC_AeR_Estratto_di_ruolo__c !=null ? opp.WGC_AeR_Estratto_di_ruolo__c : '${NULL}';
            riga.pDataCessazPIVA = convertDateToTimestamp(opp.WGC_Data_Cessazione_PIVA__c );
            riga.pVN = c.ValoreNominale__c !=null ? c.ValoreNominale__c: -999999;
            riga.pVNesigibile = c.WGC_Val_Nom_Esigibile__c!=null ? c.WGC_Val_Nom_Esigibile__c : -999999;
            riga.pPA = c.WGC_Prezzo_di_acquisto__c != null ? c.WGC_Prezzo_di_acquisto__c : 0;
            riga.pInteressi = c.WGC_Interessi_Maturati__c!=null ? c.WGC_Interessi_Maturati__c : -999999;
            riga.pInteressiStimati =  c.WGC_Interessi_stimati__c!=null ? c.WGC_Interessi_stimati__c : -999999;
            riga.pRuoliComp = c.WGC_Ruoli_compens__c!=null ? c.WGC_Ruoli_compens__c: -999999;
            riga.pDataIncassoPres = convertDateToTimestamp(c.WGC_Data_DSO__c);
            riga.pDataRimborsoPres = convertDateToTimestamp(c.WGC_Data_rimborso_presunto__c);
            riga.pDataPresentazRimborso = convertDateToTimestamp(c.WGC_Data_presentazione_rimborso__c);
            riga.pDataSaldo = convertDateToTimestamp(c.WGC_Data_Saldo__c);
            riga.pDataRimborsoPresAC = convertDateToTimestamp(c.WGC_Data_rimb_pres_in_atto_di_cessione__c);
            riga.pModalitaContab = convertStringToInteger(c.WGC_Modalita_contabilizzazione__c);
            riga.pDipManuale = c.WGC_Modifica_DSO__c ? 'S' : 'N';
            riga.pUtenteDipManuale = '${NULL}';
            riga.pCausaleDipManuale = convertStringToInteger(c.WGC_Causale_modifica_DSO__c);
            riga.pDataDelibera = convertDateToTimestamp(opp.DataDelibera__c);
            riga.pOrganoDelibera = convertStringToInteger(opp.WGC_Organo_Delibera__c);
            riga.pUtenteMCmanuale = '${NULL}';
            riga.pIdCausaleMCmanuale = -999999; //workaround per avere null sul json
            riga.pUltQuantif = 'N'; //non può essere null
            riga.pPercQuantif = c.WGC_Ulteriore_quantificazione_perc__c !=null ? c.WGC_Ulteriore_quantificazione_perc__c : -999999;
            //SM - TEN: CR Aggiunti campi note e ultima nota
            riga.pNote = c.WGC_Note_BO__c;
            riga.pUltNota = c.WGC_Ultima_Nota__c;
            riga.pLinea = agenzia.WGC_Codice_Linea_PC__c;
            righeCommessa.add(riga);
        }

        request.righeCommessa = righeCommessa;
        return censimentoTrattativa(request);
    }
    
    //SERVIZIO TIME03 - CONFERMA APERTURA RAPPORTI DI TRATTATIVA
    public static RapportoTrattativaResponse confermaTrattativa (RapportoTrattativaRequest request){
        return (RapportoTrattativaResponse) WsRestUtils.callService('WGC_ConfermaTratt__c', request, RapportoTrattativaResponse.class);
    }

    public static RapportoTrattativaResponse confermaTrattativa (Id opportunityId){
        RapportoTrattativaRequest request = new RapportoTrattativaRequest();
        request.idCrmOpportunita = opportunityId;
        return confermaTrattativa(request);
    }

    //SERVIZIO TIME04 - CALCOLO INTERESSI
    public static CalcoloInteressiResponse calcoloInteressi (Id creditoId, CalcoloInteressiRequest request){
        CalcoloInteressiResponse response = (CalcoloInteressiResponse) WsRestUtils.callService('WGC_CalcoloInteressi__c', request, CalcoloInteressiResponse.class);
        //salvo la response
        if (response !=null && response.payload!=null && response.payload.pInteressi!=null){
            Map<String,Object> parameters = new Map<String,Object>{
                    'Id' => creditoId,
                    'WGC_Interessi_stimati__c' => convertStringToDecimal(response.payload.pInteressi)
            };

            saveResponse(parameters);
        }

        return response;
    }

    public static CalcoloInteressiResponse calcoloInteressi (Id creditoId){
        CalcoloInteressiRequest interesse = new CalcoloInteressiRequest();

        Credito__c c = getCrediti(new Set<Id> {creditoId}).get(0);

        interesse.pDataA = convertDateToTimestamp(c.WGC_Data_DSO__c);

        if (c.WGC_Data_rimborso_presunto__c != null){
            interesse.pDataDa = convertDateToTimestamp(c.WGC_Data_rimborso_presunto__c);
        }else {
            interesse.pDataDa = convertDateToTimestamp(c.WGC_Data_presentazione_rimborso__c);
        }

        //interesse.pImporto = c.ValoreNominale__c != null ? c.ValoreNominale__c : 0;
        interesse.pImporto = c.WGC_Val_Nom_Esigibile__c != null ? c.WGC_Val_Nom_Esigibile__c : 0;
        if (c.Imposta__c !=null && c.Imposta__c.equals('36')){
            interesse.pFlagIVA = 'S';
        }else {
            interesse.pFlagIVA = 'N';
        }

        interesse.coppieDate = new List<DataSosp>{new DataSosp(),new DataSosp(),new DataSosp()};

        return calcoloInteressi(creditoId,interesse);
    }

    //SERVIZIO TIME05 - CALCOLO DIP
    public static CalcoloDipResponse calcoloDip (Id creditoId, CalcoloDipRequest request){
        CalcoloDipResponse response = (CalcoloDipResponse) WsRestUtils.callService('WGC_CalcoloDIP__c', request, CalcoloDipResponse.class);
        //salvo la response
        if (response !=null){
            Map<String,Object> parameters = new Map<String,Object>{
                    'Id' => creditoId,
                    'WGC_Data_DSO__c' => convertTimestampToDate(response.payload.pDIP)
            };

            saveResponse(parameters);
        }
        return response;
    }

    public static CalcoloDipResponse calcoloDip (Id creditoId){
        CalcoloDipRequest request = new CalcoloDipRequest();
        Credito__c c = getCrediti(new Set<Id> {creditoId}).get(0);

        //Aggiunto per differenziare il popolamento dei campi in base al record type dell'opportunità
        Opportunity opp = [SELECT Id, RecordType.DeveloperName FROM Opportunity WHERE Id =: c.Opportunita__c];

        request.pDataRimbPres = ( opp.RecordType.DeveloperName == 'WGC_IFIS_Oppotunita_Crediti_Erariali' || opp.RecordType.DeveloperName == 'IFISOpportunitaFactoring' ) ? convertDateToTimestamp(c.WGC_Data_richiesta_rimborso__c) : convertDateToTimestamp(c.WGC_Data_rimborso_presunto__c); //convertDateToTimestamp(c.WGC_Data_rimborso_presunto__c)
        request.pDataPresRimb = ( opp.RecordType.DeveloperName == 'WGC_IFIS_Oppotunita_Crediti_Erariali' || opp.RecordType.DeveloperName == 'IFISOpportunitaFactoring' ) ? convertDateToTimestamp(c.WGC_Data_richiesta_rimborso__c) : convertDateToTimestamp(c.WGC_Data_presentazione_rimborso__c);//convertDateToTimestamp(c.WGC_Data_presentazione_rimborso__c);
        if (c.WGC_AdE_Territoriale__c !=null) {
            request.pAdE = c.WGC_AdE_Territoriale__r.Codice__c;
        }
        request.pTipoCred = c.Imposta__c != null ? checkImposta(c.Imposta__c) : '36';
        //Modificato per record type opportunità
        request.pIdTipolIncasso = c.WGC_Tipologia_Incasso__c != null ? convertStringToInteger(c.WGC_Tipologia_Incasso__c) : null;
        request.pVN = c.ValoreNominale__c != null ? c.ValoreNominale__c : -999999;

        return calcoloDip(creditoId,request);
    }

    //SERVIZIO TIME06 - CALCOLO IRR
    public static CalcoloIrrResponse calcoloIrr (Id creditoId, CalcoloIrrRequest request){
        CalcoloIrrResponse response = (CalcoloIrrResponse) WsRestUtils.callService('WGC_CalcoloIRR__c', request, CalcoloIrrResponse.class);

        if (response !=null && response.payload.elencoCrediti.size() > 0){
            //Aggiunto per limitare i decimali a due
            response.payload.elencoCrediti[0].testata.pIRR = response.payload.elencoCrediti[0].testata.pIRR.setScale(2);

            Map<String,Object> parameters = new Map<String,Object>{
                    'Id' => creditoId,
                    'WGC_IRR_perc__c' => response.payload.elencoCrediti[0].testata.pIRR
            };

            saveResponse(parameters);
        }
        return response;
    }

    public static CalcoloIrrResponse calcoloIrr (Id creditoId){
        return calcoloIrr(new Set<Id> {creditoId});
    }

    public static CalcoloIrrResponse calcoloIrr (Set<Id> creditoIds){
        CalcoloIrrRequest request = new CalcoloIrrRequest();
        List<Credito__c> crediti = getCrediti(creditoIds);
        List<Riga> righe = new List<Riga>();
        for (credito__c c : crediti){
            Riga r = new Riga();
            //Modificato per valore di default per opportunità factoring o crediti erariali
            r.pTipoCredito = c.Imposta__c != null ? checkImposta(c.Imposta__c) : '36';
            //r.PVN = c.ValoreNominale__c != null ? c.ValoreNominale__c : 0;
            r.PVN = c.WGC_Val_Nom_Esigibile__c != null ? c.WGC_Val_Nom_Esigibile__c : 0;
            // r.pDataPresRimb = c.WGC_Data_presentazione_rimborso__c != null ? convertDateToTimestamp(c.WGC_Data_presentazione_rimborso__c) : convertDateToTimestamp(c.WGC_Data_richiesta_rimborso__c);
            r.pDataPresRimb = ( c.Opportunita__r.RecordType.DeveloperName == 'WGC_IFIS_Oppotunita_Crediti_Erariali' || c.Opportunita__r.RecordType.DeveloperName == 'IFISOpportunitaFactoring' ) ? convertDateToTimestamp(c.WGC_Data_richiesta_rimborso__c) : c.WGC_Data_presentazione_rimborso__c != null ? convertDateToTimestamp(c.WGC_Data_presentazione_rimborso__c) : c.WGC_Data_rimborso_presunto__c != null ? convertDateToTimestamp(c.WGC_Data_rimborso_presunto__c) : 0;
            //Modificato per tipologia opportunità
            r.pGgMaturazInter = c.WGC_Gg_Maturazione_Interessi__c != null ? Integer.valueOf(c.WGC_Gg_Maturazione_Interessi__c) : 90;
            r.pDataCessione = c.WGC_Data_cessione_credito__c != null ? convertDateToTimestamp(c.WGC_Data_cessione_credito__c) : convertDateToTimestamp(System.Today().addDays(30));
            //r.pPercPrezzo = c.WGC_Prezzo_pagato_alla_cessione__c !=null ? c.WGC_Prezzo_pagato_alla_cessione__c: 0;
            r.pPercPrezzo = c.WGC_Offerta_perc__c != null ? c.WGC_Offerta_perc__c : 0;
            //r.pPercRata1 = c.WGC_Offerta_perc__c !=null ? c.WGC_Offerta_perc__c: -999999;
            r.pPercRata1 = c.WGC_Importo_acconto__c != null && c.WGC_Prezzo_di_Acquisto__c != null ? ( c.WGC_Importo_acconto__c / c.WGC_Prezzo_di_Acquisto__c ) * 100 : 100;
            //r.pPercRata2 = c.WGC_Importo_acconto__c !=null ? c.WGC_Importo_acconto__c: -999999;
            // r.pPercRata2 = c.WGC_Importo_Saldo__c != null && c.WGC_Prezzo_di_Acquisto__c != null ? ( c.WGC_Importo_Saldo__c / c.WGC_Prezzo_di_Acquisto__c ) * 100 : -999999;
            r.pPercRata2 = c.Opportunita__r.RecordType.DeveloperName == 'IFISOpportunitaFastFinance' ? ( c.WGC_Importo_Saldo__c / c.WGC_Prezzo_di_Acquisto__c ) * 100 : 0;
            r.pDataRata2 = c.Opportunita__r.RecordType.DeveloperName == 'IFISOpportunitaFastFinance' ? convertDateToTimestamp(c.WGC_Data_Saldo__c) : convertDateToTimestamp(System.Today().addDays(30));
            r.pDIP = convertDateToTimestamp(c.WGC_Data_DSO__c);
            r.pCostoNotaio = c.WGC_Costo_notaio__c!=null ? c.WGC_Costo_notaio__c: 0;
            //TODO modificare con il campo corretto, una volta deciso
            //IN BONIS fisso a 0
            //PROCEDURE WGC_Data_Pagamento_Notaio__c - WGC_Data_Cessione_Credito__c
            // r.pGgPagNotaio = 0;
            r.pGgPagNotaio = c.Opportunita__r.RecordType.DeveloperName == 'IFISOpportunitaFastFinance' ? c.WGC_Data_Cessione_Credito__c.daysBetween(c.WGC_Data_Pagamento_Notaio__c) : 0;
            //r.pGgPagNotaio = c.WGC_GG_Pagamento_Notaio__c!=null ? c.WGC_GG_Pagamento_Notaio__c: 0;
            //r.pGgPagNotaio = convertDateToTimestamp(c.WGC_Data_Pagamento_Notaio__c);
            r.pCostiContenz = c.WGC_Costo_contenzioso__c!=null ? c.WGC_Costo_contenzioso__c: 0;
            r.pDataPagContenz = c.WGC_Data_Pagamento_Contenzioso__c != null ? convertDateToTimestamp(c.WGC_Data_Pagamento_Contenzioso__c) : convertDateToTimestamp(System.Today().addDays(30));
            r.pCostoUL = c.WGC_Due_Diligence__c || c.WGC_Compensi_Gest_Manuale__c != null ? c.WGC_Compensi_Gest_Manuale__c : c.WGC_Compensi__c != null ? c.WGC_Compensi__c : 0; //c.WGC_Compensi_Gest_Manuale__c != null ? c.WGC_Compensi_Gest_Manuale__c : c.WGC_Compensi__c !=null ? c.WGC_Compensi__c : 0;
            r.pDataPagUL = c.WGC_Data_pagamento_costo_UL__c != null ? convertDateToTimestamp(c.WGC_Data_pagamento_costo_UL__c) : convertDateToTimestamp(System.Today().addDays(50));
            // A.M. SDHDFNZ-101026 - aggiunta WGC_Data_Fase_Valutazione_Pratica__c per gestione valori storici
			//WGC_Valore_IRR__mdt valoriIRR = getValoriIRR(c.Opportunita__r.RecordType.DeveloperName);
			WGC_Valore_IRR__mdt valoriIRR = getValoriIRR(c.Opportunita__r.RecordType.DeveloperName, c.Opportunita__r.WGC_Data_Fase_Valutazione_Pratica__c);
            r.pTasso = valoriIRR.Tasso_di_riferimento__c;
            r.pSpread = valoriIRR.Spread__c;
            r.pTassoInteresseUntil2009 = 0;
            r.pTassoInteressePost2009 = valoriIRR.Tasso_interesse_attivo__c !=null ? valoriIRR.Tasso_interesse_attivo__c : 0;
            righe.add(r);
        }

        request.righe = righe;
        return calcoloIrr(crediti.get(0).Id, request);
    }

    //SERVIZIO TIME07 - CALCOLO COMPENSI
    public static CalcoloCompensiResponse calcoloCompensi (Id creditoId, CalcoloCompensiRequest request){
        CalcoloCompensiResponse response = (CalcoloCompensiResponse) WsRestUtils.callService('WGC_CalcoloCompensi__c', request, CalcoloCompensiResponse.class);
        //salvo la response
        if (response !=null && response.payload.pCompenso != null){
            Map<String,Object> parameters = new Map<String,Object>{
                    'Id' => creditoId,
                    'WGC_Compensi__c' => response.payload.pCompenso
            };

            saveResponse(parameters);
        }
        return response;
    }

    public static CalcoloCompensiResponse calcoloCompensi (Id creditoId){
        CalcoloCompensiRequest r = new CalcoloCompensiRequest();
        Credito__c c = getCrediti(new Set<Id> {creditoId}).get(0);

        r.pUL = c.WGC_Unita_Locale__c!=null ? c.WGC_Unita_Locale__c : '${NULL}';
        r.pContrattoUL = convertStringToInteger(c.WGC_Contratto_unita_locale__c);
        r.pVN = c.ValoreNominale__c != null ? c.ValoreNominale__c : -999999;
        r.pRuoliComp = c.WGC_Ruoli_compens__c != null ? c.WGC_Ruoli_compens__c : 0;
        r.pInteressiMatur = c.WGC_Interessi_maturati__c != null ? c.WGC_Interessi_maturati__c : 0;
        r.pPrezzoAcq = c.WGC_Prezzo_di_acquisto__c != null ? c.WGC_Prezzo_di_acquisto__c : 0;
        r.pDDeffettuata = 'N';
        r.pTipoImposta = convertStringToInteger(checkImposta(c.Imposta__c));

        return calcoloCompensi(creditoId, r);
    }

    /*************************************************************************************
    *                                 UTIL METHODS                                       *
    * ************************************************************************************/

    private static Long convertDateToTimestamp (Date d){
        return d!=null? DateTime.newInstance(d.year(), d.month(), d.day()).getTime():-999999;
    }

    private static Decimal convertStringToDecimal (String s){
        return s!=null? Decimal.valueOf(s):-999999;
    }

    private static Date convertTimestampToDate (Long longtime){
        DateTime dt = DateTime.newInstance(longtime);
        return Date.newInstance(dT.year(), dT.month(), dT.day());
    }

    private static Integer convertStringToInteger (String s){
        return s!=null ? Integer.valueOf(s) : -999999;
    }

    private static List<AccountContactRelation> getContactGruppo (Id accountId){
        return [SELECT Contact.NDGGruppo__c
                FROM AccountContactRelation
                WHERE AccountId =: accountId AND WGC_Selezionato__c = true AND WGC_Esecutore_MAV__c = true LIMIT 1
        ];
    }

	// A.M. SDHDFNZ-101026 - aggiunto campo "Opportunita__r.WGC_Data_Fase_Valutazione_Pratica__c"
    private static List<Credito__c> getCrediti (Set<Id> creditoIds){
        return [SELECT  Id, WGC_Data_rimborso_presunto__c, WGC_Data_presentazione_rimborso__c, WGC_Data_DSO__c,
                        Tipo_Imposta_Credito__c, ValoreNominale__c, WGC_AdE_Territoriale__r.Codice__c,
                        Imposta__c, WGC_Tipologia_Incasso__c,WGC_Gg_Maturazione_Interessi__c,WGC_Data_cessione_credito__c,
                        WGC_Prezzo_pagato_alla_cessione__c, WGC_Perc_Prezzo_pagato_alla_cessione__c,WGC_I_tranche_prezzo_differito__c,
                        WGC_Data_I_tranche_prezzo_differito__c, WGC_Costo_notaio__c, WGC_GG_Pagamento_Notaio__c,
                        WGC_Costo_contenzioso__c, WGC_Data_Pagamento_Contenzioso__c, WGC_Compensi__c, WGC_Data_pagamento_costo_UL__c, WGC_Tasso__c,
                        WGC_Spread__c, WGC_Tasso_Interesse__c,WGC_Ulteriore_quantificazione_perc__c,WGC_Causale_modifica_DSO__c,
                        WGC_Modalita_contabilizzazione__c,WGC_Data_rimb_pres_in_atto_di_cessione__c,WGC_Data_Saldo__c, WGC_Ruoli_compens__c,
                        WGC_Interessi_stimati__c, WGC_Val_Nom_Esigibile__c,WGC_Modalita__c, WGC_Tipo_Operazione__c,WGC_Origine__c,
                        WGC_Contratto_unita_locale__c, WGC_Compensi_gest_Manuale__c, WGC_Unita_Locale__c, WGC_Data_Contratto__c,
                        WGC_Annualita_imposta__c,WGC_Modifica_DSO__c,WGC_Interessi_maturati__c,WGC_Prezzo_di_acquisto__c, WGC_Data_acconto__c,
                        WGC_Importo_acconto__c, WGC_Offerta_perc__c, WGC_Importo_Saldo__c, WGC_Data_Pagamento_Notaio__c, Opportunita__c, WGC_Data_richiesta_rimborso__c,
                        Opportunita__r.RecordType.DeveloperName, Opportunita__r.WGC_Data_Fase_Valutazione_Pratica__c, WGC_Linea__c, WGC_Note_BO__c, WGC_Ultima_Nota__c, WGC_Due_Diligence__c
        FROM Credito__c
                WHERE Id IN: creditoIds
        ];
    }

    private static List<Opportunity> getOpportunity (Id opportunityId){
        return [SELECT Id, AccountId, WGC_NDG_Cedente__c, WGC_Organo_Delibera__c,DataDelibera__c, WGC_Data_Cessazione_PIVA__c, Assuntore__r.NDGGruppo__c,
                       WGC_Data_ingresso_in_procedura__c, WGC_Giudice_delegato__c, WGC_AeR_Estratto_di_ruolo__c, WGC_NDG_Assuntore__c,Owner.FederationIdentifier,
                       Intermediario__c, Intermediario__r.NDGGruppo__c, WGC_NDG_Debitore__c,                          WGC_Assuntore__c, WGC_Azienda_Cedente__r.NDGGruppo__c, Account.NDGGruppo__c,
                (SELECT Id, WGC_Linea__c, WGC_Data_rimborso_presunto__c, WGC_Data_presentazione_rimborso__c, WGC_Data_DSO__c,
                        Tipo_Imposta_Credito__c, ValoreNominale__c, WGC_AdE_Territoriale__r.Codice__c,
                        Imposta__c, WGC_Tipologia_Incasso__c,WGC_Gg_Maturazione_Interessi__c,WGC_Data_cessione_credito__c,
                        WGC_Prezzo_pagato_alla_cessione__c, WGC_Perc_Prezzo_pagato_alla_cessione__c,WGC_I_tranche_prezzo_differito__c,
                        WGC_Data_I_tranche_prezzo_differito__c, WGC_Costo_notaio__c, WGC_GG_Pagamento_Notaio__c,
                        WGC_Costo_contenzioso__c, WGC_Data_Pagamento_Contenzioso__c, WGC_Compensi__c, WGC_Data_pagamento_costo_UL__c, WGC_Tasso__c,
                        WGC_Spread__c, WGC_Tasso_Interesse__c,WGC_Ulteriore_quantificazione_perc__c,WGC_Causale_modifica_DSO__c,
                        WGC_Modalita_contabilizzazione__c,WGC_Data_rimb_pres_in_atto_di_cessione__c,WGC_Data_Saldo__c, WGC_Ruoli_compens__c,
                        WGC_Interessi_stimati__c, WGC_Val_Nom_Esigibile__c,WGC_Modalita__c, WGC_Tipo_Operazione__c,WGC_Origine__c,
                        WGC_Contratto_unita_locale__c, WGC_Compensi_gest_Manuale__c, WGC_Unita_Locale__c, WGC_Data_Contratto__c,
                        WGC_Annualita_imposta__c,WGC_Modifica_DSO__c,WGC_Interessi_maturati__c,WGC_Prezzo_di_acquisto__c, WGC_Data_acconto__c,
                        WGC_Importo_acconto__c, WGC_Offerta_perc__c, WGC_Note_BO__c, WGC_Ultima_Nota__c
                FROM Credito__r
                WHERE WGC_Invia_Credito__c = true ORDER BY CreatedDate)
                FROM Opportunity
                WHERE Id =: opportunityId
        ];
    }

    private static String getUserFederationIdentifier(){
        User u = [SELECT FederationIdentifier FROM User WHERE Id =: UserInfo.getUserId()];
        return u.FederationIdentifier!=null ? u.FederationIdentifier : '${NULL}';
    }

    private static String getUserAlias(){
        User u = [SELECT Alias FROM User WHERE Id =: UserInfo.getUserId()];
        return u.Alias!=null ? u.Alias.toUpperCase() : '${NULL}';
    }

    private static void saveResponse(Map<String,Object> parameters){
        Id recordId = (Id) parameters.get('Id');
        SObject obj = recordId.getSObjectType().newSObject();
        for (String s: parameters.keySet()){
            obj.put(s,parameters.get(s));
        }

        update obj;
    }

    private static String checkImposta (String imp){
        switch on imp {
            when '1642', '3721', '2481', '2521' {
                return null;
            }

            when else {
                return imp;
            }
        }
    }

    // private static WGC_Valori_IRR__c getValoriIRR(){
    //     Profile p = [SELECT Id FROM Profile WHERE Name = 'IFIS - B/O Valutazione Fast Finance' LIMIT 1];
    //     WGC_Valori_IRR__c mc = WGC_Valori_IRR__c.getInstance(p.Id);
    //     return mc;
    // }

   // A.M. SDHDFNZ-101026 - Gestione storico metadato
   //private static WGC_Valore_IRR__mdt getValoriIRR(String optyRT){
	private static WGC_Valore_IRR__mdt getValoriIRR(String optyRT, Date Data_Fase_Valutazione_Pratica){
        String type;
        if( optyRT == 'IFISOpportunitaFastFinance'){
            type = 'Procedure';
        } else {
            type = 'InBonis';
        }
		Date Data_Riferimento = (Data_Fase_Valutazione_Pratica != null ? Data_Fase_Valutazione_Pratica : Date.today());
        //return [SELECT Id, Costo_Denaro__c, Spread__c, Tasso_di_riferimento__c, Tasso_interesse_attivo__c FROM WGC_Valore_IRR__mdt WHERE DeveloperName =: type LIMIT 1];
		return [SELECT Id, Costo_Denaro__c, Spread__c, Tasso_di_riferimento__c, Tasso_interesse_attivo__c FROM WGC_Valore_IRR__mdt WHERE Tipo_Credito__c =: type AND Inizio_Validita__c <=: Data_Riferimento AND Fine_Validita__c >=: Data_Riferimento];
    }

    /*************************************************************************************
    *                                 WRAPPER CLASS                                      *
    * ************************************************************************************/

    //REQUEST TIME02
    public class CensimentoTrattativaRequest {
        public String pIdCrmOpportunita;
        public Integer pNdgCedente;
        public List<RigaCommessa> righeCommessa;
    }

    public class RigaCommessa{
        public String idCrmLinea;
        public String pUtente;
        public String pFunzionario;
        public Integer pNdgDebitore;
        public Integer pNdgCuratore;
        public Integer pNdgAssuntore;
        public Integer pNdgIntermediario;
        public Integer pNdgLegaleRapp;
        public String pAde;
        public String pCommessa;
        public Long pDataCommessa;
        public String pAnnoImposta;
        public Long pDataContratto;
        public String pUL;
        public Integer pCompensi;
        public Integer pCompensiGM;
        public Integer pContrattoUL;
        public Integer pTipoImposta;
        public Integer pOrigine;
        public Integer pTipoOperaz;
        public Integer pTodalita;
        public Integer pTipologIncasso;
        public Integer pIdTribunale;
        public Long pDataIngrProc;
        public String pGiudiceDelegato;
        public String pServRiscossioneTrib;
        public Long pDataCessazPIVA;
        public Decimal pVN;
        public Decimal pVNesigibile;
        public Decimal pPA;
        public Decimal pInteressi;
        public Decimal pInteressiStimati;
        public Decimal pRuoliComp;
        public Long pDataIncassoPres;
        public Long pDataRimborsoPres;
        public Long pDataPresentazRimborso;
        public Long pDataSaldo;
        public Long pDataRimborsoPresAC;
        public Integer pModalitaContab;
        public String pDipManuale;
        public String pUtenteDipManuale;
        public Integer pCausaleDipManuale;
        public Long pDataDelibera;
        public Integer pOrganoDelibera;
        public String pUtenteMCmanuale;
        public Integer pIdCausaleMCmanuale;
        public String pUltQuantif;
        public Decimal pPercQuantif;
        //SM - TEN: CR Aggiunti campi Ultima nota e Note
        public String pNote;
        public String pUltNota;
        public String pLinea;
    }

    //RESPONSE TIME02
    public class CensimentoTrattativaResponse extends WsRestInput.CommonResponse {
        public PayloadCensimentoTrattativa payload;

        public override Boolean isCorrect() {
            return payload != null;
        }
    }

    public class PayloadCensimentoTrattativa{
        public List<Esito> esito;
    }

    public class Esito {
        public String esitoRiga;
        public String idCrmLinea;
        public String pRapporto;
    }

    //REQUEST TIME03
    public class RapportoTrattativaRequest {
        public String idCrmOpportunita;
    }

    //RESPONSE TIME03
    public class RapportoTrattativaResponse extends WsRestInput.CommonResponse {
        public PayloadRapportoTrattativa payload;

        public override Boolean isCorrect(){
            return payload != null;
        }
    }

    public class PayloadRapportoTrattativa {
        public String esito;
        public String pRigo;
        public String pCommessa;
        public String pRapporto;
        public String returnCode;
    }

    //REQUEST TIME04
    public class CalcoloInteressiRequest {
        public Long pDataDa;
        public Long pDataA;
        public Decimal pImporto;
        public String pFlagIVA;
        public List<DataSosp> coppieDate;
    }

    public class DataSosp {
        public String pDataSospDa;
        public String pDataSospA;

        public DataSosp(){
            this.pDataSospDa = '${NULL}';
            this.pDataSospA = '${NULL}';
        }
    }

    //RESPONSE TIME04
    public class CalcoloInteressiResponse extends WsRestInput.CommonResponse {
        public PayloadCalcoloInteressi payload;

        public override Boolean isCorrect(){
            return payload != null;
        }
    }

    public class PayloadCalcoloInteressi {
        public String pInteressi;
    }

    //REQUEST TIME05
    public class CalcoloDipRequest {
        public Long pDataRimbPres;
        public Long pDataPresRimb;
        public String pAdE;
        public String pTipoCred;
        public Integer pIdTipolIncasso;
        public Decimal pVN;
    }

    //RESPONSE TIME05
    public class CalcoloDipResponse extends WsRestInput.CommonResponse {

        public PayloadCalcoloDip payload;

        public override Boolean isCorrect() {
            return payload != null;
        }
    }

    public class PayloadCalcoloDip{
        public Long pDIP;
        public Integer pNrCasi;
        public Long pDipUltOsserv;
        public String pCommessaUltOsserv;
        public Decimal pTempoRecupero;
        public Integer pTipoTMR;
        public String pDescTipoTMR;
        public Long pDataRichRimborso;
        public String pDescrTipolIncasso;
    }

    //REQUEST TIME06
    public class CalcoloIrrRequest {
        public List<Riga> righe;
    }

    public class Riga {
        public String pTipoCredito;
        public Decimal pVN;
        public Long pDataPresRimb;
        public Integer pGgMaturazInter;
        public Long pDataCessione;
        public Decimal pPercPrezzo;
        public Decimal pPercRata1;
        public Decimal pPercRata2;
        public Long pDataRata2;
        public Long pDIP;
        public Decimal pCostoNotaio;
        public Decimal pGgPagNotaio;
        public Decimal pCostiContenz;
        public Long pDataPagContenz;
        public Decimal pCostoUL;
        public Long pDataPagUL;
        public Decimal pTasso;
        public Decimal pSpread;
        public Decimal pTassoInteresseUntil2009;
        public Decimal pTassoInteressePost2009;
    }

    //RESPONSE TIME06
    public class CalcoloIrrResponse extends WsRestInput.CommonResponse {
        public PayloadCalcoloIrr payload;

        public override Boolean isCorrect(){
            return payload != null;
        }
    }

    public class PayloadCalcoloIrr {
        public List<ElencoCrediti> elencoCrediti;
    }

    public class ElencoCrediti {
        public Testata testata;
        public List<RigaResponse> righe;
        public String esito;
    }

    public class Testata {
        public Integer pGgIncasso;
        public Decimal pIRR;
    }

    public class RigaResponse {
        public Integer pNrMese;
        public Integer pNgGiorni;
        public Long pData;
        public Decimal pTasso;
        public Decimal pInteressiMaturati;
        public Decimal pInteressiCumul;
        public Decimal pVNInteressi;
        public Decimal pPrezzoRata1;
        public Decimal pPrezzoRata2;
        public Decimal pCostoNotaio;
        public Decimal pCostoContenz;
        public Decimal pCostoUL;
        public Decimal pIncassi;
        public Decimal pIntPassiviRata1;
        public Decimal PIntpassiviRata2;
        public Decimal pFlussoNetto;
    }

    //REQUEST TIME07
    public class CalcoloCompensiRequest {
        public String pUL;
        public Integer pContrattoUL;
        public Decimal pVN;
        public Decimal pRuoliComp;
        public Decimal pInteressiMatur;
        public Decimal pPrezzoAcq;
        public String pDDeffettuata;
        public Integer pTipoImposta;
    }

    //RESPONSE TIME07
    public class CalcoloCompensiResponse extends WsRestInput.CommonResponse {

        public PayloadCalcoloCompensi payload;

        public override Boolean isCorrect() {
            return payload != null;
        }
    }

    public class PayloadCalcoloCompensi {
        public Decimal pCompenso;
        public Decimal pCap;
        public Decimal pIVA;
    }
}